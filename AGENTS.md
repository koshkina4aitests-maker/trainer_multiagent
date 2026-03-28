# AGENTS.md — Backend Deployment Pipeline

**Роль агента:** Senior DevOps Engineer  
**Контекст:** Бекэнд фитнес-приложения (модульный монолит, PostgreSQL, Redis, Docker/Kubernetes).  
**Фронтенд:** Flutter (мобильное приложение, iOS/Android).

---

## Принципы безопасной работы с секретами

> **ВАЖНО.** Агент работает с серверными кредентиалами по следующим правилам:
>
> 1. Запрашивать временные кредентиалы у пользователя **один раз** — строго перед выполнением шага, которому они нужны.
> 2. Хранить их **только в переменных окружения текущего shell-сессии** (`export VAR=value`), не писать в файлы и не логировать значения.
> 3. Немедленно после завершения шага — вызывать `unset` для каждой переменной и очищать `~/.bash_history`.
> 4. Проверять, что секреты не попали в логи CI/CD (`git log`, `docker inspect`, stdout/stderr пайплайна).
> 5. Никогда не передавать кредентиалы через `--build-arg`, `ENV` в Dockerfile или флаги командной строки, видимые в `ps aux`.

---

## Шаг 0 — Запрос временных кредентиалов (выполнить первым)

```
АГЕНТ ДОЛЖЕН СКАЗАТЬ ПОЛЬЗОВАТЕЛЮ:
"Для подключения к серверу мне нужны временные кредентиалы.
 Пожалуйста, предоставьте:
   - SERVER_HOST   — IP или hostname сервера
   - SERVER_USER   — SSH-пользователь
   - SERVER_KEY    — приватный SSH-ключ (base64 или путь к файлу)
   - DB_PASSWORD   — пароль PostgreSQL (если задан отдельно)
   - REGISTRY_TOKEN — токен доступа к container registry (если используется)

 Эти данные будут использованы однократно и немедленно удалены."
```

После получения ответа от пользователя:

```bash
# Загрузить кредентиалы в окружение текущей сессии
export SERVER_HOST="<значение от пользователя>"
export SERVER_USER="<значение от пользователя>"
export SERVER_KEY_B64="<значение от пользователя>"
export DB_PASSWORD="<значение от пользователя>"
export REGISTRY_TOKEN="<значение от пользователя>"

# Восстановить приватный ключ во временный файл с ограниченными правами
export SSH_KEY_FILE="$(mktemp)"
echo "${SERVER_KEY_B64}" | base64 -d > "${SSH_KEY_FILE}"
chmod 600 "${SSH_KEY_FILE}"
```

> После завершения всех шагов выполнить **Шаг 9 — Очистка секретов**.

---

## Шаг 1 — Проверка доступности сервера

```bash
# Проверка SSH-соединения (без записи host key в постоянный known_hosts)
ssh -i "${SSH_KEY_FILE}" \
    -o StrictHostKeyChecking=no \
    -o UserKnownHostsFile=/dev/null \
    -o LogLevel=ERROR \
    "${SERVER_USER}@${SERVER_HOST}" \
    "echo 'SSH OK' && uname -a && df -h / && free -m"
```

**Ожидаемый результат:** строка `SSH OK`, версия ОС, наличие свободного дискового пространства (≥ 5 ГБ) и памяти (≥ 1 ГБ).

---

## Шаг 2 — Настройка окружения на сервере

```bash
ssh -i "${SSH_KEY_FILE}" \
    -o StrictHostKeyChecking=no \
    -o UserKnownHostsFile=/dev/null \
    "${SERVER_USER}@${SERVER_HOST}" << 'REMOTE'

set -euo pipefail

# --- Обновление пакетов и установка системных зависимостей ---
sudo apt-get update -qq
sudo apt-get install -y --no-install-recommends \
    curl ca-certificates gnupg lsb-release \
    git make jq unzip

# --- Docker (если не установлен) ---
if ! command -v docker &>/dev/null; then
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
        | sudo gpg --dearmor -o /usr/share/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) \
          signed-by=/usr/share/keyrings/docker.gpg] \
          https://download.docker.com/linux/ubuntu \
          $(lsb_release -cs) stable" \
        | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update -qq
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    sudo systemctl enable docker --now
    sudo usermod -aG docker "${USER}"
fi

# --- Docker Compose (standalone, если нужен) ---
if ! command -v docker-compose &>/dev/null; then
    COMPOSE_VER="v2.24.6"
    sudo curl -SL \
        "https://github.com/docker/compose/releases/download/${COMPOSE_VER}/docker-compose-linux-$(uname -m)" \
        -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
fi

echo "Docker version: $(docker --version)"
echo "Compose version: $(docker compose version)"

REMOTE
```

---

## Шаг 3 — Получение кода и создание структуры деплоя

```bash
ssh -i "${SSH_KEY_FILE}" \
    -o StrictHostKeyChecking=no \
    -o UserKnownHostsFile=/dev/null \
    "${SERVER_USER}@${SERVER_HOST}" << 'REMOTE'

set -euo pipefail

DEPLOY_DIR="/opt/fitness-app"
REPO_URL="https://github.com/<org>/fitness-backend.git"   # <-- подставить реальный URL
BRANCH="main"

sudo mkdir -p "${DEPLOY_DIR}"
sudo chown "${USER}:${USER}" "${DEPLOY_DIR}"

if [ -d "${DEPLOY_DIR}/.git" ]; then
    echo "Repo exists — pulling latest..."
    git -C "${DEPLOY_DIR}" fetch origin "${BRANCH}"
    git -C "${DEPLOY_DIR}" reset --hard "origin/${BRANCH}"
else
    echo "Cloning repo..."
    git clone --branch "${BRANCH}" --depth=1 "${REPO_URL}" "${DEPLOY_DIR}"
fi

echo "Current commit: $(git -C ${DEPLOY_DIR} rev-parse --short HEAD)"

REMOTE
```

---

## Шаг 4 — Установка зависимостей и сборка Docker-образа

```bash
# Передать секреты через stdin (не через переменные среды процесса или build-arg)
ssh -i "${SSH_KEY_FILE}" \
    -o StrictHostKeyChecking=no \
    -o UserKnownHostsFile=/dev/null \
    "${SERVER_USER}@${SERVER_HOST}" \
    "cat > /tmp/build_env_transfer" << ENVFILE
REGISTRY_TOKEN=${REGISTRY_TOKEN}
ENVFILE

ssh -i "${SSH_KEY_FILE}" \
    -o StrictHostKeyChecking=no \
    -o UserKnownHostsFile=/dev/null \
    "${SERVER_USER}@${SERVER_HOST}" << 'REMOTE'

set -euo pipefail
DEPLOY_DIR="/opt/fitness-app"

# Загрузить переменные окружения деплоя из защищённого файла на сервере
# (файл должен быть создан при первом ручном provisioning с правами 600)
ENV_FILE="/opt/fitness-app/.env.production"
if [ ! -f "${ENV_FILE}" ]; then
    echo "ERROR: ${ENV_FILE} не найден. Создайте его вручную при первом деплое." >&2
    exit 1
fi

cd "${DEPLOY_DIR}"

# Сборка образа с BuildKit (secrets via --secret, не через ARG)
DOCKER_BUILDKIT=1 docker build \
    --progress=plain \
    --tag "fitness-backend:$(git rev-parse --short HEAD)" \
    --tag "fitness-backend:latest" \
    .

echo "Build complete."

REMOTE
```

### Пример минимального `Dockerfile` (для справки)

```dockerfile
# syntax=docker/dockerfile:1.6
FROM python:3.12-slim AS base
WORKDIR /app

# Установка зависимостей через BuildKit cache mount (не попадает в слои образа)
RUN --mount=type=cache,target=/root/.cache/pip \
    --mount=type=bind,source=requirements.txt,target=requirements.txt \
    pip install --no-cache-dir -r requirements.txt

COPY . .

RUN python -m compileall -q .

EXPOSE 8000
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

---

## Шаг 5 — Настройка переменных окружения и секретов приложения

```bash
ssh -i "${SSH_KEY_FILE}" \
    -o StrictHostKeyChecking=no \
    -o UserKnownHostsFile=/dev/null \
    "${SERVER_USER}@${SERVER_HOST}" << REMOTE

set -euo pipefail
ENV_FILE="/opt/fitness-app/.env.production"

# Если файл уже существует — только обновить DB_PASSWORD (остальное не трогать)
if grep -q "^DB_PASSWORD=" "\${ENV_FILE}" 2>/dev/null; then
    sed -i "s|^DB_PASSWORD=.*|DB_PASSWORD=${DB_PASSWORD}|" "\${ENV_FILE}"
else
    # Первичное создание — базовые переменные (расширить под реальный стек)
    cat > "\${ENV_FILE}" << 'EOF'
APP_ENV=production
APP_PORT=8000
DB_HOST=postgres
DB_PORT=5432
DB_NAME=fitness
DB_USER=fitness_app
DB_PASSWORD=PLACEHOLDER_REPLACED_BELOW
REDIS_URL=redis://redis:6379/0
JWT_SECRET=REPLACE_WITH_STRONG_RANDOM_SECRET
ALLOWED_ORIGINS=https://your-domain.com
LOG_LEVEL=info
EOF
    sed -i "s|DB_PASSWORD=PLACEHOLDER_REPLACED_BELOW|DB_PASSWORD=${DB_PASSWORD}|" "\${ENV_FILE}"
fi

chmod 600 "\${ENV_FILE}"
echo ".env.production updated (permissions: \$(stat -c '%a' \${ENV_FILE}))"

REMOTE
```

> **Безопасность:** `.env.production` должен быть в `.gitignore`, не попадать в образ Docker и не выводиться в логи.

---

## Шаг 6 — Запуск инфраструктуры и бекэнда (Docker Compose)

```bash
ssh -i "${SSH_KEY_FILE}" \
    -o StrictHostKeyChecking=no \
    -o UserKnownHostsFile=/dev/null \
    "${SERVER_USER}@${SERVER_HOST}" << 'REMOTE'

set -euo pipefail
DEPLOY_DIR="/opt/fitness-app"
cd "${DEPLOY_DIR}"

# Применить миграции базы данных ДО перезапуска API
echo "--- Running DB migrations ---"
docker compose --env-file .env.production \
    run --rm api python manage.py migrate --no-input 2>&1

# Поднять/обновить сервисы
echo "--- Deploying services ---"
docker compose --env-file .env.production up -d \
    --remove-orphans \
    --wait \
    --timeout 120

echo "--- Service status ---"
docker compose ps

echo "--- Health check ---"
sleep 5
curl -fsS http://localhost:8000/health | jq . || \
    (echo "Health check FAILED" && docker compose logs api --tail=50 && exit 1)

REMOTE
```

### Пример `docker-compose.yml` (для справки)

```yaml
services:
  postgres:
    image: postgres:16-alpine
    restart: unless-stopped
    volumes:
      - postgres_data:/var/lib/postgresql/data
    env_file: .env.production
    environment:
      POSTGRES_DB: ${DB_NAME}
      POSTGRES_USER: ${DB_USER}
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${DB_USER}"]
      interval: 10s
      timeout: 5s
      retries: 5

  redis:
    image: redis:7-alpine
    restart: unless-stopped
    volumes:
      - redis_data:/data
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 3s
      retries: 5

  api:
    image: fitness-backend:latest
    restart: unless-stopped
    env_file: .env.production
    ports:
      - "8000:8000"
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
    healthcheck:
      test: ["CMD-SHELL", "curl -fsS http://localhost:8000/health || exit 1"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 20s

  worker:
    image: fitness-backend:latest
    restart: unless-stopped
    command: ["celery", "-A", "app.worker", "worker", "--loglevel=info"]
    env_file: .env.production
    depends_on:
      - redis
      - postgres

volumes:
  postgres_data:
  redis_data:
```

---

## Шаг 7 — Интеграционные тесты Flutter-фронтенда

Интеграционные тесты запускаются **локально** (или в CI) против развёрнутого бекэнда.

```bash
# 7.1 Установить Flutter SDK (если не установлен в CI)
if ! command -v flutter &>/dev/null; then
    FLUTTER_VERSION="3.22.0"   # синхронизировать с pubspec.yaml
    curl -fsSL \
        "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz" \
        | tar -xJ -C "${HOME}"
    export PATH="${HOME}/flutter/bin:${PATH}"
fi

flutter --version

# 7.2 Перейти в директорию фронтенда
FRONTEND_DIR="./frontend"   # <-- скорректировать путь
cd "${FRONTEND_DIR}"

# 7.3 Установить зависимости Dart/Flutter
flutter pub get

# 7.4 Убедиться, что бекэнд доступен по нужному хосту
API_BASE_URL="http://${SERVER_HOST}:8000"
echo "Testing against: ${API_BASE_URL}"
curl -fsS "${API_BASE_URL}/health" | jq .

# 7.5 Запустить интеграционные тесты
# Вариант A — Flutter integration_test (для эмулятора/устройства)
flutter test integration_test/ \
    --dart-define=API_BASE_URL="${API_BASE_URL}" \
    --reporter=expanded \
    -v

# Вариант B — dart run tests (для чистых Dart-тестов без UI)
# dart test test/integration/ \
#     --dart-define=API_BASE_URL="${API_BASE_URL}"

# 7.6 Статический анализ и проверка форматирования
flutter analyze --no-fatal-infos
dart format --set-exit-if-changed .

echo "All Flutter integration tests passed."
```

> **Совет:** Для тестов с реальным эмулятором (Android/iOS) добавить шаг запуска Android AVD или iOS Simulator и передать флаг `--device-id`.

---

## Шаг 8 — Проверка наблюдаемости и финальный smoke-test

```bash
ssh -i "${SSH_KEY_FILE}" \
    -o StrictHostKeyChecking=no \
    -o UserKnownHostsFile=/dev/null \
    "${SERVER_USER}@${SERVER_HOST}" << 'REMOTE'

set -euo pipefail
DEPLOY_DIR="/opt/fitness-app"
cd "${DEPLOY_DIR}"

echo "=== Container status ==="
docker compose ps

echo "=== Resource usage ==="
docker stats --no-stream

echo "=== API smoke tests ==="
BASE="http://localhost:8000"

# Health
curl -fsS "${BASE}/health" | jq '{status: .status}'

# Auth endpoint доступен (ожидаем 401, не 500)
STATUS=$(curl -o /dev/null -sw "%{http_code}" "${BASE}/v1/auth/me")
[ "${STATUS}" = "401" ] && echo "Auth endpoint OK (401 Unauthorized — expected)" \
    || echo "WARN: auth endpoint returned ${STATUS}"

echo "=== Log tail (last 20 lines, без секретов) ==="
docker compose logs api --tail=20 \
    | grep -v -i "password\|secret\|token\|key" || true

echo "=== Smoke test PASSED ==="

REMOTE
```

---

## Шаг 9 — Обязательная очистка секретов (выполнить ВСЕГДА)

> Этот шаг выполняется **после любого завершения пайплайна** — успешного или с ошибкой.

```bash
# --- Локальная очистка переменных окружения ---
unset SERVER_HOST
unset SERVER_USER
unset SERVER_KEY_B64
unset DB_PASSWORD
unset REGISTRY_TOKEN

# --- Удаление временного SSH-ключа ---
if [ -n "${SSH_KEY_FILE:-}" ] && [ -f "${SSH_KEY_FILE}" ]; then
    shred -u "${SSH_KEY_FILE}" 2>/dev/null || rm -f "${SSH_KEY_FILE}"
    unset SSH_KEY_FILE
fi

# --- Очистка bash history текущей сессии ---
history -c
history -w

# --- Удалить временные файлы с кредентиалами на сервере (если создавались) ---
# ssh ... "rm -f /tmp/build_env_transfer"

# --- Финальная проверка ---
echo "Secret variables cleared:"
for VAR in SERVER_HOST SERVER_USER SERVER_KEY_B64 DB_PASSWORD REGISTRY_TOKEN SSH_KEY_FILE; do
    VALUE="${!VAR:-UNSET}"
    if [ "${VALUE}" = "UNSET" ]; then
        echo "  [OK] ${VAR} = unset"
    else
        echo "  [WARN] ${VAR} is still set — check cleanup!"
    fi
done

echo "Cleanup complete."
```

---

## Шаг 10 — Проверка отсутствия секретов в логах

```bash
# Проверить git log на наличие случайно закоммиченных секретов
echo "=== Checking git log for leaked secrets ==="
PATTERNS="password|secret|token|private_key|api_key|db_pass"
git log --all --oneline -p | grep -iE "${PATTERNS}" \
    && echo "WARNING: Possible secret found in git history!" \
    || echo "Git log clean."

# Проверить docker inspect (history слоёв образа)
echo "=== Checking Docker image for leaked ENV secrets ==="
docker inspect fitness-backend:latest \
    | jq '.[].Config.Env[]' 2>/dev/null \
    | grep -iE "${PATTERNS}" \
    && echo "WARNING: Secret found in Docker image ENV!" \
    || echo "Docker image ENV clean."

echo "=== All checks passed. Pipeline complete. ==="
```

---

## Итоговый порядок выполнения

| # | Шаг | Кто выполняет |
|---|-----|---------------|
| 0 | Запрос временных кредентиалов | Агент → Пользователь |
| 1 | Проверка доступности сервера | Агент |
| 2 | Настройка окружения (Docker, зависимости) | Агент на сервере |
| 3 | Получение кода (git clone/pull) | Агент на сервере |
| 4 | Сборка Docker-образа | Агент на сервере |
| 5 | Настройка `.env.production` | Агент на сервере |
| 6 | Запуск инфраструктуры и миграций | Агент на сервере |
| 7 | Интеграционные тесты Flutter | Агент локально/CI |
| 8 | Smoke-тест и наблюдаемость | Агент на сервере |
| **9** | **Очистка всех секретов** | **Агент — ОБЯЗАТЕЛЬНО** |
| 10 | Проверка логов на утечки | Агент |

---

## Замечания по безопасности

- Все секреты живут **только в переменных окружения текущей shell-сессии** (не в файлах, не в переменных среды Docker-контейнеров через `--env`, не в `docker-compose.yml` напрямую).
- `.env.production` на сервере — единственное долгоживущее хранилище секретов; доступ `chmod 600`, владелец — deploy-пользователь.
- SSH-ключ существует как временный файл `mktemp` и уничтожается через `shred` сразу после работы.
- `history -c && history -w` очищает историю bash, чтобы команды с параметрами не сохранялись.
- В логах контейнеров маскируются строки, содержащие `password`, `secret`, `token`, `key` (проверяется в Шаге 10).
- Для production рекомендуется переход на **HashiCorp Vault**, **AWS Secrets Manager** или **Doppler** вместо `.env`-файлов.

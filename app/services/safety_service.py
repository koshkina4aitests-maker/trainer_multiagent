from app.schemas.safety import SafetyScreeningRequest, SafetyScreeningResponse


def evaluate_safety(payload: SafetyScreeningRequest) -> SafetyScreeningResponse:
    warnings: list[str] = []
    emergency_guidance = "При ухудшении состояния остановите тренировку и обратитесь к врачу."
    risk_level = "low"

    if payload.chest_pain or payload.has_dizziness:
        risk_level = "high"
        warnings.append("Обнаружены красные флаги (боль в груди/головокружение).")
        emergency_guidance = (
            "Немедленно прекратите тренировку, примите безопасное положение, "
            "при выраженных симптомах вызовите экстренную помощь."
        )

    if payload.has_sharp_pain:
        risk_level = "high"
        warnings.append("Острая боль указывает на риск травмы. Силовая нагрузка запрещена.")

    if payload.heart_rate_recovery_seconds is not None and payload.heart_rate_recovery_seconds > 180:
        risk_level = "medium" if risk_level == "low" else risk_level
        warnings.append("Медленное восстановление ЧСС: снизьте интенсивность и увеличьте отдых.")

    condition = payload.current_condition.strip().lower()
    if any(flag in condition for flag in ("pain", "боль", "nausea", "тошно")):
        if risk_level == "low":
            risk_level = "medium"
        warnings.append("Симптомы из self-report требуют щадящего режима.")

    if not warnings:
        warnings.append("Критичных сигналов не обнаружено, сохраняйте технику и умеренную прогрессию.")

    return SafetyScreeningResponse(
        risk_level=risk_level,
        warnings=warnings,
        emergency_guidance=emergency_guidance,
    )

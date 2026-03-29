def test_core_mvp_flow() -> None:
    from uuid import uuid4

    from fastapi.testclient import TestClient

    from app.main import app

    suffix = uuid4().hex[:8]
    email = f"user-{suffix}@example.com"
    google_sub = f"google-sub-{suffix}"
    exercise_name = f"Barbell Bench Press {suffix}"

    with TestClient(app) as client:
        auth_resp = client.post(
            "/v1/auth/google",
            json={
                "email": email,
                "full_name": "Test User",
                "google_sub": google_sub,
            },
        )
        assert auth_resp.status_code == 200
        user_id = auth_resp.json()["user_id"]

        profile_resp = client.put(
            f"/v1/users/{user_id}/profile",
            headers={"X-User-Id": str(user_id)},
            json={
                "age": 30,
                "height_cm": 175,
                "weight_kg": 78,
                "medical_notes": "knee pain",
                "training_context": "gym",
                "training_style": "fullbody",
            },
        )
        assert profile_resp.status_code == 200
        assert profile_resp.json()["training_context"] == "gym"
        assert profile_resp.json()["training_style"] == "fullbody"

        goal_resp = client.post(
            f"/v1/users/{user_id}/goals",
            headers={"X-User-Id": str(user_id)},
            json={"goal_type": "strength", "target_value": "bench_press_100kg"},
        )
        assert goal_resp.status_code == 201

        exercise_resp = client.post(
            "/v1/exercises",
            json={
                "name": exercise_name,
                "muscle_group": "chest",
                "contraindications": "shoulder pain",
            },
        )
        assert exercise_resp.status_code == 201
        exercise_id = exercise_resp.json()["id"]

        plan_resp = client.post(
            f"/v1/users/{user_id}/plans",
            headers={"X-User-Id": str(user_id)},
            json={
                "title": "Push Day A",
                "program_type": "custom",
                "source": "manual",
                "recommendation_style": "custom",
                "notes": "MVP test plan",
                "items": [
                    {
                        "exercise_id": exercise_id,
                        "exercise_name": exercise_name,
                        "sets": 3,
                        "reps": 8,
                        "weight_kg": 60,
                        "rir_target": 2,
                    },
                ],
            },
        )
        assert plan_resp.status_code == 201
        plan_id = plan_resp.json()["id"]

        session_resp = client.post(
            "/v1/workouts/sessions",
            headers={"Idempotency-Key": "session-start-1", "X-User-Id": str(user_id)},
            json={
                "user_id": user_id,
                "plan_id": plan_id,
                "current_condition": "light fatigue today",
            },
        )
        assert session_resp.status_code == 201
        session_id = session_resp.json()["id"]

        session_duplicate_resp = client.post(
            "/v1/workouts/sessions",
            headers={"Idempotency-Key": "session-start-1", "X-User-Id": str(user_id)},
            json={
                "user_id": user_id,
                "plan_id": plan_id,
                "current_condition": "light fatigue today",
            },
        )
        assert session_duplicate_resp.status_code == 409

        log_resp = client.post(
            f"/v1/workouts/sessions/{session_id}/logs",
            headers={"X-User-Id": str(user_id)},
            json={
                "exercise_id": exercise_id,
                "sets": 3,
                "reps_per_set": 8,
                "weight_kg": 60,
                "rir": 2,
            },
        )
        assert log_resp.status_code == 201

        complete_resp = client.post(
            f"/v1/workouts/sessions/{session_id}/complete",
            headers={"Idempotency-Key": "complete-session-1", "X-User-Id": str(user_id)},
        )
        assert complete_resp.status_code == 200
        assert complete_resp.json()["status"] == "completed"

        recommendation_resp = client.post(
            f"/v1/users/{user_id}/recommendations",
            headers={"Idempotency-Key": "recommendation-1", "X-User-Id": str(user_id)},
            json={"current_condition": "fatigue and minor pain", "style": "split_upper"},
        )
        assert recommendation_resp.status_code == 200
        rationale = recommendation_resp.json()["rationale"].lower()
        assert "истории тренировок" in rationale
        assert "план объясним" in rationale
        assert recommendation_resp.json()["style"] == "split_upper"
        assert len(recommendation_resp.json()["exercises"]) > 0

        copy_resp = client.post(
            f"/v1/users/{user_id}/recommendations/{recommendation_resp.json()['recommendation_id']}/copy-to-plan",
            headers={"X-User-Id": str(user_id)},
            json={
                "title": "Copied recommendation",
                "program_type": "custom",
                "notes": "Copied from recommendation",
            },
        )
        assert copy_resp.status_code == 201
        assert copy_resp.json()["title"] == "Copied recommendation"

        history_resp = client.get(
            f"/v1/workouts/history/{user_id}",
            headers={"X-User-Id": str(user_id)},
        )
        assert history_resp.status_code == 200
        history = history_resp.json()
        assert len(history) >= 1
        assert history[0]["id"] == session_id

        safety_resp = client.post(
            "/v1/safety/screening",
            json={
                "current_condition": "mild pain after previous session",
                "has_sharp_pain": False,
                "has_dizziness": False,
                "chest_pain": False,
                "heart_rate_recovery_seconds": 210,
            },
        )
        assert safety_resp.status_code == 200
        safety = safety_resp.json()
        assert safety["risk_level"] in {"medium", "high"}
        assert len(safety["warnings"]) >= 1

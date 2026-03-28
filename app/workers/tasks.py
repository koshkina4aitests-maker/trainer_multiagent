from app.workers.celery_app import celery_app


@celery_app.task(name="notifications.send_workout_completion_message")
def send_workout_completion_message(user_id: int, session_id: int) -> str:
    # Placeholder for push/email integration adapter.
    return f"Queued completion message for user={user_id}, session={session_id}"


@celery_app.task(name="insights.recompute_user_progress")
def recompute_user_progress(user_id: int) -> str:
    return f"Queued progress recomputation for user={user_id}"


@celery_app.task(name="billing.process_webhook_event")
def process_billing_webhook_event(event_id: str) -> str:
    return f"Queued billing webhook processing for event={event_id}"

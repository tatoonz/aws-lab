import json
from datetime import datetime


def lambda_handler(event, context):
    """
    Handles events triggered by the EventBridge scheduled rule.
    """
    current_time = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    print(f"--- Scheduled Lambda Invoked ---")
    print(f"Invocation Time: {current_time}")
    print(f"Event Source: {event.get('source', 'Unknown')}")
    print(f"The Lambda is running on a schedule.")

    # Your processing logic goes here.
    # Example: Run database cleanup, send summary reports, check health, etc.

    return {
        "statusCode": 200,
        "body": json.dumps(
            {"message": f"Daily scheduled job executed at {current_time}"}
        ),
    }

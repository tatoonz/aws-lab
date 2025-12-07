# Trigger Lambda on a Schedule (EventBridge Scheduler)

This project demonstrates how to set up an AWS architecture where an AWS Lambda function is triggered automatically on a defined schedule using Amazon EventBridge Scheduler. This pattern is commonly used for periodic tasks, such as generating daily reports, database cleanup, or health checks.

## Architecture

1.  **EventBridge Scheduler**: Configured with a schedule expression (e.g., `rate(1 minute)`) to trigger the target.
2.  **Lambda Function**: A Python function that is invoked by the scheduler. In this example, it simply logs the current time and invocation details.
3.  **IAM Roles & Policies**:
    -   **Lambda Role**: Allows the function to write logs to CloudWatch.
    -   **Scheduler Role**: Allows EventBridge Scheduler to invoke the Lambda function.

## Prerequisites

-   AWS Account and credentials configured locally.
-   [OpenTofu](https://opentofu.org/) (or Terraform) installed.
-   [AWS CLI](https://aws.amazon.com/cli/) installed.

## Project Structure

```text
.
├── process.py                 # The Python code for the Lambda function
└── tofu/                      # Infrastructure as Code (OpenTofu/Terraform)
    ├── main.tf                # Resources definition (Scheduler, Lambda, IAM)
    ├── variables.tf           # Input variables
    └── example.tfvars.demo    # Example variable values
```

## Deployment

1.  **Navigate to the infrastructure directory:**

    ```bash
    cd tofu
    ```

2.  **Initialize OpenTofu:**

    ```bash
    tofu init
    ```

3.  **Customize Variables (Optional):**
    
    Review `variables.tf` and `example.tfvars.demo`. You can create your own `terraform.tfvars` or rename `example.tfvars.demo` to `example.tfvars` and modify it.
    
    *Note: The `aws_profile` variable in `example.tfvars.demo` is set to "your-aws-profile". Change this to your local AWS profile name if different.*
    *Note: The default schedule is `rate(1 minute)`. You can change this via the `event_schedule_expression` variable.*

4.  **Review the Plan:**

    ```bash
    tofu plan -var-file=example.tfvars
    ```

5.  **Apply the Configuration:**

    ```bash
    tofu apply -var-file=example.tfvars
    ```
    
    Type `yes` when prompted to confirm.

    Once applied, OpenTofu will create:
    -   A Lambda function containing the code from `process.py`.
    -   An EventBridge Scheduler schedule.
    -   Necessary IAM permissions.

## Testing

1.  **Wait for the Schedule:**
    The default schedule is configured to run every 1 minute. Wait a minute or two after deployment.

2.  **Check Logs:**
    Go to the AWS Console -> **CloudWatch** -> **Log groups**.
    Find the log group for your Lambda function (e.g., `/aws/lambda/{prefix}-demo-scheduled-lambda-function`).
    
    Open the latest log stream. You should see messages indicating the function was invoked:
    
    ```text
    --- Scheduled Lambda Invoked ---
    Invocation Time: 2023-10-27 10:00:00
    Event Source: Unknown
    The Lambda is running on a schedule.
    ```

## Cleanup

To avoid incurring charges, destroy the resources when you are done:

```bash
tofu destroy -var-file=example.tfvars
```

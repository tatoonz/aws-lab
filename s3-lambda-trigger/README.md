# Trigger Lambda when New File Uploaded to S3

This project demonstrates how to set up an AWS architecture where an upload to an Amazon S3 bucket automatically triggers an AWS Lambda function. This pattern is commonly used for event-driven processing, such as image resizing, data validation, or log ingestion.

## Architecture

1.  **S3 Bucket**: Stores the uploaded files.
2.  **S3 Event Notification**: Configured to send an event to Lambda whenever a new object is created (`s3:ObjectCreated:*`).
3.  **Lambda Function**: A Python function that receives the event, downloads the file from S3, and processes it (in this example, it counts the number of lines in the file).
4.  **IAM Roles & Policies**: Ensures the Lambda function has permission to read from S3 and write logs to CloudWatch, and that S3 has permission to invoke the Lambda function.

## Prerequisites

-   AWS Account and credentials configured locally.
-   [OpenTofu](https://opentofu.org/) (or Terraform) installed.
-   [AWS CLI](https://aws.amazon.com/cli/) installed.

## Project Structure

```text
.
├── process.py                 # The Python code for the Lambda function
├── demo-uploade-file-*.txt    # Sample files for testing
└── tofu/                      # Infrastructure as Code (OpenTofu/Terraform)
    ├── main.tf                # Resources definition (S3, Lambda, IAM)
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
    -   An S3 bucket.
    -   A Lambda function containing the code from `process.py`.
    -   Necessary IAM permissions.

## Testing

1.  **Find the Bucket Name:**
    Go to the AWS Console S3 page or check the output/state to find the bucket name (it will look like `{prefix}-demo-s3-trigger-lambda-bucket`).

2.  **Upload a File:**
    Upload one of the sample text files (or any text file) to the bucket using the AWS Console or CLI:

    ```bash
    # Example CLI command (replace <bucket_name> with actual bucket name)
    aws s3 cp ../demo-uploade-file-1.txt s3://<bucket_name>/
    ```

3.  **Check Logs:**
    Go to the AWS Console -> **CloudWatch** -> **Log groups**.
    Find the log group for your Lambda function (e.g., `/aws/lambda/{prefix}-demo-s3-trigger-lambda-function`).
    
    Open the latest log stream. You should see messages indicating the file was processed:
    
    ```text
    New file uploaded: s3://<bucket_name>/demo-uploade-file-1.txt
    Processed file: demo-uploade-file-1.txt, line count: <number>
    ```

## Cleanup

To avoid incurring charges, destroy the resources when you are done:

```bash
tofu destroy -var-file=example.tfvars
```

*Note: The S3 bucket resource has `force_destroy = true` enabled, so it will be deleted even if it contains objects.*

import os

import boto3

s3 = boto3.client("s3")


def lambda_handler(event, context):
    # Each "record" is each S3 object triggered in event
    for record in event["Records"]:
        bucket = record["s3"]["bucket"]["name"]
        key = record["s3"]["object"]["key"]

        print(f"New file uploaded: s3://{bucket}/{key}")

        # Download the file to /tmp (Lambda writable space)
        download_path = f"/tmp/{os.path.basename(key)}"
        s3.download_file(bucket, key, download_path)

        # Example processing: count lines
        try:
            with open(download_path, "r") as f:
                line_count = sum(1 for _ in f)
            print(f"Processed file: {key}, line count: {line_count}")
        except Exception as e:
            print(f"Failed to process file: {e}")

    return {"status": "ok"}

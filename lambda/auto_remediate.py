import json
import boto3

def lambda_handler(event, context):
    print("Received event:", json.dumps(event, indent=2))
    
    s3 = boto3.client('s3')
    bucket_name = event.get("detail", {}).get("resourcesAffected", {}).get("s3Bucket", {}).get("name")
    
    if bucket_name:
        try:
            # Remove public access
            s3.put_bucket_acl(Bucket=bucket_name, ACL='private')
            print(f"Set bucket {bucket_name} ACL to private.")
        except Exception as e:
            print(f"Error setting bucket ACL: {e}")
    else:
        print("No bucket name found in the event.")
    
    return {"status": "done"}

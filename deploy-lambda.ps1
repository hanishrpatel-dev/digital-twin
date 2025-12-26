# Load environment variables
Get-Content .env | ForEach-Object {
    if ($_ -match '^([^=]+)=(.*)$') {
        [System.Environment]::SetEnvironmentVariable($matches[1], $matches[2], 'Process')
    }
}


cd backend

# Create a unique S3 bucket name for deployment
$timestamp = Get-Date -Format "yyyyMMddHHmmss"
$deployBucket = "twin-deploy-$timestamp"

# Create the bucket
aws s3 mb s3://$deployBucket --region $env:DEFAULT_AWS_REGION

# Upload your zip file to S3
aws s3 cp lambda-deployment.zip s3://$deployBucket/ --region $env:DEFAULT_AWS_REGION

# Update Lambda function from S3
aws lambda update-function-code `
    --function-name twin-api `
    --s3-bucket $deployBucket `
    --s3-key lambda-deployment.zip `
    --region $env:DEFAULT_AWS_REGION

# Clean up: delete the temporary bucket
aws s3 rm s3://$deployBucket/lambda-deployment.zip
aws s3 rb s3://$deployBucket
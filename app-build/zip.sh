BUCKET_NAME=$1
if [ -z "$BUCKET_NAME" ]; then
    echo "Usage: $0 <BUCKET_NAME>"
    exit 1
fi

zip -r code.zip ./src
aws s3 cp code.zip s3://$BUCKET_NAME/code.zip
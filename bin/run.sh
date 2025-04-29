#!/bin/sh
set -e

IMAGE_NAME="node:16-alpine"

CMD=$(echo "$@" | sed 's/^-- //')

# Run the command and pass through some environment variables
docker run \
  --rm \
  -it \
  -w=/app \
  -v $(pwd):/app \
  -e AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY \
  -e S3_BUCKET \
  -e CF_DISTRIBUTION_ID \
  $IMAGE_NAME /bin/sh -cx "npm install && $CMD"

import fs from 'fs';
import path from 'path';
import { CloudFrontClient, CreateInvalidationCommand } from '@aws-sdk/client-cloudfront';
import { PutObjectCommand, S3Client } from '@aws-sdk/client-s3';

async function deploy(scope, root, pkg) {
  const region = process.env.AWS_REGION || process.env.AWS_DEFAULT_REGION || 'us-east-1';
  const credentials = process.env.AWS_ACCESS_KEY_ID && process.env.AWS_SECRET_ACCESS_KEY
    ? {
        accessKeyId: process.env.AWS_ACCESS_KEY_ID,
        secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
        ...(process.env.AWS_SESSION_TOKEN ? { sessionToken: process.env.AWS_SESSION_TOKEN } : {}),
      }
    : undefined;

  const bucket = new S3Client({
    region,
    credentials,
  });
  const cloudFront = new CloudFrontClient({
    region: 'us-east-1',
    credentials,
  });

  const fileData = fs.readFileSync(path.resolve(root, pkg.main));
  const filename = path.basename(pkg.main);
  const fullVersion = pkg.version;
  const majorVersion = fullVersion.split('.')[0];

  console.log(path.join(scope, fullVersion, filename));
  const uploadFile = async (version) => {
    const command = new PutObjectCommand({
      Bucket: process.env.S3_BUCKET,
      Body: fileData,
      Key: path.join(scope, version, filename),
      ACL: 'public-read',
      ContentType: 'application/javascript',
    });

    return bucket.send(command);
  };

  const s3data = await Promise.all([uploadFile(fullVersion), uploadFile(majorVersion)]);
  console.log(s3data);

  console.log('Invalidating CloudFront');

  const invalidateCloudfront = async () => {
    const command = new CreateInvalidationCommand({
      DistributionId: process.env.CF_DISTRIBUTION_ID,
      InvalidationBatch: {
        CallerReference: 'roku-mux-buildkite-pipeline',
        Paths: {
          Items: ['/roku/*'],
          Quantity: 1,
        },
      },
    });

    return cloudFront.send(command);
  };

  const cfData = await Promise.all([invalidateCloudfront()]);
  console.log(cfData);

  console.log('great success');
}

(function main() {
  deploy(
    'roku',
    process.cwd(),
    JSON.parse(fs.readFileSync(path.resolve(process.cwd(), 'package.json')).toString())
  );
})();

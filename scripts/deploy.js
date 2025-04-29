import fs from 'fs';
import AWS from 'aws-sdk';
import path from 'path';

async function deploy(scope, root, pkg) {
  const bucket = new AWS.S3({
    params: {
      Bucket: 'mux-sdks-test'
    },
  });
  const cloudFront = new AWS.CloudFront({
    region: 'us-east-1'
  })

  const fileData = fs.readFileSync(path.resolve(root, pkg.main));
  const filename = path.basename(pkg.main);
  const fullVersion = pkg.version;
  const majorVersion = fullVersion.split('.')[0];

  console.log(path.join(scope, fullVersion, filename));
  const uploadFile = (version) => {
    return new Promise((resolve, reject) => {
      const params = {
        Body: fileData,
        Key: path.join(scope, version, filename),
        ACL: 'public-read',
        ContentType: 'application/javascript',
      };

      bucket.upload(params, (err, data) => (err ? reject(err) : resolve(data)));
    });
  };

  const s3data = await Promise.all([uploadFile(fullVersion), uploadFile(majorVersion)]);
  console.log(s3data);

  console.log('Invalidating CloudFront');

  const invalidateCloudfront = () => {
    return new Promise((resolve, reject) => {
      const params = {
        DistributionId: 'EQ2SDW3HVTEIS',
        InvalidationBatch: {
          CallerReference: 'roku-mux-buildkite-pipeline',
          Paths: {
            Items: ['/roku/*'],
            Quantity: 1
          }
        }
      }

      cloudFront.createInvalidation(params, (err, data) => (err ? reject(err) : resolve(data)));
    });
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

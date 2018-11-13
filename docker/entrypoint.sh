#!/bin/sh
echo "🐋  Starting ..."

timestamp=$(date +%s)

if [ -n "$CYPRESS_CONF" ] && [ -n "$REGION" ]; then
  echo "⚙️  Downloading configuration from Parameter Store"
  aws ssm get-parameter --name ${CYPRESS_CONF} --with-decryption --region ${REGION} | jq '.Parameter.Value' --raw-output | base64 -d > cypress.json
fi

if [ -n "$CYPRESS_ENV" ] && [ -n "$REGION" ]; then
  echo "⚙️  Downloading ENV var from Parameter Store"
  aws ssm get-parameter --name ${CYPRESS_ENV} --with-decryption --region ${REGION} | jq '.Parameter.Value' --raw-output | base64 -d > cypress.env.json
fi

if [ -n "$S3_SOURCE" ] && [ -n "$REGION" ]; then
  echo "⚙️  Downloading Test from S3"
  aws s3 cp s3://${S3_SOURCE} $(pwd)/cypress/integration/  --recursive --region ${REGION}
fi

if [ "$BROWSER" == "chrome" ]; then
  echo "🦄 You are using Google Chrome"
  $(npm bin)/cypress run --browser chrome
else
  echo "⚡️ You are using Electron"
  $(npm bin)/cypress run
fi

if [ -n "$S3_REPORTS" ] && [ -n "$REGION" ]; then
  echo "📤 Uploading report to S3"
  if [ -d $(pwd)/mochawesome-report ]; then
    aws s3 cp $(pwd)/mochawesome-report s3://${S3_REPORTS}/${timestamp}/mochawesome --recursive --region ${REGION}
  fi
  if [ -d $(pwd)/cypress/videos ]; then
    aws s3 cp $(pwd)/cypress/videos s3://${S3_REPORTS}/${timestamp}/videos --recursive --region ${REGION}
  fi
  if [ -d $(pwd)/cypress/screenshots ]; then
    aws s3 cp $(pwd)/cypress/screenshots s3://${S3_REPORTS}/${timestamp}/screenshots --recursive --region ${REGION}
  fi
fi

if [ -d $(pwd)/mochawesome-report ] && [ -n "$NAMESPACE" ] && [ -n "$METRIC_OK" ] && [ -n "$METRIC_KO" ]; then
  echo "📤 Uploading metrics to CloudWatch"
  aws --region ${REGION} cloudwatch put-metric-data --namespace ${NAMESPACE} --metric-name ${METRIC_OK} --unit None --value $(cat $(pwd)/mochawesome-report/mochawesome.json | jq .stats.passes)
  aws --region ${REGION} cloudwatch put-metric-data --namespace ${NAMESPACE} --metric-name ${METRIC_KO} --unit None --value $(cat $(pwd)/mochawesome-report/mochawesome.json | jq .stats.failures)
fi

echo "Done"
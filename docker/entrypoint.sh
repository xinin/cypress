#!/bin/sh

f_timeout () { 
  echo 'A timeout has occurred.'  
  exit 1;
}

echo "🐋  Starting ..."

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

#Sometimes cypress crashes, this prevents the container from running indefinitely.
timeout 20s $(npm bin)/cypress verify || f_timeout;

if [ "$BROWSER" == "chrome" ]; then
  echo "🦄 You are using Google Chrome"
  $(npm bin)/cypress run --browser chrome
else
  echo "⚡️ You are using Electron"
  $(npm bin)/cypress run
fi

timestamp=$(date +%s)

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
  passes=0
  failures=0
  for filename in $(pwd)/mochawesome-report/*.json; do
    echo ${filename}
    passes=`expr $passes + $(cat $filename | jq '.stats.passes' --raw-output)`
    failures=`expr $failures + $(cat $filename | jq '.stats.failures' --raw-output)`
  done
  echo 'Total passes ✔️ '${passes}
  echo 'Total failures ✖️ '${failures}
  if [ -n "$DIMENSIONS" ]; then
    aws --region ${REGION} cloudwatch put-metric-data --namespace ${NAMESPACE} --metric-name ${METRIC_OK} --unit None --value ${passes} --dimensions ${DIMENSIONS}
    aws --region ${REGION} cloudwatch put-metric-data --namespace ${NAMESPACE} --metric-name ${METRIC_KO} --unit None --value ${failures} --dimensions ${DIMENSIONS}
  else
    aws --region ${REGION} cloudwatch put-metric-data --namespace ${NAMESPACE} --metric-name ${METRIC_OK} --unit None --value ${passes}
    aws --region ${REGION} cloudwatch put-metric-data --namespace ${NAMESPACE} --metric-name ${METRIC_KO} --unit None --value ${failures}
  fi
fi

echo "Done"

exit 0;
#!/bin/bash

## This setup script will:
# (1) Install the otel collector (for your org)
# (2) Deploy the hipster shop app

# General variables
SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")

# Prompts
#echo 'Enter environment (i.e. qep):'
#read ENVIRONMENT
#echo 'Enter realm (i.e. us1):'
#read REALM
#echo 'Enter ingest token:'
#read INGEST_TOKEN
#echo 'Enter rum token:'
#read RUM_TOKEN

echo $ENVIRONMENT
echo $REALM
if [ "${#INGEST_TOKEN}" -ge 1 ]
  then
    printf '%s\n' "${INGEST_TOKEN/????????/********}"
  else
    printf '%s\n' "${INGEST_TOKEN//?/*}"
fi

if [ "${#RUM_TOKEN}" -ge 1 ]
  then
    printf '%s\n' "${RUM_TOKEN/????????/********}"
  else
    printf '%s\n' "${RUM_TOKEN//?/*}"
fi

# (1) Install the otel collector (for your org)
#OTEL_VALUES_PATH="$SCRIPTPATH/otel/values.yaml"
#MY_OTEL_VALUES_PATH="$SCRIPTPATH/otel/values-mine.yaml"
# Remove if previous exists
#if [[ -e $MY_OTEL_VALUES_PATH ]]; then
#  rm "$MY_OTEL_VALUES_PATH"
#  echo "Removed previous $MY_OTEL_VALUES_PATH"
#fi
#cp $OTEL_VALUES_PATH $MY_OTEL_VALUES_PATH
## Update environment
#sed -i "s/{{environment}}/$ENVIRONMENT/" $MY_OTEL_VALUES_PATH

# Install the otel collector
#helm install --set cloudProvider=" " --set distribution=" " \
#--set splunkObservability.accessToken="$INGEST_TOKEN" \
#--set clusterName="$ENVIRONMENT" --set splunkObservability.realm="$REALM" \
#--set gateway.enabled="false" \
#-f $MY_OTEL_VALUES_PATH
#--generate-name splunk-otel-collector-chart/splunk-otel-collector

# (2) Deploy the hipster shop app

# Delete the hipster-shop-mine.yaml
HIPSTERSHOP_PATH="$SCRIPTPATH/app/hipster-shop.yaml"
MY_HIPSTERSHOP_PATH="$SCRIPTPATH/app/hipster-shop-mine.yaml"
if [[ -e $MY_HIPSTERSHOP_PATH ]]; then
  rm "$MY_HIPSTERSHOP_PATH"
  echo "Removed previous $MY_HIPSTERSHOP_PATH"
fi
# Copy template
cp $HIPSTERSHOP_PATH $MY_HIPSTERSHOP_PATH
# Replace parameters
sed -i "s/{{environment}}/$ENVIRONMENT/" $MY_HIPSTERSHOP_PATH
sed -i "s/{{realm}}/$REALM/" $MY_HIPSTERSHOP_PATH
sed -i "s/{{rum_token}}/$RUM_TOKEN/" $MY_HIPSTERSHOP_PATH
sed -i "s/{{rum_app_name}}/$ENVIRONMENT-app/" $MY_HIPSTERSHOP_PATH
# Re-deploy app
kubectl apply -f $MY_HIPSTERSHOP_PATH

echo ""
echo ""
echo ""
echo Installed the otel collector for your environment.
echo Deployed the base hipster shop application.
echo ""
echo Check in O11y Cloud if you can find the application
echo in the right org and in the right environment.
#!/bin/bash

# This setup script will:
# (1) Build the credit-check-service app
# (2) Export the image from docker
# (3) Import it into k3s
#     (Steps 2 and 3 are so we don't need to use a public registry)
# (4) Deploy the service in kubernetes
#
# We will use 9-redeploy.sh to update the app.
# It adds a step of manually finding and deleting the pod,
# because unless the kubernetes manifest is changed the pod
# won't redeploy with the new container image until it restarts.

# (1) Build the credit-check-service app
docker build -t credit-check-service:latest creditcheckservice

# (2) Export the image from docker
docker save --output credit-check-service.tar credit-check-service:latest

# (3) Import it into k3s
sudo k3s ctr images import credit-check-service.tar

# (4) Deploy the service in kubernetes
kubectl apply -f creditcheckservice/creditcheckservice.yaml

echo ""
echo ""
echo ""
echo Deployed the new creditcheckservice.
echo ""
echo This is the service you will need to configure/code.
echo ""
echo You will use 9-redeploy.sh after making any changes to redeploy the service.
echo ""
echo Important note, if there were any issues with this deployment you will need
echo to downgrade docker. See
echo - 1b-docker-uninstall.sh
echo - 1c-docker-reinstall-pinned-version.sh#!/bin/bash

# This setup script will:
# (1) Deploy the creditprocessorservice
#
# This is a new service for which you don't have the source
# code. But you can look in the source code for
# creditcheckservice to see what APIs it is using from it.

# (1) Deploy the creditprocessorservice

kubectl apply -f creditprocessorservice/creditprocessorservice.yaml

echo ""
echo ""
echo ""
echo Deployed the new creditprocessorservice.
echo ""
echo This service is instrumented already.#!/bin/bash

# This setup script will:
# (1) Deploy the updated paymentservice service
#
# The paymentservice was deployed with the hipster shop,
# but this will deploy a new version which will be calling
# your creditcheckservice. You also don't have the updated code
# for this service, but you can see which APIs that it could
# possibly be calling, and you can look at the traces in
# Splunk Observability Cloud.

kubectl apply -f paymentservice/paymentservice.yaml

echo ""
echo ""
echo ""
echo Deployed the updated paymentservice.
echo ""
echo This service will now use your new creditcheckservice.
echo ""
echo Read the guides carefully.
echo It is now time to instrument the creditcheckservice.

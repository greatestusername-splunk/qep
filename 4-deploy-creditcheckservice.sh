#!/bin/bash

# This setup script will:
# (1) Build the credit-check-service app
# (2) Export the image from docker
# (3) Import it into k3s
#     (Steps 2 and 3 are so we don't need to use a public registry)
# (4) Deploy the service in kubernetes
#
# We will use update-creditcheckservice.sh to update the app.
# That script will do the first 3 steps of this script. (The
# last step isn't needed because the manifest is using the latest
# image.)

# (1) Build the credit-check-service app
docker build -t credit-check-service:latest creditcheckservice

# (2) Export the image from docker
docker save --output credit-check-service.tar credit-check-service:latest

# (3) Import it into k3s
sudo k3s ctr images import credit-check-service.tar

# (4) Deploy the service in kubernetes
kubectl apply -f creditcheckservice/creditcheckservice.yaml
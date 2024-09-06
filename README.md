# qep OTel Demo Instructions

## Pre-requisites
You will need an instance with the following installed and configured:
  * k3s (Kubernetes), 
  * helm (and the [splunk-otel-collector-chart](https://github.com/signalfx/splunk-otel-collector-chart/tree/main) added)

## Initial Steps
To begin the exercise you will need to:
* Get an EC2 instance or spin up a Splunk Show environment
* Clone this repo
* Make sure you have all the pre-requisites installed in your instance
* Run the setup scripts in order
```
cd qep
./1-docker-setup.sh
# Exit and ssh back to this instance
./2-remove-diab.sh
./3-upgrade-otel-and-deploy-app.sh
# Set the values from your Splunk Observability Cloud org
./4-deploy-creditcheckservice.sh
./5-deploy-creditprocessorservice.sh
./6-deploy-updated-paymentservice.sh
```

# Unrelated to this demo

## Next steps
You will now begin to implement what you need to for the proof of value, based on the customer requirements you received.

The service that you are working on is **creditcheckservice**. It sits between the **paymentservice** and the **creditprocessorservice**.

You will need to add auto-instrumentation to your service and redeploy it. Once you've made any changes to the code or configuration we've provided a script for you to use for that process:
```
./9-redeploy.sh
```

Once you have done that you will iterate making changes to configuration, code, etc. to be able to demonstrate your requirements.

There are more than one way to do this exercise. If you can think of multiple ways to achieve something, try to pick the simplest one, but be aware of the options. And note down any decisions you made.

When you wrap up you will record a max-20 minute demo/review:
* A 15 minute demo (tell-show-tell)
* A 5 minute explanation of some of the environment changes you made to make this demo happen
  * This doesn't need to cover everything; just cover a few things that you thought were interesting in the configuration process, or any interesting decisions you made.

## Tips (some very important to know)

* [Python](docs/python.md)
* [Instrumentation](docs/instrumentation.md)
* [Docker](docs/docker.md)
* [Kubernetes](docs/kubernetes.md)
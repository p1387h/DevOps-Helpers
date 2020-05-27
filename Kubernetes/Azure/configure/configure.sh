#!/bin/bash

function connect {
  # Make kubectl connect to the cluster by default in this shell
  echo "Getting the admin credentials for $CLUSTERNAME in $RESOURCE_GROUP"
  az aks get-credentials -n $CLUSTERNAME -g $RESOURCE_GROUP --file - --admin > kube.config
  export KUBECONFIG="./kube.config"
}

# Function for copying the kubectl configuration to the places it 
# is being referred to.
function copyConfig {
  cp ./kube.config ./istio/kube.config
  cp ./kube.config ./helloworld/kube.config
}

function configureDashboard {
  # Enable the dashboard.
  echo "Enabling the dashboard for the kubernetes-dashboard service account"
  kubectl apply -f ./dashboard/dashboard_adminuser.yaml
}

function configureIstio {
  # Make copy of configuration and replace the necessary strings 
  # inside it.
  echo "Replacing configuration entries"
  cp ./istio/istiooperator_configuration.yaml ./istio/istiooperator_configuration.temp.yaml
  sed -i -e 's/$LOADBALANCER_IP/'$LOADBALANCER_IP'/g' ./istio/istiooperator_configuration.temp.yaml
  sed -i -e 's/$IP_RESOURCEGROUP/'$IP_RESOURCEGROUP'/g' ./istio/istiooperator_configuration.temp.yaml

  # Create the namespaces for the gateways.
  kubectl apply -f ./istio/namespace_ingressgateway.yaml
  kubectl apply -f ./istio/namespace_egressgateway.yaml

  # Install istio.
  echo "Installing istio on the cluster"
  istioctl manifest apply \
    -f ./istio/istiooperator_configuration.temp.yaml

  # Label the created istio-system namespace in order to apply 
  # kubernetes network policies. Do the same for the kube-system 
  # namespace.
  kubectl label ns istio-system istio=system
  kubectl label ns kube-system ns=kube-system
  
  # Set the grafana username and password.
  echo "Setting grafana username and password"
  kubectl create secret generic grafana \
    -n istio-system \
    --from-literal username=$GRAFANA_USERNAME \
    --from-literal passphrase=$GRAFANA_PASSWORD
  kubectl label secret/grafana -n istio-system app=grafana

  # Set the kiali username and password.
  echo "Setting kiali username and password"
  kubectl create secret generic kiali \
    -n istio-system \
    --from-literal username=$KIALI_USERNAME \
    --from-literal passphrase=$KIALI_PASSWORD
  kubectl label secret/kiali -n istio-system app=kiali

  # Enforce mutual tls.
  echo "Enforcing mutual tls"
  kubectl apply -f ./istio/peerauthentication_mutualtls.yaml
}

function configureLogging {
  kubectl apply -f ./prometheus/container-azm-ms-agentconfig.yaml
}

if [ -z ${CLUSTERNAME+x} ]; then
  echo "CLUSTERNAME must be set as environment variable."
elif [ -z ${RESOURCE_GROUP+x} ]; then
  echo "RESOURCE_GROUP must be set as environment variable."
elif [ -z ${LOADBALANCER_IP+x} ]; then
  echo "LOADBALANCER_IP must be set as environment variable."
elif [ -z ${IP_RESOURCEGROUP+x} ]; then
  echo "IP_RESOURCEGROUP path must be set as environment variable."
elif [ -z ${KIALI_USERNAME+x} ]; then
  echo "KIALI_USERNAME must be set as environment variable."
elif [ -z ${KIALI_PASSWORD+x} ]; then
  echo "KIALI_PASSWORD must be set as environment variable."
elif [ -z ${GRAFANA_USERNAME+x} ]; then
  echo "GRAFANA_USERNAME must be set as environment variable."
elif [ -z ${GRAFANA_PASSWORD+x} ]; then
  echo "GRAFANA_PASSWORD must be set as environment variable."
else
  connect
  copyConfig
  configureDashboard
  configureIstio
  configureLogging
fi
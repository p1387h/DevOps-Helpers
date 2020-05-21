#!/bin/bash

function connect {
  # Make kubectl connect to the cluster by default in this shell
  echo "Getting the admin credentials for $CLUSTERNAME in $RESOURCE_GROUP"
  az aks get-credentials -n $CLUSTERNAME -g $RESOURCE_GROUP --file - --admin > kube.config
  export KUBECONFIG="./kube.config"
}

function configureDashboard {
  # Enable the dashboard.
  echo "Enabling the dashboard for the kubernetes-dashboard service account"
  kubectl apply -f ./dashboard/dashboard_adminuser.yaml
}

function configureIstio {
  # Install istio. Setting maps inside an array is not supported by istioctl, therefore this 
  # hacky method must be used:
  echo "Installing istio on the cluster"
  istioctl manifest apply \
    -f ./istio/istiooperator_configuration.yaml \
    --set components.ingressGateways[0].enabled=true \
    --set components.ingressGateways[0].k8s.service.loadBalancerIP=$LOADBALANCER_IP \
    --set components.ingressGateways[0].k8s.serviceAnnotations.service\\.beta\\.kubernetes\\.io/azure-load-balancer-resource-group=$IP_RESOURCEGROUP \
    --set components.ingressGateways[0].k8s.service.ports[0].name=http2 \
    --set components.ingressGateways[0].k8s.service.ports[0].port=80 \
    --set components.ingressGateways[0].k8s.service.ports[0].targetPort=80 \
    --set components.ingressGateways[0].k8s.service.ports[1].name=https \
    --set components.ingressGateways[0].k8s.service.ports[1].port=443

  # Set the kiali username and password.
  kubectl create secret generic kiali \
    -n istio-system \
    --from-literal username=$KIALI_USERNAME \
    --from-literal passphrase=$KIALI_PASSWORD
  kubectl label secret/kiali -n istio-system app=kiali
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
else
  connect
  configureDashboard
  configureIstio
  configureLogging
fi
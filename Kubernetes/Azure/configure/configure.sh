#!/bin/bash

if CLUSTERNAME="" ; then
  echo "CLUSTERNAME must be set as environment variable."
elif RESOURCE_GROUP="" ; then
  echo "CLUSTERNAME must be set as environment variable."
elif LOADBALANCER_IP="" ; then
  echo "CLUSTERNAME must be set as environment variable."
elif KIALI_USERNAME="" ; then
  echo "KIALI_USERNAME must be set as environment variable."
elif KIALI_PASSWORD="" ; then
  echo "KIALI_PASSWORD must be set as environment variable."
else
  # Make kubectl connect to the cluster by default in this shell
  echo "Getting the admin credentials for $CLUSTERNAME in $RESOURCE_GROUP"
  az aks get-credentials -n $CLUSTERNAME -g $RESOURCE_GROUP --file - --admin > kube.config
  export KUBECONFIG="./kube.config"

  # Enable the dashboard.
  echo "Enabling the dashboard for the kubernetes-dashboard service account"
  kubectl apply -f ./dashboard/dashboard_adminuser.yaml

  # Install istio. Setting maps inside an array is not supported by istioctl, therefore this 
  # hacky method must be used:
  echo "Installing istio on the cluster"
  istioctl manifest apply \
    -f ./istio/istiooperator_configuration.yaml \
    --set components.ingressGateways[0].enabled=true \
    --set components.ingressGateways[0].k8s.service.loadBalancerIP=$LOADBALANCER_IP \
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
fi
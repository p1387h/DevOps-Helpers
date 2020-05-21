#!/bin/bash

if [ -z ${KUBECONFIG+x} ]; then
  echo "KUBECONFIG path must be set as environment variable."
elif [ -z ${LOADBALANCER_IP+x} ]; then
  echo "LOADBALANCER_IP must be set as environment variable."
elif [ -z ${IP_RESOURCEGROUP+x} ]; then
  echo "IP_RESOURCEGROUP must be set as environment variable."
else
  istioctl manifest generate > istio_manifest_comparison_default.yaml

  # Setting maps inside an array is not supported by istioctl, therefore this hacky method must be used:
  istioctl manifest generate \
    -f ./istio/istiooperator_configuration.yaml \
    --set components.ingressGateways[0].enabled=true \
    --set components.ingressGateways[0].k8s.service.loadBalancerIP=$LOADBALANCER_IP \
    --set components.ingressGateways[0].k8s.serviceAnnotations.service\\.beta\\.kubernetes\\.io/azure-load-balancer-resource-group=$IP_RESOURCEGROUP \
    --set components.ingressGateways[0].k8s.service.ports[0].name=http2 \
    --set components.ingressGateways[0].k8s.service.ports[0].port=80 \
    --set components.ingressGateways[0].k8s.service.ports[0].targetPort=80 \
    --set components.ingressGateways[0].k8s.service.ports[1].name=https \
    --set components.ingressGateways[0].k8s.service.ports[1].port=443 \
    > istio_manifest_comparison_default_custom.yaml

  istioctl manifest diff ./istio_manifest_comparison_default.yaml ./istio_manifest_comparison_default_custom.yaml
fi
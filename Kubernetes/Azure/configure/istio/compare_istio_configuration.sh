#!/bin/bash

if [ -z ${KUBECONFIG+x} ]; then
  echo "KUBECONFIG path must be set as environment variable."
elif [ -z ${LOADBALANCER_IP+x} ]; then
  echo "LOADBALANCER_IP must be set as environment variable."
elif [ -z ${IP_RESOURCEGROUP+x} ]; then
  echo "IP_RESOURCEGROUP must be set as environment variable."
else
  istioctl manifest generate > istio_manifest_comparison_default.yaml
  istioctl manifest generate -f ./istiooperator_configuration.yaml > istio_manifest_comparison_default_custom.yaml
  istioctl manifest diff ./istio_manifest_comparison_default.yaml ./istio_manifest_comparison_default_custom.yaml
fi
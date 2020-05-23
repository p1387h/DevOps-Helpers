### Install all default components
Replace the $IP_RESOURCEGROUP as well as the $LOADBALANCER_IP inside the istiooperator_configuration.yaml. This is due to the used parser in the installer not allowing slashes and backslashes as names inside the annotation block. Every other value can be set, but the needed "service.beta.kubernetes.io/azure-load-balancer-resource-group" does ont work inline.

```sh
source ./configure.sh
```

### Helper script for comparing configuration files
```sh
source ./compare_istio_configuration.sh
```
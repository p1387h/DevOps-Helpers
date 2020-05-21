### Requirements:
Istio requires at least 4GB of RAM for starting all services successfully. Since a fixed amount is [reserved for system functionalities](https://docs.microsoft.com/en-us/azure/aks/concepts-clusters-workloads#resource-reservations) vms with less or equal than 4GB of ram can not be used (i.e. Standard_B2s).

### Step 1: AKS Preparation
https://docs.microsoft.com/en-us/azure/aks/servicemesh-istio-install?pivots=client-operating-system-linux

Change the username and password (as base64) inside the kiali.yaml file and execute the following command to make them available in the cluster:

```sh
kubectl apply -f secret_kiali.yaml
```

[Microsoft example](https://docs.microsoft.com/en-us/azure/aks/servicemesh-istio-install?pivots=client-operating-system-linux#install-the-istio-components-on-aks):
```sh
KIALI_USERNAME=$(echo -n "kiali" | base64)
KIALI_PASSPHRASE=$(echo -n "REPLACE_WITH_YOUR_SECURE_PASSWORD" | base64)

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: kiali
  namespace: istio-system
  labels:
    app: kiali
type: Opaque
data:
  username: $KIALI_USERNAME
  passphrase: $KIALI_PASSPHRASE
EOF
```

### Step 2:
Change the ip of the istio ingress gateway in the configuration.yaml file and install Istio via the following command. The public ip of the cluster must be explicitly set due to istio otherwise creating a new dynamic one.

```sh
istioctl manifest apply --set profile=default -f ./istiooperator_configuration.yaml
```

##### Notes: External services
Do not allow the sidecars to send requests to external sources unless they are defined in the service mesh (must be part of the original installation):
https://istio.io/docs/tasks/traffic-management/egress/egress-control/#envoy-passthrough-to-external-services
Alternatively restrict the traffic later on:
https://istio.io/docs/tasks/traffic-management/egress/egress-control/#change-to-the-blocking-by-default-policy

##### Notes: Configuration
Configure the installation: https://istio.io/docs/setup/install/istioctl/#install-from-external-charts

The documentation for the istio configuration files can be improved. For the general reader the actual structure of the needed file is not directly evident. A possible format can be produced by dumping the "demo" configuration into a yaml file:

```sh
istioctl profile dump demo > demo.yaml
```

Values can be overwritten via the following syntax:

```sh
istioctl manifest apply --set addonComponents.kiali enabled=false --set...
```

Differences between manifests can be generated via the following command:

```sh
istioctl manifest generate > default.yaml
istioctl manifest generate -f ./istiooperator_configuration.yaml > default_comparison.yaml
istioctl manifest diff ./default.yaml ./default_comparison.yaml
```
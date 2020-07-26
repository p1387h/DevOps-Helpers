### Requirements:
Istio requires at least 4GB of RAM for starting all services successfully. Since a fixed amount is [reserved for system functionalities](https://docs.microsoft.com/en-us/azure/aks/concepts-clusters-workloads#resource-reservations) vms with less or equal than 4GB of ram can not be used (i.e. Standard_B2s).

### Step 1: AKS Preparation
https://docs.microsoft.com/en-us/azure/aks/servicemesh-istio-install?pivots=client-operating-system-linux

Change the usernames and passwords (as base64) inside the kiali.yaml and grafana.yaml files and execute the following command to make them available in the cluster:

```sh
kubectl apply -f secret_grafana.yaml
kubectl apply -f secret_kiali.yaml
```

[Microsoft example](https://docs.microsoft.com/en-us/azure/aks/servicemesh-istio-install?pivots=client-operating-system-linux#install-the-istio-components-on-aks):
```sh
GRAFANA_USERNAME=$(echo -n "grafana" | base64)
GRAFANA_PASSPHRASE=$(echo -n "REPLACE_WITH_YOUR_SECURE_PASSWORD" | base64)

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: grafana
  namespace: istio-system
  labels:
    app: grafana
type: Opaque
data:
  username: $GRAFANA_USERNAME
  passphrase: $GRAFANA_PASSPHRASE
EOF

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

##### Notes: Gateway
The gateway for each resource must be placed inside the same namespace that the gateway workload instance (the ingressgateway pod) resides in. This is due to the selector being restricted to one single namespace.

https://istio.io/docs/reference/config/networking/gateway/#Gateway

### Step 3:
Enforce the usage of mutual tls in the whole mesh by applying the following configuration file to the cluster. Make sure that the namespace of the peerauthentication resource matches the istio installation namespace (i.e. istio-system).

```sh
kubectl apply -f ./peerauthentication_mutualtls.yaml
```

https://istio.io/docs/reference/config/security/peer_authentication/#PeerAuthentication

### Step 4:
Use VirtualServices and Gateways for routing traffic to (VirtualService) and from (Gateway) the Deployments. Gateways act as a load balancer configuration for the istio gateway controller. Make sure to limit the configuration to the corresponding namespaces via the 'exportTo: "."' flags. See the notes for when **not** to include the flag.

##### Notes: App/Version
**Always** use the following labels for all Deployments and Pods as they are needed for visualing the mesh and required for advanced routing via Destinationrules:
- app
- version

https://istio.io/latest/docs/ops/deployment/requirements/
> Deployments with app and version labels: We recommend adding an explicit app label and version label to deployments. Add the labels to the deployment specification of pods deployed using the Kubernetes Deployment. The app and version labels add contextual information to the metrics and telemetry Istio collects.
> The app label: Each deployment specification should have a distinct app label with a meaningful value. The app label is used to add contextual information in distributed tracing.
> The version label: This label indicates the version of the application corresponding to the particular deployment.

##### Notes: ExportTo
It is possible for VirtualServices to overlap one another. Limit their visibility in order to prevent these errors.
https://istio.io/latest/docs/reference/config/analysis/ist0109/

Do **not** add the flag to VirtualServices that are part of the ingress flow if the istio ingress gateway lies in another namespace since the configuration must be visible across the namespaces. See the "host" configuration part of the following server configuration:
https://istio.io/latest/docs/reference/config/networking/gateway/#Server
> NOTE: Only virtual services exported to the gateway’s namespace (e.g., exportTo value of *) can be referenced. Private configurations (e.g., exportTo set to .) will not be available. Refer to the exportTo setting in VirtualService, DestinationRule, and ServiceEntry configurations for details.

Make sure to **always** use the 'exportTo: "."' flag when using ServiceEntries since they generally must not be shared across namespaces.
https://istio.io/latest/docs/reference/config/networking/service-entry/
> The following example demonstrates the use of a dedicated egress gateway through which all external service traffic is forwarded. The ‘exportTo’ field allows for control over the visibility of a service declaration to other namespaces in the mesh. By default, a service is exported to all namespaces. The following example restricts the visibility to the current namespace, represented by “.”, so that it cannot be used by other namespaces.

### Step 5: External Services
External services must be manually enabled in order to be accessed by pods if the "outboundTrafficPolicy" is set to "REGISTRY_ONLY". Requests are then routed to the egress gateway where they are forwarded to the external host as shown below:

<p align="center">
  <img width="511" height="352" src="https://github.com/p1387h/DevOps-Helpers/blob/master/Kubernetes/Azure/configure/istio/images/Flow.png">
</p>
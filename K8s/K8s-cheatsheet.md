# kubectl Commands Cheat Sheet

## kubectl Commands

### Basic Commands

| Command | Description |
| --- | --- |
| `kubectl version` | Display the version of kubectl and Kubernetes API server in use. Helps ensure compatibility. |
| `kubectl config view` | View the current kubeconfig settings, including cluster, user, and context configurations. |
| `kubectl cluster-info` | Show details about the current Kubernetes cluster, such as master node and DNS info. |
| `kubectl get nodes` | List all the nodes (worker and master) in the cluster. Nodes are the machines where workloads run. |
| `kubectl get namespaces` | Display all namespaces in the cluster. Namespaces are used to separate resources within the cluster. |

### Working with Pods

| Command | Description |
| --- | --- |
| `kubectl get pods` | List all the pods running in the current namespace. Pods are the smallest deployable units in Kubernetes. |
| `kubectl get pods -A` | List all the pods across all namespaces in the cluster. |
| `kubectl get pod <pod-name> -o wide` | Get detailed information about a specific pod, including the node it’s running on and IP address. |
| `kubectl describe pod <pod-name>` | Display in-depth information about the pod, including events and resource usage. Useful for troubleshooting. |
| `kubectl logs <pod-name>` | Fetch and view the logs of a pod's containers. Helps in debugging issues within a container. |
| `kubectl exec -it <pod-name> -- bash` | Open an interactive terminal to a running container within the pod. Helpful for debugging or running commands inside the container. |
| `kubectl delete pod <pod-name>` | Delete a specific pod. The pod will be terminated, and if part of a deployment, a new one will be created. |
| `kubectl port-forward <pod-name> 8080:80` | Forward a port on your local machine to a port on a pod, enabling access to services inside the pod from your local machine. |

### Deployments

| Command | Description |
| --- | --- |
| `kubectl get deployments` | List all deployments in the current namespace. Deployments manage replicas of pods and ensure the desired state. |
| `kubectl describe deployment <deployment-name>` | Show detailed information about a specific deployment, including its replica count, strategies, and events. |
| `kubectl scale deployment <deployment-name> --replicas=<count>` | Adjust the number of pod replicas in a deployment. For example, scaling up to handle more traffic. |
| `kubectl rollout restart deployment <deployment-name>` | Restart all pods in a deployment. This can be useful for applying updates. |
| `kubectl delete deployment <deployment-name>` | Delete a specific deployment. This will also terminate the associated pods. |

### Services

| Command | Description |
| --- | --- |
| `kubectl get svc` | List all services in the current namespace. Services expose pods to the network, balancing traffic. |
| `kubectl describe svc <service-name>` | Show detailed information about a specific service, including its endpoints and ports. |
| `kubectl expose deployment <deployment-name> --type=LoadBalancer --port=80 --target-port=8080` | Expose a deployment as a service. This allows pods in the deployment to receive traffic on the specified port. |
| `kubectl delete svc <service-name>` | Delete a specific service. The associated endpoints will no longer be accessible. |

### ConfigMaps & Secrets

| Command | Description |
| --- | --- |
| `kubectl get configmap` | List all ConfigMaps in the current namespace. ConfigMaps store non-sensitive configuration data for use by pods. |
| `kubectl describe configmap <configmap-name>` | Display detailed information about a specific ConfigMap, including its key-value pairs. |
| `kubectl create configmap <name> --from-literal=<key>=<value>` | Create a new ConfigMap with a key-value pair directly from the command line. |
| `kubectl delete configmap <configmap-name>` | Delete a specific ConfigMap, removing its configuration from the namespace. |
| `kubectl get secret` | List all secrets in the current namespace. Secrets store sensitive data like passwords and tokens securely. |
| `kubectl describe secret <secret-name>` | Show detailed information about a secret, though the values are typically base64-encoded. |
| `kubectl create secret generic <name> --from-literal=<key>=<value>` | Create a generic secret with key-value pairs directly from the command line. |
| `kubectl delete secret <secret-name>` | Delete a specific secret, removing its sensitive data from the namespace. |

### Namespaces

| Command | Description |
| --- | --- |
| `kubectl get namespaces` | List all namespaces in the cluster. Namespaces allow you to logically separate resources. |
| `kubectl create namespace <name>` | Create a new namespace for isolating resources or teams. |
| `kubectl delete namespace <name>` | Delete a namespace and all resources within it. Use with caution. |
| `kubectl config set-context --current --namespace=<name>` | Set a default namespace for your current kubectl context, avoiding the need to specify `--namespace` for every command. |

### Persistent Volumes & Claims

| Command | Description |
| --- | --- |
| `kubectl get pv` | List all Persistent Volumes (PVs) in the cluster. PVs represent physical storage in the cluster. |
| `kubectl get pvc` | List all Persistent Volume Claims (PVCs) in the current namespace. PVCs request storage resources from PVs. |
| `kubectl describe pv <pv-name>` | Show detailed information about a specific Persistent Volume, including capacity and access modes. |
| `kubectl describe pvc <pvc-name>` | Display detailed information about a specific Persistent Volume Claim, including its bound volume. |
| `kubectl delete pvc <pvc-name>` | Delete a specific Persistent Volume Claim, freeing the associated storage resource. |

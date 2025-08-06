# Helm chart installation of a PostgreSQL cluster

To get started, try setting up your own Kubernetes cluster.

This is done using [WSL](https://canonical-ubuntu-wsl.readthedocs-hosted.com/en/latest/guides/install-ubuntu-wsl2/) locally on your own PC, and installing [Minikube](https://medium.com/cypik/installing-minikube-on-ubuntu-22-04-lts-77f5abaf3d39) to get your own 1-node Kubernetes cluster.

We'll be using [CNPG](https://cloudnative-pg.io/charts/) and installing the cluster using a [Helm chart](https://helm.sh/docs/intro/install/).

## 1. Prerequisites

Go through the **Installation Steps** on the [Minikube](https://medium.com/cypik/installing-minikube-on-ubuntu-22-04-lts-77f5abaf3d39) website, steps **1 - 6** in the guide.

Kubernetes Cluster: Ensure you have a Kubernetes cluster up and running.
Helm: Make sure Helm is installed on your system. If not, you can install it using:

~~~bash
curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
~~~

Cloud Native PostgreSQL Operator: Before using the *cnpg/cluster* Helm chart, the CNPG operator must be installed in your Kubernetes cluster.

## 2. Add the CNPG Helm Repository

You need to add the Helm repository that contains the CNPG chart.

~~~bash
helm repo add cnpg https://cloudnative-pg.github.io/charts
~~~

Update the repo.

~~~bash
helm repo update
~~~

## 3. Install the Cloud Native PostgreSQL Operator

Before deploying a PostgreSQL cluster, you need to install the CNPG operator, which is in its own namespace.

> Note: When working with CNPG in VKS, the CNPG Operator should already be present for us to use.

~~~bash
helm upgrade --install cnpg \
  --namespace cnpg-system \
  --create-namespace \
  cnpg/cloudnative-pg
~~~

## 4. Install a PostgreSQL Cluster

Once the operator is installed, you can use the *cnpg/cluster* chart to deploy a PostgreSQL cluster. Here's a basic example of how to install it in your own namespace.

Create your namespace.

~~~bash
kubectl create namespace <your-namespace>
~~~

Install a default PostgreSQL cluster.

~~~bash
helm install my-postgresql-cluster cnpg/cluster --namespace <your-namespace>
~~~

This will create a PostgreSQL cluster with default settings.

## 5. Customizing the Cluster

You can customize your PostgreSQL cluster by passing values to the Helm chart. You can either create a custom values.yaml file or pass values directly via the command line.

Example values.yaml:

~~~yaml
postgresql:
  image:
    tag: "15.3"   # Specify PostgreSQL version
  resources:
    requests:
      cpu: "500m"
      memory: "512Mi"
    limits:
      cpu: "1"
      memory: "1Gi"
replicaCount: 3  # Number of replicas in the cluster
~~~

> Note: You can also see the cluster.yaml file in the repo for a full installation.

The 'values.yaml' file is the default, similar to the document called 'cluster.yaml' in the repo.

To get the default values out into a yaml file:

~~~bash
helm show values cnpg/cluster > values.yaml
~~~

Installing using this file:

~~~bash
helm install my-postgresql-cluster cnpg/cluster --namespace <your-namespace> -f values.yaml
~~~

If you are not installing using the default values.yaml file, but using your cluster.yaml file, you should add your own configmap.yaml and secret.yaml first.

Add the files by running these commands, and you will need to change the namespace value inside the files to your namespace name. They currently have **'dbmgmt'** as the namespace:

~~~bash
helm install my-postgresql-cluster cnpg/cluster --namespace <your-namespace> -f cluster.yaml
~~~

~~~bash
kubectl apply --namespace <your-namespace> -f configmap.yaml
~~~

~~~bash
kubectl apply --namespace <your-namespace> -f secret.yaml
~~~

Or pass values directly to an existing setup.

~~~bash
helm install my-postgresql-cluster cnpg/cluster --namespace <your-namespace> -f cluster.yaml --set replicaCount=3 --set postgresql.image.tag="15.3"
~~~

## 6. Managing the Cluster

Upgrade the Cluster: To upgrade your cluster configuration or update the Helm chart.

~~~bash
helm upgrade my-postgresql-cluster cnpg/cluster --namespace <your-namespace> -f <your cluster/values.yaml>
~~~

## Roll back to a previous version of the Helm release

~~~bash
helm rollback my-postgresql-cluster <revision-number> --namespace <your-namespace>
~~~

> Note: If you misspell your chosen cluster name 'my-postgresql-cluster' or 'your-namespace', Helm will just install another cluster.

Check the Status: To check the status of your PostgreSQL cluster.

~~~bash
kubectl get pods -l app.kubernetes.io/instance=my-postgresql-cluster --namespace <your-namespace>
~~~

Uninstall the Cluster: To remove the PostgreSQL cluster.

~~~bash
helm uninstall my-postgresql-cluster --namespace <your-namespace>
~~~

> Note: You can use "delete" as well for removing, instead of uninstall.

## 7. Accessing the Database

Once your PostgreSQL cluster is up, you can access it via a Kubernetes service created by the Helm chart. Use kubectl port-forward or a service endpoint to connect to the database using a PostgreSQL client like psql.

~~~bash
kubectl port-forward svc/my-postgresql-cluster 5432:5432 --namespace <your-namespace>
~~~

Getting your cluster superuser extracted.

~~~bash
kubectl get secret 'yourclustername'-superuser -n 'your-namespace' -o jsonpath="{.data.password}" | base64 --decode |
~~~

Access the PostgreSQL database.

~~~bash
psql -h localhost -U postgres
~~~

If you have the CNPG plugin installed, you can access the databases with.

~~~bash
k cnpg psql <cluster-name> -n <your-namespace>
~~~

Access the PostgreSQL instance if needing to look at postgresql.conf or other things.

~~~bash
kubectl exec -it <pod-name> -n <your-namespace> -- bash
~~~

## 8. Monitoring and Backups

The CNPG operator also provides features for monitoring, backup, and restore. These can be configured via the Helm chart or directly using Kubernetes manifests.

## 9. Install Prometheus Operator CRDs

Install Prometheus Operator using Helm.

Help to set up [CNPG Grafana dashboard site](https://cloudnative-pg.io/documentation/current/quickstart/).

~~~bash
helm repo add prometheus-community \
  https://prometheus-community.github.io/helm-charts

helm upgrade --install \
  -f https://raw.githubusercontent.com/cloudnative-pg/cloudnative-pg/main/docs/src/samples/monitoring/kube-stack-config.yaml \
  prometheus-community \
  prometheus-community/kube-prometheus-stack

helm repo update
~~~

e.g.

~~~bash
kubectl get crds
NAME                                        CREATED AT
...
alertmanagers.monitoring.coreos.com         <timestamp>
...
prometheuses.monitoring.coreos.com          <timestamp>
prometheusrules.monitoring.coreos.com       <timestamp>
...
~~~

e.g.

~~~bash
kubectl get svc
NAME                                      TYPE        PORT(S)
...                                       ...         ...
prometheus-community-grafana              ClusterIP   80/TCP
prometheus-community-kube-alertmanager    ClusterIP   9093/TCP
prometheus-community-kube-operator        ClusterIP   443/TCP
prometheus-community-kube-prometheus      ClusterIP   9090/TCP
~~~

Grafana Dashboard

~~~bash
kubectl port-forward svc/prometheus-community-grafana 3000:80
~~~

Access Grafana locally at <http://localhost:3000/> providing the credentials **admin** as username, **prom-operator** as password (defined in kube-stack-config.yaml).

You can import a dashboard using the **grafana-dashboard.json** also found in the repo, or on the [CNPG Grafana dashboard site](https://cloudnative-pg.io/documentation/current/quickstart/) link.

## 10. Setting up ArgoCD operator

Installation

~~~bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
~~~

Port-forward

~~~bash
kubectl port-forward svc/argocd-server -n argocd 8080:443 > /dev/null &
~~~

CLI version of ArgoCD

~~~bash
Head to home directory:
curl -sSL -o ~/argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
chmod +x ~/argocd
mkdir -p ~/.local/bin
mv ~/argocd ~/.local/bin/argocd
sudo chmod +x /usr/local/bin/argocd
echo 'export PATH=$HOME/.local/bin:$PATH' >> ~/.bashrc
source ~/.bashrc
argocd version
~~~

Extract **admin** password

~~~bash
kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d && echo
~~~

Adding Application to Argo

~~~bash
argocd app create my-app \
  --repo https://github.com/smoorth/k8s.git \
  --path /home/stemo/k8s/helm-azure/cnpg-umbrella/docs/test/mypg.yaml \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace test \
  --sync-policy automated
~~~

## 11. Advanced Configurations

The *cnpg/cluster* Helm chart supports various advanced configurations such as:

- Custom storage classes
- TLS encryption
- External connections
- Integration with monitoring systems like Prometheus
- Setting up high availability (HA) configurations.

## 12. Documentation and Help

For more detailed information and advanced use cases, refer to the official Cloud Native PostgreSQL documentation.

**[Cloud Native PostgreSQL Documentation](https://cloudnative-pg.io/documentation/1.24/)**

This should give you a solid foundation to start working with the *cnpg/cluster* Helm chart to deploy and manage PostgreSQL clusters on Kubernetes.

## 12. Common / Nice to know commands

Ongoing list of commands that might be nice to know when managing the Kubernetes PostgreSQL cluster.

For more, see the [[Helm]] and [[K8s-cheatsheet]].

| Description | Commands|
|---|---|
| Start / stop your local Minikube environment | minikube start/stop |
| See your current pods in your own namespace | kubectl get pods --namespace 'your-namespace' |
| --- See extended info of your current pods in your own namespace | kubectl get pods --namespace 'your-namespace' -o wide |
| --- Add "-w" to follow the progress when deploying | kubectl get pods --namespace 'your-namespace' -w |
| --- similar to add "--watch" to follow the progress when deploying | kubectl get pods --namespace 'your-namespace' --watch |
| See everything in your current namespace, with extended info | kubectl get all --namespace 'your-namespace' -o wide |
| --- instead of '--namespace' you can use | -n 'your-namespace' |
| See your current services (svc) in your own namespace | kubectl get svc -n 'your-namespace' |
| View the status of the CNPG cluster | kubectl get cluster |
| --- more detailed information | kubectl describe cluster my-cluster |
| View logs from PostgreSQL pods | kubectl logs 'pod-name' -n 'your-namespace' |
| Scale up or down the number of PostgreSQL instances, e.g., to 5 instances | kubectl patch cluster my-cluster --type='merge' -p '{"spec":{"instances":5}}' |
| Perform a backup: CNPG allows using pg_basebackup or snapshots | kubectl apply -f backup.yaml -n 'your-namespace' |
| Restore from a backup | kubectl apply -f restore.yaml -n 'your-namespace' |
| Delete a resource from a yaml file | kubectl delete -f yourfilename.yaml -n 'your-namespace' |
| Resource usage (CPU, memory) | kubectl top pod -l cnpg.io/cluster='my-cluster-name' -n 'your-namespace' |
| --- node resource usage | kubectl top nodes |
| Check events in the namespace | kubectl get events -n 'your-namespace' |
| CNPG logs: View logs from the CNPG controller itself | kubectl logs -l app.kubernetes.io/name=cloudnative-pg |
| Exec / jump into PostgreSQL container | kubectl exec -it 'pod-name' -- psql -U 'username' -d 'database' |
| --- e.g., using superuser Postgres | kubectl exec -it 'pod-name' -- psql -U postgres -d postgres |
| Inspect persistent volume claims (PVCs) | kubectl get pvc -l cnpg.io/cluster='my-cluster-name' |
| --- inspect persistent volumes (PVs) | kubectl get pv |
| List Helm deployments | helm list -A |
| Get the Helm chart of a default cnpg/cluster into a yaml file | helm show values cnpg/cluster > values.yaml |
| Port forward your cluster to localhost | kubectl port-forward svc/'my-cluster-name' 5432:5432 -n 'your-namespace' |
| --- Add '&' at the end to have it run in the background | kubectl port-forward svc/'my-cluster-name' 5432:5432 -n 'your-namespace' & |
| --- Add '> /dev/null' before the '&' at the end if you do not what to see connections in the terminal | kubectl port-forward svc/'my-cluster-name' 5432:5432 -n 'your-namespace' > /dev/null & |
| --- Access and exit again, write 'jobs' and 'fg %n', n being the job's id. When moved to the prompt again, click 'ctrl+c' | 'jobs' -> 'fg %n' -> 'ctrl+c' |
| Access logs from your cluster | kubectl logs -f -l cnpg.io/cluster='my-cluster-name' -n 'your-namespace' --max-log-requests 10 |
| Get your cluster with the label values | kubectl get pod --show-labels -n 'your-namespace' |
| Get your namespace secrets | kubectl get secrets -n 'your-namespace' |
| Tired of adding '-n your-namespace' in the commandline, then set the context like so | kubectl config set-context --current --namespace='your-namespace' |
| View the current namespace context | kubectl config view --minify \| grep namespace |
| Getting manifest from current running cluster | helm get manifest 'releasename' -n 'your-namespace' > '/path/to/your/folder/cluster-manifest.yaml' |
| Change between kubeconfigs | export KUBECONFIG=~/.kube/config |
| See URL of nodeport usage, through minikube | minikube service 'name-of-service' --url -n your-namespace' |
| Get a environment secret, e.g. superuser, decoded from base63 | kubectl get secret 'yourclustername'-superuser -n 'your-namespace' -o jsonpath="{.data.password}" \| base64 --decode |

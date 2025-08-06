# Helm Commands Cheat Sheet

## Helm Commands

### Basic Helm Commands

| Command | Description |
| --- | --- |
| `helm version` | Display the Helm client and server (Tiller) versions in use. |
| `helm repo add <repo-name> <repo-url>` | Add a new Helm chart repository, allowing you to install charts from it. |
| `helm repo update` | Fetch the latest available charts from all configured repositories. |
| `helm search repo <chart>` | Search for a specific chart within the repositories you’ve added. |
| `helm show values cnpg/cluster > values.yaml` | Adds a values.yaml file to you repo, showing the current configuration on a cnpg/cluster install |

### Installing and Upgrading Releases

| Command | Description |
| --- | --- |
| `helm install <release-name> <chart>` | Install a Helm chart with a specific release name. This deploys the application to your Kubernetes cluster. |
| `helm install <release-name> <chart> --namespace <namespace>` | Install a chart into a specific namespace. Helm will create the namespace if it doesn’t exist. |
| `helm upgrade <release-name> <chart>` | Upgrade an existing Helm release to a new chart version or apply changes to its configuration. |
| `helm upgrade --install <release-name> <chart>` | Install a release if it doesn’t already exist, or upgrade it if it does. This is useful for CI/CD workflows. |
| `helm rollback <release-name> <revision>` | Roll back a Helm release to a previous revision. Useful if a new deployment introduces bugs. |

### Releases Management

| Command | Description |
| --- | --- |
| `helm list` | List all installed Helm releases in the current namespace. |
| `helm list -A` | List all Helm releases across all namespaces. |
| `helm status <release-name>` | Display the current status of a specific release, including its resources and revision history. |
| `helm uninstall <release-name>` | Uninstall a Helm release and clean up associated resources. |

### Working with Values

| Command | Description |
| --- | --- |
| `helm get values <release-name>` | Retrieve the configuration values currently applied to a specific release. |
| `helm get values <release-name> -o yaml` | Get the values for a release in YAML format, which can be easily edited. |
| `helm upgrade <release-name> <chart> --set <key>=<value>` | Override specific configuration values when upgrading a release. Useful for one-off changes. |
| `helm upgrade <release-name> <chart> -f values.yaml` | Apply configuration from a custom values file when upgrading a release. |

### Debugging and Troubleshooting

| Command | Description |
| --- | --- |
| `helm get all <release-name>` | Retrieve all information about a specific release, including manifest, values, and notes. |
| `helm get manifest <release-name>` | Get the Kubernetes resource manifest for a specific release. |
| `helm history <release-name>` | Show a history of revisions for a specific release, helpful for auditing changes. |
| `helm test <release-name>` | Run defined tests for a Helm release to verify its functionality. |

### Helm Repositories

| Command | Description |
| --- | --- |
| `helm repo list` | List all currently added Helm repositories. |
| `helm repo remove <repo-name>` | Remove a Helm repository, which will no longer be available for searches or installations. |
| `helm search hub <keyword>` | Search for a chart in the Helm Hub, a central repository of community-maintained charts. |

### Packaging and Chart Development

| Command | Description |
| --- | --- |
| `helm create <chart-name>` | Create a new Helm chart directory structure, complete with sample files. Useful for developing your own charts. |
| `helm lint` | Run a lint check on a chart to ensure it is well-formed and follows best practices. |
| `helm package <chart-directory>` | Package a Helm chart directory into a `.tgz` archive, making it ready for distribution. |
| `helm push <chart.tgz> <repo>` | Push a packaged chart to a Helm repository. This is useful for sharing charts with others. |
| `helm dependency update` | Update chart dependencies by downloading the latest versions specified in `Chart.yaml`. |

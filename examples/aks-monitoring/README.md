# AKS Monitoring

Follow the steps below to install AKS with Monitoring, and deploy Linkerd as a workload to produce metrics/logs etc.

## Set Environment Variables

Create the following environment variables so Terraform can connect to Azure:

- ARM_TENANT_ID
- ARM_SUBSCRIPTION_ID
- ARM_CLIENT_ID
- ARM_CLIENT_SECRET

Typically you would dot source (load) these values from a secure file, eg:

```powershell
. $env:HOME/.azdev.ps1
```

Environment variables should also be created for sensitive values like the AKS Service Principle values:

```bash
# Bash
export TF_VAR_kubernetes_client_id="<MyAzureSpClientId>"
export TF_VAR_kubernetes_client_secret="<MyAzureSpClientSecret>"

# [Optional] Reuse current ARM env vars
# Load standard env vars for Azure/TF
source ~/.azdev
export TF_VAR_kubernetes_client_id=$ARM_CLIENT_ID
export TF_VAR_kubernetes_client_secret=$ARM_CLIENT_SECRET
# Show env vars
env | grep -E "ARM|TF_VAR"
```

```powershell
# PowerShell
$env:TF_VAR_kubernetes_client_id = "<MyAzureSpClientId>"
$env:TF_VAR_kubernetes_client_secret = "<MyAzureSpClientSecret>"

# [Optional] Reuse current ARM env vars
# Load standard env vars for Azure/TF
. $env:HOME/.azdev.ps1
$env:TF_VAR_kubernetes_client_id = $env:ARM_CLIENT_ID
$env:TF_VAR_kubernetes_client_secret = $env:ARM_CLIENT_SECRET
# Show env vars
gci env:ARM*; gci env:TF_VAR*

```

## Install AKS with Terraform

```powershell
# Navigate to correct example folder
cd ./examples/aks-monitoring/

# Run Terraform
terraform init
terraform plan
../../scripts/Invoke-Terraform.ps1 -Command "apply"


# Get the access credentials for the Kubernetes cluster
# Creds are merged into your current console session, eg:
# Merged "artesting123-mon" as current context in ~/.kube/config
az aks get-credentials --resource-group "artesting123-mon-resources-rg" --name "artesting123-mon"

# Access the Kubernetes web dashboard in Azure Kubernetes Service (AKS)
https://docs.microsoft.com/en-us/azure/aks/kubernetes-dashboard

# Start the Kubernetes dashboard
az aks browse --resource-group "artesting123-mon-resources-rg" --name "artesting123-mon"

# You may need to create a ClusterRoleBinding to access the Web GUI properly
kubectl create clusterrolebinding kubernetes-dashboard --clusterrole=cluster-admin --serviceaccount=kube-system:kubernetes-dashboard
```

## Install Linkerd

```powershell
# https://linkerd.io/2/getting-started/

# Check context
kubectl config get-contexts
kubectl config current-context

# View nodes
kubectl get nodes

# View namespaces
kubectl get ns

# Install emojivoto app (with known bug when you click donut emoji)
curl https://run.linkerd.io/emojivoto.yml | kubectl apply -f -

# Install linkerd
linkerd check --pre
curl -sL https://run.linkerd.io/install | sh
export PATH=$PATH:$HOME/.linkerd2/bin
linkerd version
linkerd install | kubectl apply -f -

# Check linkerd status - check linkerd namespace in k8s GUI
linkerd check

# View linkerd dashboard
linkerd dashboard
(Ctrl + C)
bg

# Inject linkerd stuff
curl https://run.linkerd.io/emojivoto.yml | linkerd inject - | kubectl apply -f -

# Monitor emojivoto namespace in k8s GUI to view rollout of linkerd sidecar containers per pod
start http://127.0.0.1:8001/#!/overview?namespace=emojivoto

# Monitor emojivoto namespace in linkerd GUI to view success rates
start http://localhost:50750/namespaces/emojivoto

# Grafana dashboard
start http://localhost:50750/grafana

# Misc commands
linkerd -n emojivoto stat deploy
linkerd -n emojivoto tap deploy/web
```

## Destroy

../../scripts/Invoke-Terraform.ps1 -Command "destroy"

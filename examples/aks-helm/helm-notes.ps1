# Install Binary Repository on AKS
throw "do not run whole script; F8 sections as required"

#region Kubectl
# Get AKS k8s creds
az aks get-credentials --resource-group <ResourceGroupName> --name <AksClusterName> --overwrite-existing

# Open AKS k8s dashboard
az aks browse --resource-group <ResourceGroupName> --name <AksClusterName>

# Show resources
kubectl get ns
kubectl get all
#endregion Kubectl



#region Helm setup
# Install helm client
choco install -y kubernetes-helm

# Add Nexus repo
helm repo add stable https://kubernetes-charts.storage.googleapis.com/
helm repo list
helm repo update
#endregion Helm setup



#region Nexus Helm
# Prepare
cd nexus
kubectl create namespace nexus-helm
# permanently save the namespace for all subsequent kubectl commands in that context
kubectl config set-context --current --namespace=nexus-helm
helm pull stable/sonatype-nexus

# Install / upgrade (--atomic will roll back if any issues during install / upgrade)
helm upgrade -n nexus-helm -f nexus_values.yaml --install nexus stable/sonatype-nexus --atomic --dry-run
helm upgrade -n nexus-helm -f nexus_values.yaml --install nexus stable/sonatype-nexus --dry-run
helm upgrade -n nexus-helm -f nexus_values.yaml --install nexus stable/sonatype-nexus

# Verify
helm list
helm search hub nexus
kubectl get all,pv,pvc

# Monitor build
kubectl get ingress -o jsonpath='{.items[*].metadata.annotations.ingress\.kubernetes\.io/backends}'

# Port forward
# Find the name of your Nexus Pod
kubectl get pods
kubectl get all
kubectl port-forward <PodName> 8081:8081

# Uninstall
helm uninstall nexus
#endregion Nexus Helm



#region JFrog Artifactory
# https://github.com/jfrog/charts/tree/master/stable/artifactory-oss

# Add JFrog Helm repository
helm repo add jfrog https://charts.jfrog.io
helm repo update
helm repo list

# Find
helm search hub artifactory-oss

# Prepare
cd artifactory
helm pull jfrog/artifactory-oss
kubectl create namespace artifactory
kubectl get ns

# Install
helm upgrade --install --namespace artifactory artifactory-oss jfrog/artifactory-oss --dry-run
helm upgrade --install --namespace artifactory artifactory-oss jfrog/artifactory-oss

# Verify
helm list --namespace artifactory
helm list --all-namespaces
kubectl get all --namespace artifactory
kubectl get pv,pvc --namespace artifactory
# Login
# Username: admin, Password: password

# Uninstall
helm uninstall --namespace artifactory artifactory-oss

# Cleanup
# NOTE: Persistent Volume and Persistent Volume Claims may not be deleted
# Get and delete Persistent Volume Claims:
kubectl get pv,pvc -A
kubectl delete pvc -A --all
kubectl delete pv -A --all

kubectl delete namespace artifactory
#endregion JFrog Artifactory

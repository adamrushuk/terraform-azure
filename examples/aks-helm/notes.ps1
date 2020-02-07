# Install Binary Repository on AKS
throw "do not run whole script; F8 sections as required"

#region Kubectl
# Get AKS k8s creds
az aks get-credentials --resource-group aks-rg --name aks001 --overwrite-existing

# Open AKS k8s dashboard
az aks browse --resource-group aks-rg --name aks001

# Show resources
kubectl get ns
kubectl get all
#endregion Kubectl



#region Nexus Custom
# Prepare
cd nexus
kubectl create namespace nexus
kubectl get ns

# Apply manifests
kubectl apply --namespace nexus -f ./manifests

# Connect to pod and Show generated admin password
$podname = kubectl get pod -n nexus -l app=nexus -o jsonpath="{.items[0].metadata.name}"
kubectl exec -n nexus -it $podname /bin/bash
echo -e "\nadmin password: \n$(cat /nexus-data/admin.password)\n"

# Example nuget hosted default feed
http://<NexusHost>:8081/repository/nuget-hosted/

# Register Nuget repo command, eg:
nuget setapikey <NuGetApiKey> -source http://<NexusHost>:8081/repository/{repository name}/

# Assemble and show App URL
$appurl = kubectl get svc nexus --namespace nexus --ignore-not-found -o jsonpath="http://{.status.loadBalancer.ingress[0].ip}:{.spec.ports[0].port}"
Write-Output "Browse to app with: $appurl"

# Register Nuget feed as PowerShell repository
# https://sammart.in/post/creating-your-own-powershell-repository-with-nexus-3/
# Set NuGet API-Key Realm as "Active": http://<NexusHost>:8081/#admin/security/realms
Register-PSRepository -Name "MyCustomRepo" -SourceLocation http://<NexusHost>:8081/repository/nuget-hosted/ -PublishLocation http://<NexusHost>:8081/repository/nuget-hosted/ -PackageManagementProvider "nuget" -InstallationPolicy "Trusted"
Get-PSRepository

# Publish module
Publish-Module -Name "$env:HOME\Documents\WindowsPowerShell\Modules\Az.KeyVault\1.4.0" -Repository MyCustomRepo -NuGetApiKey "<NuGetApiKey>" -Verbose

# Find modules
Find-Module -Repository "MyCustomRepo"

# Delete manifests
kubectl delete --namespace nexus -f ./manifests
#endregion Nexus Custom



#region Helm setup
# Install helm client
choco install -y kubernetes-helm

# Install Nexus
helm repo add stable https://kubernetes-charts.storage.googleapis.com/
helm repo list
helm repo update
#endregion Helm setup



#region Nexus Helm
# Prepare
cd nexus
helm pull stable/sonatype-nexus

# Install / upgrade (--atomic will roll back if any issues during install / upgrade)
helm upgrade -f nexus_values.yaml --install nexus stable/sonatype-nexus --atomic --dry-run
helm upgrade -f nexus_values.yaml --install nexus stable/sonatype-nexus --dry-run
helm upgrade -f nexus_values.yaml --install nexus stable/sonatype-nexus

# Verify
helm list
helm search hub nexus

# Monitor build
kubectl get ingress -o jsonpath='{.items[*].metadata.annotations.ingress\.kubernetes\.io/backends}'

# Port forward
# Find the name of your Nexus Pod
kubectl get pods ()
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

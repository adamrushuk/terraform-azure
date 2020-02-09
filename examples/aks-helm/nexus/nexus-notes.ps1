# Deploy Nexus on AKS
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



#region Nexus Custom
# https://help.sonatype.com/repomanager3/formats/nuget-repositories

# AKS Container Insights is awesome - view live data
start https://portal.azure.com/#blade/Microsoft_Azure_Monitoring/AzureMonitoringBrowseBlade/containerInsights/menuId/containerInsights

# Prepare
cd nexus
# kubectl create namespace nexus
kubectl get ns
kubectl get all,pv,pvc #-n nexus

# Check
kubectl get events --sort-by=.metadata.creationTimestamp

# Apply manifests
kubectl apply -f ./manifests

# Check
kubectl get all
$podName = kubectl get pod -l app=nexus -o jsonpath="{.items[0].metadata.name}"
kubectl describe pod $podName
kubectl top pod $podName

# Wait for pod to be ready
kubectl get pod $podName --watch

# View container (Nexus application) logs
kubectl logs -f $podName

# Assemble and show App URL
$nexusUri = kubectl get svc nexus --ignore-not-found -o jsonpath="{.status.loadBalancer.ingress[0].ip}:{.spec.ports[0].port}"
$appurl = "http://$nexusUri"
Write-Output "Browse to app with: $appurl"
start $appurl

# Connect to pod and output generated admin password
kubectl exec -it $podName /bin/bash
echo -e "\nadmin password: \n$(cat /nexus-data/admin.password)\n"


# Show nexus user details (should have UID 200)
cat /etc/passwd | grep nexus

# Show persistent data folder mount info (eg. /nexus-data)
df -h | grep nexus
ls -lah / | grep nexus
ls -lah /nexus-data

# Get NuGet API token from Nexus
start "http://$nexusUri/#user/nugetapitoken"
$nuGetApiKey = "<NuGetApiKey>"

# Set NuGet API-Key Realm as "Active": http://<NexusHost>:8081/#admin/security/realms
start https://sammart.in/post/creating-your-own-powershell-repository-with-nexus-3/
start "http://$nexusUri/#admin/security/realms"

# Register Nuget feed as PowerShell repository
$repoUrl = "http://$nexusUri/repository/nuget-hosted/"
$repoName = "MyNugetRepo"
Register-PSRepository -Name $repoName -SourceLocation $repoUrl -PublishLocation $repoUrl -PackageManagementProvider "nuget" -InstallationPolicy "Trusted"

Get-PSRepository

# Publish modules
"Az.Advisor", "Az.Aks" | ForEach-Object { Publish-Module -Name "$env:OneDrive\Documents\PowerShell\Modules\$_" -Repository $repoName -NuGetApiKey $nuGetApiKey -Verbose }

# Find modules
Find-Module -Repository $repoName

# Show modules in Nexus repo
start "http://$nexusUri/#browse/browse:nuget-hosted"


# CLEANUP
# Delete manifests
kubectl delete -f ./manifests
# Delete only Deployment (pvc and service remains)
kubectl delete -f ./manifests/deployment.yml
#endregion Nexus Custom

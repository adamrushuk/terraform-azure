# Ingress notes
#
# Source: https://docs.microsoft.com/en-us/azure/aks/ingress-tls

Set-Location examples\aks-helm

# Get AKS k8s creds
az aks get-credentials --resource-group thnt-rg --name thnt-aks-ar

# Show resources
kubectl get ns
kubectl get all



#region Deploy NGINX ingress controller
# Create a namespace for your ingress resources
kubectl create namespace ingress-basic

# Add the official stable repo
helm repo add stable https://kubernetes-charts.storage.googleapis.com/

# Use Helm to deploy an NGINX ingress controller
helm install nginx stable/nginx-ingress `
    --namespace ingress-basic `
    --set controller.replicaCount=2 `
    --set controller.nodeSelector."beta\.kubernetes\.io/os"=linux `
    --set defaultBackend.nodeSelector."beta\.kubernetes\.io/os"=linux

# Watch status
kubectl --namespace ingress-basic get services -o wide -w nginx-nginx-ingress-controller
#endregion



#region cert-manager
# Install the CustomResourceDefinition resources separately
kubectl apply --validate=false -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.12/deploy/manifests/00-crds.yaml --namespace ingress-basic

# Label the ingress-basic namespace to disable resource validation
kubectl label namespace ingress-basic certmanager.k8s.io/disable-validation=true

# Add the Jetstack Helm repository
helm repo add jetstack https://charts.jetstack.io

# Update your local Helm chart repository cache
helm repo update

# Install the cert-manager Helm chart
helm install cert-manager `
    --namespace ingress-basic `
    --version v0.12.0 jetstack/cert-manager `
    --set ingressShim.defaultIssuerName=letsencrypt `
    --set ingressShim.defaultIssuerKind=ClusterIssuer

# Create a CA cluster issuer
kubectl apply -f cluster-issuer.yaml --namespace ingress-basic
#endregion



#region Run demo applications
helm repo add azure-samples https://azure-samples.github.io/helm-charts/

helm install aks-helloworld azure-samples/aks-helloworld --namespace ingress-basic

helm install aks-helloworld-two azure-samples/aks-helloworld `
    --namespace ingress-basic `
    --set title="AKS Ingress Demo" `
    --set serviceName="aks-helloworld-two"

# Show resources
helm list --namespace ingress-basic
kubectl get svc --namespace ingress-basic
#endregion


#region Create an ingress route
# Update MY_CUSTOM_DOMAIN placeholder with nginx-nginx-ingress-controller LoadBalancer EXTERNAL-IP,
# eg. "51.140.119.69" becomes "51-140-119-69.nip.io"
$ingressExternalIp = kubectl get svc nginx-nginx-ingress-controller --namespace ingress-basic -o jsonpath="{.status.loadBalancer.ingress[0].ip}"
$ingressExternalIpToRevDomain = ($ingressExternalIp -replace "\.","-") + ".nip.io"
$ingressFilename = "hello-world-ingress.yaml"
(Get-Content $ingressFilename -Raw) -replace "MY_CUSTOM_DOMAIN", $ingressExternalIpToRevDomain | Set-Content $ingressFilename

# Create resource
kubectl apply -f hello-world-ingress.yaml --namespace ingress-basic

# Wait for Secret to be "READY"
kubectl get certificate --namespace ingress-basic --watch
#endregion


#region Test HTTPS rules
# Get FQDN
$fqdn = kubectl get ingress hello-world-ingress --namespace ingress-basic -o jsonpath="{.spec.tls[].hosts[]}"

# Check aks-helloworld service
Start-Process https://$fqdn/

# Check aks-helloworld-two service
Start-Process https://$fqdn/hello-world-two
#endregion


#region Cleanup
kubectl delete namespace ingress-basic
helm repo remove azure-samples


kubectl get all,pv,pvc --namespace ingress-basic
helm repo list --namespace ingress-basic
helm list --namespace ingress-basic
#end

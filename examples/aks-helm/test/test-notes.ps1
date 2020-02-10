# Deploy nginx with volume mount on AKS
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



#region Volume mount testing
cd ./examples/aks-helm/test

kubectl apply -f .

kubectl get all

kubectl get pod mypod

kubectl logs mypod
kubectl logs -f mypod --tail 200

kubectl describe pod mypod

kubectl exec -it mypod /bin/bash
df -h
ls -lah /mnt/azure

kubectl delete -f .
#endregion Volume mount testing


# Reference
Example on how to attach and troubleshoot a volume to a BusyBox container:
https://itnext.io/debugging-kubernetes-pvcs-a150f5efbe95

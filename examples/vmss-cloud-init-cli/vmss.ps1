# Create Scale Set
# source: https://docs.microsoft.com/en-us/azure/virtual-machines/linux/tutorial-create-vmss

# Vars
$environment = "dev"
$location = "uksouth"
$resource_group_name = "zzap-rg-vmss"
$scaleset_name = "myScaleSet"

# Create resource group
az group create --name $resource_group_name --location $location

# Create scale set
az vmss create `
  --resource-group $resource_group_name `
  --name $scaleset_name `
  --image UbuntuLTS `
  --upgrade-policy-mode automatic `
  --custom-data cloud-init.txt `
  --admin-username sysadmin `
  --generate-ssh-keys

# Get public IP
$vmss_public_ip = az network public-ip show `
  --resource-group $resource_group_name `
  --name "$($scaleset_name)LBPublicIP" `
  --query [ipAddress] `
  --output tsv

# Test
# normal port 22 wont work as behind load balancer
curl -v telnet://$($vmss_public_ip):22
# NAT ports for each backend VM should work
curl -v telnet://$($vmss_public_ip):50000
curl -v telnet://$($vmss_public_ip):50001

# SSH
ssh -v sysadmin@$($vmss_public_ip) -p 50000

# Create probe BEFORE load balancer
az network lb probe create `
  --resource-group $resource_group_name `
  --lb-name "$($scaleset_name)LB" `
  --name myLoadBalancerRuleWeb `
  --protocol tcp `
  --port 80

# Create load balancing rules
az network lb rule create `
  --resource-group $resource_group_name `
  --name myLoadBalancerRuleWeb `
  --lb-name "$($scaleset_name)LB" `
  --backend-pool-name "$($scaleset_name)LBBEPool" `
  --backend-port 80 `
  --frontend-ip-name loadBalancerFrontEnd `
  --frontend-port 80 `
  --protocol tcp

# [OPTIONAL ]Reset SSH key- Virtual Machine Scale Set (VMSS)
az vmss extension set `
  --vmss-name $scaleset_name `
  -g $resource_group_name `
  -n VMAccessForLinux `
  --publisher Microsoft.OSTCExtensions `
  --version 1.4 `
  --protected-settings "{\"username\":\"deploy_user\", \"ssh_key\":\"$(cat ~/.ssh/id_rsa.pub)\"}"

# Upgrade ALL instances in the scale set with the new key
az vmss update-instances --instance-ids '*' -n $scaleset_name -g $resource_group_name



# Cleanup
az group delete --name $resource_group_name

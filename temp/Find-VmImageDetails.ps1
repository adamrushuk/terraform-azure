# Find VM Image details
$vmImages = Get-AzVmImage -PublisherName canonical -Location eastus

$locName="eastus"
Get-AzVMImagePublisher -Location $locName | Select-Object PublisherName

$pubName="canonical"
Get-AzVMImageOffer -Location $locName -PublisherName $pubName | Select-Object Offer

$offerName="UbuntuServer"
Get-AzVMImageSku -Location $locName -PublisherName $pubName -Offer $offerName | Select-Object Skus

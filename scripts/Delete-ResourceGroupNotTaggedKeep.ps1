# Delete EVERY resource group that does NOT have tag: keep=true
$jobs = Get-AzResourceGroup | Where-Object {$_.Tags -eq $null -or $_.Tags.GetEnumerator().Name -ne "keep"} | Remove-AzResourceGroup -Force -AsJob
$jobs | Wait-Job
$jobs | Receive-Job -Keep

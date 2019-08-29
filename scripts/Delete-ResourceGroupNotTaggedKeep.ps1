# Delete EVERY resource group that does NOT include tag: keep=true
$jobs = Get-AzResourceGroup | Where-Object {$_.Tags -eq $null -or $_.Tags.GetEnumerator().Name -notcontains "keep"} | Remove-AzResourceGroup -Force -AsJob
$jobs | Wait-Job
$jobs | Receive-Job -Keep

# Start timer
$timer = [Diagnostics.Stopwatch]::StartNew()
Write-Host "STARTED: $(Get-Date)"

# Terraform
terraform destroy -auto-approve

# Stop timer
$timer.Stop()
Write-Host "FINISHED: $(Get-Date)"
Write-Host "TERRAFORM DESTROY: [$($timer.Elapsed.Minutes)m$($timer.Elapsed.Seconds)s elapsed]"

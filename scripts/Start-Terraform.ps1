# Start timer
$timer = [Diagnostics.Stopwatch]::StartNew()
Write-Host "STARTED: $(Get-Date)"

# Terraform
terraform apply -auto-approve

# Stop timer
$timer.Stop()
Write-Host "FINISHED: $(Get-Date)"
Write-Host "TERRAFORM APPLY: [$($timer.Elapsed.Minutes)m$($timer.Elapsed.Seconds)s elapsed]"

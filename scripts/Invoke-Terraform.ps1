<#
.SYNOPSIS
    Invokes Terraform with supplied command
.DESCRIPTION
    Invokes Terraform with supplied command (default: apply), using auto approve (no prompts)
    Starts a timer to show Total Time Elapsed.
.NOTES
    Author:  Adam Rush
    Blog:    https://adamrushuk.github.io
    GitHub:  https://github.com/adamrushuk
    Twitter: @adamrushuk
#>

[CmdletBinding()]
param (
    # The Terraform command to run
    $Command = "apply"
)

# Start timer
$timer = [Diagnostics.Stopwatch]::StartNew()
Write-Host "`nSTARTED: $(Get-Date)" -ForegroundColor "Yellow"

# Terraform
& terraform $Command -auto-approve

# Stop timer
$timer.Stop()
Write-Host "`nFINISHED: $(Get-Date)" -ForegroundColor "Yellow"
Write-Host "TERRAFORM [$Command]: [$($timer.Elapsed.Minutes)m$($timer.Elapsed.Seconds)s elapsed]`n" -ForegroundColor "Green"

param
(
    [string] $SubscriptionName = "Faurecia_DSF_Dev",
    [string] $BlueprintName = "bp-cloudgov",
    [string] $Developer = "jkang"
)

$ErrorActionPreference = "Stop"

# Declare variables
$TempBlueprintName = "$BlueprintName-$Developer"
$BlueprintAssignmentName = $TempBlueprintName -replace "bp-", "bpa-"

Write-Host "Switching to subscription '$SubscriptionName'..."
Set-AzContext -SubscriptionName $SubscriptionName | Out-Null

Write-Host "Deleting blueprint assignment '$BlueprintAssignmentName'..."
Remove-AzBlueprintAssignment -Name $BlueprintAssignmentName

Write-Host "Deleting resource groups..."
Remove-AzResourceGroup -Confirm -Name "rg-inf-$Developer-azure-bastion"
Remove-AzResourceGroup -Confirm -Name "rg-inf-$Developer-ci"
Remove-AzResourceGroup -Confirm -Name "rg-inf-$Developer-classic-bastion"
Remove-AzResourceGroup -Confirm -Name "rg-inf-$Developer-delivery"
Remove-AzResourceGroup -Confirm -Name "rg-inf-$Developer-inventory"
Remove-AzResourceGroup -Confirm -Name "rg-inf-$Developer-recovery"
Remove-AzResourceGroup -Confirm -Name "rg-inf-$Developer-network"

Write-Host "Done."

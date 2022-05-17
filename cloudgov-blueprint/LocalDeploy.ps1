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

Write-Host "Getting subscription ID..."
$SubscriptionId = Get-AzSubscription -SubscriptionName $SubscriptionName | Select-Object -ExpandProperty Id

Write-Host "Importing blueprint definition '$TempBlueprintName' to Azure as draft..."
Import-AzBlueprintWithArtifact -Name $TempBlueprintName -SubscriptionId $SubscriptionId -InputPath  "./$BlueprintName" -IncludeSubFolders -Force

Write-Host "Getting the blueprint definition we just imported..."
$Blueprint = Get-AzBlueprint -Name $TempBlueprintName -SubscriptionId $SubscriptionId

$Version = Get-Date -format "yyyyMMddHHmmss"
Write-Host "Publishing a new blueprint definition version '$Version'..."
Publish-AzBlueprint -Blueprint $Blueprint -Version $Version | Out-Null

Write-Host "Getting the blueprint definition version we just published..."
$LatestPublishedBp = Get-AzBlueprint -SubscriptionId $SubscriptionId -Name $TempBlueprintName -LatestPublished

Write-Host "Generating blueprint assignment file..."
$AssignmentFile = "./$BlueprintName/assign-$Developer.json"
$Content = Get-Content "./$BlueprintName/assign.json" -raw | ConvertFrom-Json
$Content.properties | ForEach-Object {$_.blueprintId=$LatestPublishedBp.id}
$Content.properties.parameters.stackName  | ForEach-Object {$_.value="$Developer"}
$Content | ConvertTo-Json -Depth 100| set-content $AssignmentFile

Write-Host "Creating or updating blueprint assignment..."
$BlueprintAssignment = Get-AzBlueprintAssignment -Name $BlueprintAssignmentName -ErrorAction SilentlyContinue
if ($BlueprintAssignment) {
    Set-AzBlueprintAssignment -Name $BlueprintAssignmentName -Blueprint $LatestPublishedBp -AssignmentFile $AssignmentFile | Out-Null
} else {
    New-AzBlueprintAssignment -Name $BlueprintAssignmentName -Blueprint $LatestPublishedBp -AssignmentFile $AssignmentFile | Out-Null
}

Write-Host "Done. To verify provisioning status: Get-AzBlueprintAssignment -Name ""$BlueprintAssignmentName"" | Select-Object -ExpandProperty ProvisioningState"

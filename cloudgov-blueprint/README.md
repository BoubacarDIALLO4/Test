# Cloud governance blueprint

[![Build Status](https://dev.azure.com/faurecia-dsf/Solar/_apis/build/status/cloudgov-blueprint)](https://dev.azure.com/faurecia-dsf/Solar/_build/latest?definitionId=388)
[![Badge Image](https://vsrm.dev.azure.com/faurecia-dsf/_apis/public/Release/badge/05182646-b23d-43be-910f-aead1ee48bc8/11/27)](https://dev.azure.com/faurecia-dsf/Solar/_release?view=all&_a=releases&definitionId=11)

This repository contains [Azure Blueprints](https://docs.microsoft.com/en-us/azure/governance/blueprints/overview) that orchestrates the deployment of DSF shared staci development infrastructure: VNet, bastion, etc.

See [this article](https://github.com/Azure/azure-blueprints) for details about managing Azure Blueprint as codes.

## Contribution guideline

Please follow [Github flow](https://guides.github.com/introduction/flow/).

To trigger deployment, add a new tag on main branch. It should automatically trigger CI/CD pipelines.

You can view details of the Blueprint assignment in [Azure Portal](https://portal.azure.com/#blade/Microsoft_Azure_Policy/BlueprintsMenuBlade/BlueprintAssignments).

### Prerequisites

1. Have at least the following role assignments:
   - subscription level **Blueprint Contributor**
   - subscription level **Blueprint Operator**

1. Install PowerShell 7.x or higher version

1. Install Azure Module following [this document](https://docs.microsoft.com/en-us/powershell/azure/install-az-ps?view=azps-5.2.0#install-the-azure-powershell-module).

1. Install the follwoing Powershell modules

    ```powershell
    Install-Module -Name Az.Blueprint,Az.ManagedServiceIdentity -Scope CurrentUser
    ```

### Quickstart: Manually publish and assign blueprint for testing

```powershell
# Log in
Connect-AzAccount

# Deploy
.\LocalDeploy.ps1 -Developer "jkang"

# Cleanup
.\Cleanup.ps1 -Developer "jkang"
```

## Quickstart: Publish blueprint and assign to subscritpion for testing

```powershell
# Declare variables
$managementGorupId = "mg-faurecia-dsf"
$subscriptionName = "Faurecia_DSF_Dev"
$blueprintName = "bp-dsf-dev-local"
$blueprintAssignmentName = "bpa-dsf-dev-local"

# Login
Connect-AzAccount

# Select subscription
Set-AzContext -SubscriptionName $subscriptionName

# Push blueprint definition to Azure
Import-AzBlueprintWithArtifact -Name $blueprintName -ManagementGroupId $managementGorupId -InputPath "./bp-dsf-dev" -IncludeSubFolders -Force

# Get the blueprint definition we just created
$blueprint = Get-AzBlueprint -Name $blueprintName -ManagementGroupId $managementGorupId

# Publish a new version
$version = Get-Date -format "yyyyMMddHHmmss"
Publish-AzBlueprint -Blueprint $blueprint -Version $version

# Get published version of the blueprint 
$latestPublishedBp = Get-AzBlueprint -ManagementGroupId $managementGorupId -Name $blueprintName -LatestPublished

# Update blueprint ID in assignment file
$assignmentFile = "./bp-dsf-dev/assign-test.json"
$content = Get-Content $assignmentFile -raw | ConvertFrom-Json
$content.properties | % {if($_.blueprintId -ne $latestPublishedBp.id){$_.blueprintId=$latestPublishedBp.id}}
$content | ConvertTo-Json -Depth 100| set-content $assignmentFile

# Create or update blueprint assignment
$bpa = Get-AzBlueprintAssignment -Name $blueprintAssignmentName -ErrorAction SilentlyContinue
if ($bpa) {
    Set-AzBlueprintAssignment -Name $blueprintAssignmentName -Blueprint $latestPublishedBp -AssignmentFile $assignmentFile
} else {
    New-AzBlueprintAssignment -Name $blueprintAssignmentName -Blueprint $latestPublishedBp -AssignmentFile $assignmentFile
}

# Get blueprint assignment to verify provitioning state
Get-AzBlueprintAssignment -Name $blueprintAssignmentName

###################
# Cleanup
##################

# Delete the blueprint assignment
Remove-AzBlueprintAssignment -Name $blueprintAssignmentName

# Delete all resources created by the blueprint (following list might not be exclusive)
Remove-AzResourceGroup -Name "rg-inf-test-inventory" -AsJob
Remove-AzResourceGroup -Name "rg-inf-test-ci" -AsJob
Remove-AzResourceGroup -Name "rg-inf-test-recovery" -AsJob
Remove-AzResourceGroup -Name "rg-inf-test-azure-bastion"
Remove-AzResourceGroup -Name "rg-inf-test-classic-bastion"
Remove-AzResourceGroup -Name "rg-inf-test-network" -AsJob
```

## CI/CD

1. Create a feature branch from master
1. Make code changes, commit and create a PR merging to master
1. Once the PR is completed, tag the master branch with a new version following [Semantic Versioning 2.x](https://semver.org/))
1. CI/CD will trigger automatically which will publish and assign the new blueprint version
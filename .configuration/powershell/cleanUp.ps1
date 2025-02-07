# PowerShell script to clean up Azure resources

# Exit immediately if a command exits with a non-zero status, treat unset variables as an error, and propagate errors in pipelines.
$ErrorActionPreference = "Stop"
$WarningPreference = "Stop"

# Azure Resource Group Names Constants
$solutionName = "Contoso"
$devBoxResourceGroupName = "$solutionName-DevExp-RG"
$networkResourceGroupName = "$solutionName-DevExp-Connectivity-RG"

# Identity Parameters Constants
$customRoleName = "ContosoDevCenterDevBoxRole"

# Get the current subscription ID
$subscriptionId = (az account show --query id --output tsv)

# Function to delete a resource group
function Remove-ResourceGroup {
    param (
        [Parameter(Mandatory=$true)]
        [string]$resourceGroupName
    )

    try {
        $groupExists = (az group exists --name $resourceGroupName)

        if ($groupExists -eq "true") {
            # List and delete all deployments in the resource group
            $deployments = az deployment group list --resource-group $resourceGroupName --query "[].name" -o tsv
            foreach ($deployment in $deployments) {
                Write-Output "Deleting deployment: $deployment"
                az deployment group delete --resource-group $resourceGroupName --name $deployment
                Write-Output "Deployment $deployment deleted."
            }
            Start-Sleep -Seconds 10
            Write-Output "Deleting resource group: $resourceGroupName..."
            az group delete --name $resourceGroupName --yes --no-wait
            Write-Output "Resource group $resourceGroupName deletion initiated."
        } else {
            Write-Output "Resource group $resourceGroupName does not exist. Skipping deletion."
        }
    } catch {
        Write-Error "Error deleting resource group $resourceGroupName $_"
        return 1
    }
}

# Function to remove a role assignment
function Remove-RoleAssignment {
    param (
        [Parameter(Mandatory=$true)]
        [string]$roleId,

        [Parameter(Mandatory=$true)]
        [string]$subscription
    )

    try {
        Write-Output "Checking the role assignments for the identity..."

        if ([string]::IsNullOrEmpty($roleId)) {
            Write-Output "Role not defined. Skipping role assignment deletion."
            return
        }

        $assignmentExists = az role assignment list --role $roleId --scope /subscriptions/$subscription
        if ([string]::IsNullOrEmpty($assignmentExists) -or $assignmentExists -eq "[]") {
            Write-Output "'$roleId' role assignment does not exist. Skipping deletion."
        } else {
            Write-Output "Removing '$roleId' role assignment from the identity..."
            az role assignment delete --role $roleId
            Write-Output "'$roleId' role assignment successfully removed."
        }
    } catch {
        Write-Error "Error removing role assignment $roleId $_"
        return 1
    }
}

# Function to delete a custom role
function Remove-CustomRole {
    param (
        [Parameter(Mandatory=$true)]
        [string]$roleName
    )

    try {
        Write-Output "Deleting the '$roleName' role..."
        $roleExists = az role definition list --name $roleName

        if ([string]::IsNullOrEmpty($roleExists) -or $roleExists -eq "[]") {
            Write-Output "'$roleName' role does not exist. Skipping deletion."
            return
        }

        az role definition delete --name $roleName

        while ((az role definition list --name $roleName --query [].roleName -o tsv) -eq $roleName) {
            Write-Output "Waiting for the role to be deleted..."
            Start-Sleep -Seconds 10
        }
        Write-Output "'$roleName' role successfully deleted."
    } catch {
        Write-Error "Error deleting custom role $roleName $_"
        return 1
    }
}

# Function to delete role assignments
function Remove-RoleAssignments {
    try {
        # Deleting role assignments and role definitions
        $roles = @('Owner', 'Managed Identity Operator', $customRoleName, 'ContosoDx-identity-customRole', 'ContosoIpeDx-identity-customRole', 'Deployment Environments Reader', 'Deployment Environments User')
        foreach ($roleName in $roles) {
            Write-Output "Getting the role ID for '$roleName'..."
            $roleId = az role definition list --name $roleName --query [].name --output tsv
            if ([string]::IsNullOrEmpty($roleId)) {
                Write-Output "Role ID for '$roleName' not found. Skipping role assignment deletion."
                continue
            } else {
                Write-Output "Role ID for '$roleName' is '$roleId'."
                Write-Output "Removing '$roleName' role assignment..."
            }
            Remove-RoleAssignment -roleId $roleId -subscription $subscriptionId
        }
    } catch {
        Write-Error "Error deleting role assignments: $_"
        return 1
    }
}

# Function to clean up resources
function Remove-Resources {
    try {
        Clear-Host
        Remove-RoleAssignments
        Remove-ResourceGroup -resourceGroupName $devBoxResourceGroupName
        Remove-ResourceGroup -resourceGroupName $networkResourceGroupName
        Remove-ResourceGroup -resourceGroupName "NetworkWatcherRG"
        Remove-ResourceGroup -resourceGroupName "Default-ActivityLogAlerts"
        Remove-ResourceGroup -resourceGroupName "DefaultResourceGroup-WUS2"
        Remove-CustomRole -roleName $customRoleName
        Remove-CustomRole -roleName 'ContosoDx-identity-customRole'
        Remove-CustomRole -roleName 'ContosoIpeDx-identity-customRole'
    } catch {
        Write-Error "Error during cleanup process: $_"
        return 1
    }
}

# Main script execution
try {
    Remove-Resources
} catch {
    Write-Error "Script execution failed: $_"
    exit 1
}
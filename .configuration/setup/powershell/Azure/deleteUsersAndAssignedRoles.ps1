# PowerShell script to delete user assignments and roles

param (
    [string]$appDisplayName
)

# Function to delete user assignments and roles
function Remove-UserAssignments {
    try {
        # Get the current signed-in user's object ID
        $currentUser = az ad signed-in-user show --query id -o tsv

        if (-not $currentUser) {
            throw "Failed to retrieve current signed-in user's object ID."
        }

        Write-Output "Removing user assignments and roles for currentUser: $currentUser"

        # Define roles to be removed
        $roles = @(
            @{ RoleName = "DevCenter Project Admin"; IdType = "ServicePrincipal" },
            @{ RoleName = "DevCenter Dev Box User"; IdType = "User" }
        )

        # Remove roles from the service principal and current user
        foreach ($role in $roles) {
            Remove-Role -userIdentityId $currentUser -roleName $role.RoleName -idType $role.IdType
            if ($LASTEXITCODE -ne 0) {
                throw "Failed to remove role '$($role.RoleName)' from current user with object ID: $currentUser"
            }
        }

        Write-Output "User assignments and roles removals completed successfully for currentUser: $currentUser"
    } catch {
        Write-Error "Error: $_"
        return 1
    }
}

# Function to remove a role from a user or service principal
function Remove-Role {
    param (
        [Parameter(Mandatory=$true)]
        [string]$userIdentityId,

        [Parameter(Mandatory=$true)]
        [string]$roleName,

        [Parameter(Mandatory=$true)]
        [string]$idType
    )

    try {
        Write-Output "Removing '$roleName' role from identityId $userIdentityId..."

        # Attempt to remove the role
        $result = az role assignment delete --assignee $userIdentityId --role $roleName --scope /subscriptions/$subscriptionId

        if ($null -ne $result) {
            throw "Failed to remove role '$roleName' from identityId $userIdentityId."
        }

        Write-Output "Role '$roleName' removed successfully."
    } catch {
        Write-Error "Error: $_"
        return 1
    }
}

# Function to validate input parameters
function Test-Input {
    param (
        [Parameter(Mandatory=$true)]
        [string]$appDisplayName
    )

    if ([string]::IsNullOrEmpty($appDisplayName)) {
        Write-Output "Error: Missing required parameter."
        Write-Output "Usage: .\deleteUsersAndAssignedRoles.ps1 -appDisplayName <appDisplayName>"
        return 1
    }
}

# Main script execution
try {
    Test-Input -appDisplayName $appDisplayName
    if ($LASTEXITCODE -eq 0) {
        Remove-UserAssignments
    }
} catch {
    Write-Error "Script execution failed: $_"
    exit 1
}
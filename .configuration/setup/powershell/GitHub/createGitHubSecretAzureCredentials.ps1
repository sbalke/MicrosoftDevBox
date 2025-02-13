# PowerShell script to create GitHub secret for Azure credentials


# Function to log in to GitHub using the GitHub CLI
function Connect-ToGitHub {
    Write-Output "Connecting to GitHub using GitHub CLI..."

    try {
        # Attempt to log in to GitHub
        gh auth login
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to log in to GitHub."
        }

        Write-Output "Successfully logged in to GitHub."
    } catch {
        Write-Error "Error: $_"
        return 1
    }
}

# Function to set up GitHub secret authentication
function Set-GitHubSecretAuthentication {
    param (
        [string]$ghSecretBody
    )

    $ghSecretName = "AZURE_CREDENTIALS"
    
    try {
        # Check if required parameter is provided
        if ([string]::IsNullOrEmpty($ghSecretBody)) {
            throw "Missing required parameter."
        }

        Write-Output "Setting up GitHub secret authentication..."

        # Log in to GitHub
        Connect-ToGitHub
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to log in to GitHub."
        }

        # Set the GitHub secret
        gh secret set $ghSecretName --body $ghSecretBody
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to set GitHub secret: $ghSecretName"
        }

        Write-Output "GitHub secret: $ghSecretName set successfully."
        Write-Output "GitHub secret body: $ghSecretBody"
    } catch {
        Write-Error "Error: $_"
        return 1
    }
}

# Function to validate input parameters
function Test-Input {
    param (
        [string]$ghSecretBody
    )

    try {
        # Check if required parameters are provided
        if ([string]::IsNullOrEmpty($ghSecretBody)) {
            throw "Missing required parameters."
        }
    } catch {
        Write-Error "Error: $_"
        Write-Output "Usage: Test-Input -ghSecretBody <ghSecretBody>"
        return 1
    }
}

# Main script execution
try {
    Test-Input -ghSecretBody $ghSecretBody
    if ($LASTEXITCODE -eq 0) {
        Set-GitHubSecretAuthentication -ghSecretBody $ghSecretBody
    }
} catch {
    Write-Error "Script execution failed: $_"
    exit 1
}
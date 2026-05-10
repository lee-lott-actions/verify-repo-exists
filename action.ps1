function Test-RepoExists {
    param(
        [string]$RepoName,
        [string]$Token,
        [string]$Owner
    )

    # Validate required parameters
    if ([string]::IsNullOrEmpty($RepoName) -or
        [string]::IsNullOrEmpty($Owner) -or
        [string]::IsNullOrEmpty($Token)) {
        Write-Host "Error: Missing required parameters"
        Add-Content -Path $env:GITHUB_OUTPUT -Value "error-message=Missing required parameters: repo_name, owner, and token must be provided."
        Add-Content -Path $env:GITHUB_OUTPUT -Value "result=failure"
        return
    }

    Write-Host "Attempting to verify repository $RepoName exists"

    # Use MOCK_API if set, otherwise default to GitHub API
    $apiBaseUrl = $env:MOCK_API
    if (-not $apiBaseUrl) { $apiBaseUrl = "https://api.github.com" }
    $uri = "$apiBaseUrl/repos/$Owner/$RepoName"

    $headers = @{
        Authorization = "Bearer $Token"
        Accept = "application/vnd.github.v3+json"
		"X-GitHub-Api-Version" = "2026-03-10"
    }

    try {
        $response = Invoke-WebRequest -Uri $uri -Headers $headers -Method Get

        Write-Host $response.Content

        if ($response.StatusCode -eq 200) {
			Write-Host "Repository '$RepoName' exists in organization."
            Add-Content -Path $env:GITHUB_OUTPUT -Value "result=success"
            Add-Content -Path $env:GITHUB_OUTPUT -Value "repo-exists=true"

            # Try to parse is_template property from JSON; if fails, treat as false
            $isTemplate = $false
            try {
                $json = $response.Content | ConvertFrom-Json
                if ($null -ne $json.is_template -and $json.is_template -eq $true) {
                    $isTemplate = $true
                }
            } catch {
                $isTemplate = $false
            }
            if ($isTemplate) {
                Add-Content -Path $env:GITHUB_OUTPUT -Value "is-template-repo=true"
            } else {
                Add-Content -Path $env:GITHUB_OUTPUT -Value "is-template-repo=false"
            }
        } else {
			Write-Host "Repository '$RepoName' does not exist in organization."
            Add-Content -Path $env:GITHUB_OUTPUT -Value "result=success"
            Add-Content -Path $env:GITHUB_OUTPUT -Value "repo-exists=false"
            Add-Content -Path $env:GITHUB_OUTPUT -Value "is-template-repo=false"
			
        }
    } catch {
		$errorMsg = "Error: Failed to verify Repository '$RepoName' exists in organization '$Owner'. Exception: $($_.Exception.Message)"
        Add-Content -Path $env:GITHUB_OUTPUT -Value "result=failure"
        Add-Content -Path $env:GITHUB_OUTPUT -Value "repo-exists=false"
        Add-Content -Path $env:GITHUB_OUTPUT -Value "is-template-repo=false"
		Add-Content -Path $env:GITHUB_OUTPUT -Value "error-message=$errorMsg"
		Write-Host $errorMsg
    }
}

Describe "Test-RepoExists" {
    BeforeAll {
        $script:RepoName   = "test-repo"
        $script:Owner      = "test-owner"
        $script:Token      = "fake-token"
        $script:MockApiUrl = "http://127.0.0.1:3000"
        . "$PSScriptRoot/../action.ps1"
    }
	
	BeforeEach {
        $env:GITHUB_OUTPUT = New-TemporaryFile
        $env:MOCK_API = $script:MockApiUrl
    }
	
    AfterEach {
        if (Test-Path $env:GITHUB_OUTPUT) { Remove-Item $env:GITHUB_OUTPUT }
        Remove-Item Env:MOCK_API -ErrorAction SilentlyContinue
    }

	Context "Success Cases"	{
	    It "unit: Test-RepoExists succeeds with HTTP 200 and is_template true" {
	        Mock Invoke-WebRequest {
	            [PSCustomObject]@{ StatusCode = 200; Content = '{"is_template": true}' }
	        }
	        Test-RepoExists -RepoName $RepoName -Token $Token -Owner $Owner
	        $output = Get-Content $env:GITHUB_OUTPUT
	        $output | Should -Contain "result=success"
	        $output | Should -Contain "repo-exists=true"
	        $output | Should -Contain "is-template-repo=true"
	    }

		It "unit: Test-RepoExists succeeds with HTTP 200 and is_template false" {
	        Mock Invoke-WebRequest {
	            [PSCustomObject]@{ StatusCode = 200; Content = '{"is_template": false}' }
	        }
	        Test-RepoExists -RepoName $RepoName -Token $Token -Owner $Owner
	        $output = Get-Content $env:GITHUB_OUTPUT
	        $output | Should -Contain "result=success"
	        $output | Should -Contain "repo-exists=true"
	        $output | Should -Contain "is-template-repo=false"
	    }
	}

	Context "HTTP Failure Cases" {
		    It "unit: Test-RepoExists fails with HTTP 404" {
	        Mock Invoke-WebRequest {
	            [PSCustomObject]@{ StatusCode = 404; Content = '{"message": "Not Found"}' }
	        }
	        Test-RepoExists -RepoName $RepoName -Token $Token -Owner $Owner
	        $output = Get-Content $env:GITHUB_OUTPUT
	        $output | Should -Contain "result=success"
	        $output | Should -Contain "repo-exists=false"
	        $output | Should -Contain "is-template-repo=false"
	    }	
	}
	
	Context "Parameter Validation Failure Cases" {
		It "unit: Test-RepoExists fails with empty RepoName" {
	        Test-RepoExists -RepoName "" -Token $Token -Owner $Owner
	        $output = Get-Content $env:GITHUB_OUTPUT
	        $output | Should -Contain "result=failure"
	        $output | Should -Contain "error-message=Missing required parameters: repo_name, owner, and token must be provided."
	    }
	
	    It "unit: Test-RepoExists fails with empty Owner" {
	        Test-RepoExists -RepoName $RepoName -Token $Token -Owner ""
	        $output = Get-Content $env:GITHUB_OUTPUT
	        $output | Should -Contain "result=failure"
	        $output | Should -Contain "error-message=Missing required parameters: repo_name, owner, and token must be provided."
	    }
	
	    It "unit: Test-RepoExists fails with empty Token" {
	        Test-RepoExists -RepoName $RepoName -Token "" -Owner $Owner
	        $output = Get-Content $env:GITHUB_OUTPUT
	        $output | Should -Contain "result=failure"
	        $output | Should -Contain "error-message=Missing required parameters: repo_name, owner, and token must be provided."
	    }
	}

	Context "Exception Failure Cases" {
		It "unit: Test-RepoExists fails with exception" {
			Mock Invoke-WebRequest { throw "API Error" }
	
			Test-RepoExists -RepoName $RepoName -Token $Token -Owner $Owner
	
			$output = Get-Content $env:GITHUB_OUTPUT
			$output | Should -Contain "result=failure"
			$output | Should -Contain "repo-exists=false"
			$output | Where-Object { $_ -match "^error-message=Error: Failed to verify Repository '$RepoName' exists in organization '$Owner'\. Exception:" } |
				Should -Not -BeNullOrEmpty
		}	
	}
}

# Validate Repository Existence Action

This GitHub Action checks if a specified repository exists on GitHub and whether it is a template repository using the GitHub API. It returns boolean outputs indicating whether the repository exists (`true` for HTTP 200, `false` otherwise) and whether it is a template repository (`true` if `is_template` is true, `false` otherwise).

## Features
- Validates the existence of a GitHub repository by making an API call.
- Checks if the repository is a template repository.
- Outputs booleans (`repo-exists` and `is-template-repo`) for easy integration into workflows.
- Requires a GitHub token with `repo` scope for authentication.

## Inputs
| Name       | Description                                      | Required | Default |
|------------|--------------------------------------------------|----------|---------|
| `repo-name`| The name of the repository to check.             | Yes      | N/A     |
| `token`    | GitHub token with repository read access.        | Yes      | N/A     |
| `owner`    | The owner of the repository (user or organization). | Yes      | N/A     |

## Outputs
| Name              | Description                                           |
|-------------------|-------------------------------------------------------|
| `result`          | Result of the action ("success" or "failure")         |
| `repo-exists`     | Boolean indicating if the repository exists (`true` for HTTP 200, `false` otherwise). |
| `is-template-repo`| Boolean indicating if the repository is a template repository (`true` if `is_template` is true, `false` otherwise). |

## Usage
1. **Add the Action to Your Workflow**:
   Create or update a workflow file (e.g., `.github/workflows/check-repo.yml`) in your repository.

2. **Reference the Action**:
   Use the action by referencing the repository and version (e.g., `v1`).

3. **Example Workflow**:
   ```yaml
   name: Check Repository Existence
   on:
     push:
       branches:
         - main
   jobs:
     check-repo:
       runs-on: ubuntu-latest
       steps:
         - name: Validate Repository
           id: validate
           uses: lee-lott-actions/verify-repo-exists@v1
           with:
             repo-name: 'your-repo-name'
             token: ${{ secrets.GITHUB_TOKEN }}
             owner: ${{ github.repository_owner }}
         - name: Print Result
           run: |
             if [[ "${{ steps.validate.outputs.repo-exists }}" == "true" ]]; then
               echo "Repository ${{ github.repository_owner }}/your-repo-name exists."
               if [[ "${{ steps.validate.outputs.is-template-repo }}" == "true" ]]; then
                 echo "Repository is a template repository."
               else
                 echo "Repository is not a template repository."
               fi
             else
               echo "Error: Repository does not exist or is inaccessible."
               exit 1
             fi

#!/bin/bash
validate_repo_exists() {
  local repo_name="$1"
  local token="$2"
  local owner="$3"

  # Validate required inputs
  if [ -z "$repo_name" ] || [ -z "$owner" ] || [ -z "$token" ]; then
    echo "Error: Missing required parameters"
    echo "error-message=Missing required parameters: repo_name, owner, and token must be provided." >> "$GITHUB_OUTPUT"
    echo "result=failure" >> "$GITHUB_OUTPUT"
    return
  fi

  echo "Attempting to verify repository $repo_name exists" 

  # Use MOCK_API if set, otherwise default to GitHub API
  local api_base_url="${MOCK_API:-https://api.github.com}"

  RESPONSE=$(curl -s -o response.json -w "%{http_code}" \
    -H "Authorization: Bearer $token" \
    -H "Accept: application/vnd.github.v3+json" \
    -H "Content-Type: application/json" \
    "$api_base_url/repos/$owner/$repo_name")

  cat response.json
    
  if [ "$RESPONSE" -eq 200 ]; then
    echo "result=success" >> $GITHUB_OUTPUT
    echo "repo-exists=true" >> $GITHUB_OUTPUT
    
    IS_TEMPLATE=$(jq -r '.is_template' response.json)
    
    if [ "$IS_TEMPLATE" = "true" ]; then
      echo "is-template-repo=true" >> $GITHUB_OUTPUT
    else
      echo "is-template-repo=false" >> $GITHUB_OUTPUT
    fi
  else
    echo "result=success" >> $GITHUB_OUTPUT
    echo "repo-exists=false" >> $GITHUB_OUTPUT
    echo "is-template-repo=false" >> $GITHUB_OUTPUT
  fi
}

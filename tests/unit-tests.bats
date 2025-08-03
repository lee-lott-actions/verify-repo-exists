#!/usr/bin/env bats

# Load the Bash script
load ../action.sh

# Mock the curl command to simulate API responses
mock_curl() {
  local http_code=$1
  local response_file=$2
  echo "$http_code"
  cat "$response_file" > response.json
}

# Mock jq command to extract values from JSON
mock_jq() {
  local key=$1
  local file=$2
  if [ "$key" = ".is_template" ]; then
    local value=$(cat "$file" | sed -n 's/.*"is_template":[ ]*\([a-z]*\).*/\1/p')
    echo "$value"
  else
    echo ""
  fi
}

# Setup function to run before each test
setup() {
  export GITHUB_OUTPUT=$(mktemp)
}

# Teardown function to clean up after each test
teardown() {
  rm -f response.json "$GITHUB_OUTPUT" mock_response.json
}

@test "validate_repo_exists succeeds with HTTP 200 and is_template true" {
  echo '{"is_template": true}' > mock_response.json
  curl() { mock_curl "200" mock_response.json; }
#  jq() { mock_jq ".is_template" mock_response.json; }

  jq() { 
    local flag="$1"
    local field="$2"
    local file="$3"

    if [ "$flag" = "-r" ]; then
      mock_jq "$field" "$file"
    else
      mock_jq "$flag" "$field"
    fi
  }

  export -f curl
  export -f jq

  run validate_repo_exists "test-repo" "fake-token" "test-owner"

  [ "$status" -eq 0 ]
  [ "$(grep 'result' "$GITHUB_OUTPUT")" == "result=success" ]
  [ "$(grep 'repo-exists' "$GITHUB_OUTPUT")" == "repo-exists=true" ]
  [ "$(grep 'is-template-repo' "$GITHUB_OUTPUT")" == "is-template-repo=true" ]
}

@test "validate_repo_exists succeeds with HTTP 200 and is_template false" {
  echo '{"is_template": false}' > mock_response.json
  curl() { mock_curl "200" mock_response.json; }

#  jq() { mock_jq ".is_template" mock_response.json; }

  jq() { 
    local flag="$1"
    local field="$2"
    local file="$3"

    if [ "$flag" = "-r" ]; then
      mock_jq "$field" "$file"
    else
      mock_jq "$flag" "$field"
    fi
  }

  export -f curl
  export -f jq

  run validate_repo_exists "test-repo" "fake-token" "test-owner"

  [ "$status" -eq 0 ]
  [ "$(grep 'result' "$GITHUB_OUTPUT")" == "result=success" ]
  [ "$(grep 'repo-exists' "$GITHUB_OUTPUT")" == "repo-exists=true" ]
  [ "$(grep 'is-template-repo' "$GITHUB_OUTPUT")" == "is-template-repo=false" ]
}

@test "validate_repo_exists fails with HTTP 404" {
  echo '{"message": "Not Found"}' > mock_response.json
  curl() { mock_curl "404" mock_response.json; }
  export -f curl

  run validate_repo_exists "test-repo" "fake-token" "test-owner"

  [ "$status" -eq 0 ]
  [ "$(grep 'result' "$GITHUB_OUTPUT")" == "result=success" ]
  [ "$(grep 'repo-exists' "$GITHUB_OUTPUT")" == "repo-exists=false" ]
  [ "$(grep 'is-template-repo' "$GITHUB_OUTPUT")" == "is-template-repo=false" ]
}

@test "validate_repo_exists fails with empty repo_name" {
  run validate_repo_exists "" "fake-token" "test-owner"

  [ "$status" -eq 0 ]
  [ "$(grep 'result' "$GITHUB_OUTPUT")" == "result=failure" ]
  [ "$(grep 'error-message' "$GITHUB_OUTPUT")" == "error-message=Missing required parameters: repo_name, owner, and token must be provided." ]
}

@test "validate_repo_exists fails with empty owner" {
  run validate_repo_exists "test-repo" "fake-token" ""

  [ "$status" -eq 0 ]
  [ "$(grep 'result' "$GITHUB_OUTPUT")" == "result=failure" ]
  [ "$(grep 'error-message' "$GITHUB_OUTPUT")" == "error-message=Missing required parameters: repo_name, owner, and token must be provided." ]
}

@test "validate_repo_exists fails with empty token" {
  run validate_repo_exists "test-repo" "" "test-owner"

  [ "$status" -eq 0 ]
  [ "$(grep 'result' "$GITHUB_OUTPUT")" == "result=failure" ]
  [ "$(grep 'error-message' "$GITHUB_OUTPUT")" == "error-message=Missing required parameters: repo_name, owner, and token must be provided." ]
}

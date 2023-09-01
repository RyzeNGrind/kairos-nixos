# sync-script.sh
#!/bin/bash

# Jira to GitHub Sync
curl -X GET -H "Authorization: Bearer $(op read op://das-labs/JIRA_TOKEN/password)" -H "Content-Type: application/json" "https://dasgroup.atlassian.net/rest/api/3/issue/DEMO-1" > jira_issues.json
jq -r '.issues[] | "\(.key) \(.fields.summary)"' jira_issues.json > github_issues.txt
while read -r line; do
  issue_key=$(echo $line | cut -d' ' -f1)
  issue_summary=$(echo $line | cut -d' ' -f2-)
  curl -u "$(op read op://das-labs/GITHUB_USERNAME/username):$(op read op://das-labs/GITHUB_TOKEN/password)" https://api.github.com/repos/$(op read op://das-labs/GITHUB_USERNAME/username)/$(op read op://das-labs/GITHUB_REPO/password)/issues -d "{\"title\":\"$issue_key: $issue_summary\"}"
done < github_issues.txt

# GitHub to Plane Sync
curl -X GET -u "$(op read op://das-labs/GITHUB_USERNAME/username):$(op read op://das-labs/GITHUB_TOKEN/password)" https://api.github.com/repos/$(op read op://das-labs/GITHUB_USERNAME/username)/$(op read op://das-labs/GITHUB_REPO/password)/issues > github_issues.json
jq -r '.[] | "\(.number) \(.title)"' github_issues.json > plane_issues.txt
while read -r line; do
  issue_number=$(echo $line | cut -d' ' -f1)
  issue_title=$(echo $line | cut -d' ' -f2-)
  curl -H "Authorization: Bearer $(op read op://das-labs/PLANE_TOKEN/password)" -H "Content-Type: application/json" -d "{\"title\":\"$issue_title\"}" https://api.plane.app/v1/issues
done < plane_issues.txt

 # Plane to Jira Sync
 curl -X GET -H "Authorization: Bearer $(op read op://das-labs/PLANE_TOKEN/password)" -H "Content-Type: application/json" "https://api.plane.app/projects/$(op read op://das-labs/PLANE_PROJECT/password)/issues" > plane_issues.json
 jq -r '.issues[] | "\(.id) \(.title)"' plane_issues.json > jira_issues.txt
 while read -r line; do
   issue_id=$(echo $line | cut -d' ' -f1)
   issue_title=$(echo $line | cut -d' ' -f2-)
   curl -X POST -H "Authorization: Bearer $(op read op://das-labs/JIRA_TOKEN/password)" -H "Content-Type: application/json" "https://dasgroup.atlassian.net/rest/api/3/issue" -d "{\"fields\": {\"project\":{\"key\": \"$(op read op://das-labs/JIRA_PROJECT/password)\"},\"summary\": \"$issue_title\",\"issuetype\": {\"name\": \"Task\"}}}"
 done < jira_issues.txt


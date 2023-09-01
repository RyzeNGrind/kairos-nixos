# sync-script.sh
#!/bin/bash

# Jira to GitHub Sync
curl -X GET -H "Authorization: Bearer $(op get item JIRA_TOKEN --vault das-labs --fields password)" -H "Content-Type: application/json" "https://dasgroup.atlassian.net/rest/api/3/issue/DEMO-1" > jira_issues.json
jq -r '.issues[] | "\(.key) \(.fields.summary)"' jira_issues.json > github_issues.txt
while read -r line; do
  issue_key=$(echo $line | cut -d' ' -f1)
  issue_summary=$(echo $line | cut -d' ' -f2-)
  curl -u "$(op get item GITHUB_USERNAME --vault das-labs --fields username):$(op get item GITHUB_TOKEN --vault das-labs --fields password)" https://api.github.com/repos/$(op get item GITHUB_USERNAME --vault das-labs --fields username)/$(op get item GITHUB_REPO --vault das-labs --fields password)/issues -d "{\"title\":\"$issue_key: $issue_summary\"}"
done < github_issues.txt

# GitHub to Plane Sync
curl -X GET -u "$(op get item GITHUB_USERNAME --vault das-labs --fields username):$(op get item GITHUB_TOKEN --vault das-labs --fields password)" https://api.github.com/repos/$(op get item GITHUB_USERNAME --vault das-labs --fields username)/$(op get item GITHUB_REPO --vault das-labs --fields password)/issues > github_issues.json
jq -r '.[] | "\(.number) \(.title)"' github_issues.json > plane_issues.txt
while read -r line; do
  issue_number=$(echo $line | cut -d' ' -f1)
  issue_title=$(echo $line | cut -d' ' -f2-)
  curl -H "Authorization: Bearer $(op get item PLANE_TOKEN --vault das-labs --fields password)" -H "Content-Type: application/json" -d "{\"title\":\"$issue_title\"}" https://api.plane.app/v1/issues
done < plane_issues.txt

 # Plane to Jira Sync
 curl -X GET -H "Authorization: Bearer $(op get item PLANE_TOKEN --vault das-labs --fields password)" -H "Content-Type: application/json" "https://api.plane.app/projects/$(op get item PLANE_PROJECT --vault das-labs --fields password)/issues" > plane_issues.json
 jq -r '.issues[] | "\(.id) \(.title)"' plane_issues.json > jira_issues.txt
 while read -r line; do
   issue_id=$(echo $line | cut -d' ' -f1)
   issue_title=$(echo $line | cut -d' ' -f2-)
   curl -X POST -H "Authorization: Bearer $(op get item JIRA_TOKEN --vault das-labs --fields password)" -H "Content-Type: application/json" "https://dasgroup.atlassian.net/rest/api/3/issue" -d "{\"fields\": {\"project\":{\"key\": \"$(op get item JIRA_PROJECT --vault das-labs --fields password)\"},\"summary\": \"$issue_title\",\"issuetype\": {\"name\": \"Task\"}}}"
 done < jira_issues.txt


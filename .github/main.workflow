workflow "Add new pull requests to projects" {
  resolves = ["alex-page/add-new-pulls-project"]
  on = "pull_request"
}

action "alex-page/add-new-pulls-project" {
  uses = "alex-page/add-new-pulls-project@v0.0.4"
  args = ["Curated Terraform Modules", "To do"]
  secrets = ["GITHUB_TOKEN", "GH_PAT"]
}

workflow "Add new issues to projects" {
  resolves = ["alex-page/add-new-issue-project"]
  on = "issues"
}

action "alex-page/add-new-issue-project" {
  uses = "alex-page/add-new-issue-project@v0.0.4"
  args = ["Curated Terraform Modules", "To do"]
  secrets = ["GITHUB_TOKEN", "GH_PAT"]
}

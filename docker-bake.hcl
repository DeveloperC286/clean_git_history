group "default" {
  targets = ["check-clean-git-history"]
}

target "check-clean-git-history" {
  context = "."
  dockerfile = "ci/Dockerfile"
  tags = ["clean-git-history-check:latest"]
} 
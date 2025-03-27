region = "us-west-2"

lifecycle_policy = {
  rules = [
    {
      "rulePriority" : 1,
      "description" : "Keep last 5 images",
      "selection" : {
        "tagStatus" : "any",
        "countType" : "imageCountMoreThan",
        "countNumber" : 5
      },
      "action" : {
        "type" : "expire"
      }
    }
  ]
}

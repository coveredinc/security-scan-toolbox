region = "us-west-1"

lifecycle_policy = {
  rules = [
    {
      "rulePriority" : 1,
      "description" : "Keep preview images for 7 days",
      "selection" : {
        "countNumber" : 7,
        "countType" : "sinceImagePushed",
        "countUnit" : "days",
        "tagStatus" : "any"
      },
      "action" : {
        "type" : "expire"
      }
    }
  ]
}

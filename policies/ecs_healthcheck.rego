package trivy.ecs.healthcheck

# This rule will trigger a denial if any container in an ECS task definition is missing a health check.
deny[msg] {
  # We assume the resource is an AWS ECS task definition.
  resource := input.resource
  resource.type == "aws_ecs_task_definition"

  # Parse the container_definitions JSON. Adjust the path based on how your input is structured.
  container_definitions := parse_json(resource.values.container_definitions)

  # Iterate over each container in the task.
  container := container_definitions[_]

  # If the container does not have a healthCheck key, then trigger a failure.
  not container.healthCheck

  # Compose an informative message.
  msg := sprintf("Container '%s' is missing a health check", [container.name])
}
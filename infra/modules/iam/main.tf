resource "aws_iam_role" "ecs_task_role" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = { Service = "ecs-tasks.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution" {
  role = aws_iam_role.ecs_task_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy" "ecs_task_ecr_policy" {
  name = "ecsTaskECRPullPolicy"
  role = aws_iam_role.ecs_task_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability"
        ]
        Resource = "arn:aws:ecr:us-east-1:677276078111:repository/*"
      }
    ]
  })
}


# ECS Task Execution: ECS requires a task execution role to push logs to CloudWatch. 
# You'll need to define an IAM role with permissions to push logs to CloudWatch
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs-task-execution-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Effect = "Allow"
        Sid    = ""
      },
    ]
  })
}

resource "aws_iam_policy" "ecs_cloudwatch_policy" {
  name = "ecs-cloudwatch-logs-policy"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "logs:CreateLogStream"
        Effect   = "Allow"
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Action   = "logs:PutLogEvents"
        Effect   = "Allow"
        Resource = "arn:aws:logs:*:*:log-group:/ecs/*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_cloudwatch_attachment" {
  policy_arn = aws_iam_policy.ecs_cloudwatch_policy.arn
  role       = aws_iam_role.ecs_task_execution_role.name
}


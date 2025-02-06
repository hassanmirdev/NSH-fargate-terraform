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
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "cloudwatch:PutMetricData"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetRepositoryPolicy",
        "ecr:BatchGetImage",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "ecr:PutImage"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::prometheus-cloud/*"
    }
  ]
  })
}

resource "aws_iam_policy" "ecs_logging_xray_policy" {
  name        = "ecs_logging_xray_policy"
  description = "Allows ECS tasks to send logs to CloudWatch and traces to X-Ray"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow"
        Action = [
          "xray:PutTraceSegments",
          "xray:PutTelemetryRecords"
        ]
        Resource = "*"
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

resource "aws_iam_role" "ecs_execution_role" {
  name = "ecs-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Effect = "Allow"
        Sid     = ""
      }
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
      {
        Action   = "cloudwatch:PutMetricData"
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_cloudwatch_attachment" {
  policy_arn = aws_iam_policy.ecs_cloudwatch_policy.arn
  role       = aws_iam_role.ecs_task_execution_role.name
}

resource "aws_iam_role" "ecs_xray_role" {
  name = "ecs-xray-role"

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

# Set Up AWS X-Ray for Application Tracing
resource "aws_iam_policy" "xray_policy" {
  name = "ecs-xray-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "xray:PutTelemetryRecords"
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action   = "xray:PutTraceSegments"
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "xray_policy_attachment" {
  policy_arn = aws_iam_policy.xray_policy.arn
  role       = aws_iam_role.ecs_xray_role.name
}

resource "aws_iam_policy" "cloudwatch_agent_policy" {
  name = "ecs-cloudwatch-agent-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = [
          "cloudwatch:PutMetricData",
          "cloudwatch:ListMetrics"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cloudwatch_agent_policy_attachment" {
  policy_arn = aws_iam_policy.cloudwatch_agent_policy.arn
  role       = aws_iam_role.ecs_task_execution_role.name
}
resource "aws_iam_role_policy_attachment" "ecs_execution_attach_logging" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_iam_role_policy_attachment" "ecs_execution_attach_xray" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
}

resource "aws_iam_role_policy_attachment" "ecs_s3_read_policy" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}


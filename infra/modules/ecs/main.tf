resource "aws_ecs_cluster" "main" {
  name = var.cluster_name

  setting {                          #Enable Container Insights in ECS Cluster:
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_task_definition" "appointment_service" {
  family                   = var.task_name
  cpu                      = 512
  memory                   = 1024
  container_definitions    = jsonencode([{
    name       = var.appointment_container_name
    image      = var.image_url
    memory     = 512
    cpu        = 256
    essential  = true
    portMappings = [
      {
        containerPort = 3001
        hostPort      = 3001
        protocol      = "tcp"
      }
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.ecs_logs.name
        "awslogs-region"        = "us-east-1"
        "awslogs-stream-prefix" = "ecs"
      }
    }
  }, {
    # CloudWatch Agent sidecar container definition
    name      = "cloudwatch-agent"
    image     = "amazon/cloudwatch-agent:latest"
    cpu       = 50
    memory    = 128
    essential = false
    environment = [
      {
        name  = "CW_CONFIG_CONTENT"
        value = filebase64("${path.module}/../../environments/dev/cloudwatch-config.json")        
#value = filebase64("cloudwatch-config.json")  # Reference the CloudWatch config file
      }
    ]
    mountPoints = [
      {
        sourceVolume = "cloudwatch-config-volume"
        containerPath = "/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json"
      }
    ]
  }, {
    # X-Ray Daemon sidecar container definition
    name      = "xray-daemon"
    image     = "amazon/aws-xray-daemon"
    cpu       = 50
    memory    = 128
    essential = false
    portMappings = [
      {
        containerPort = 2000
        hostPort      = 2000
      }
    ]
    environment = [
      {
        name  = "AWS_XRAY_DAEMON_ADDRESS"
        value = "xray.us-east-1.amazonaws.com:2000"
      },
      {
        name  = "AWS_XRAY_TRACING_NAME"
        value = "appointment-service-trace"
      },
      {
        name  = "AWS_XRAY_DAEMON_DISABLE_METADATA"
        value = "true"
      }
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.ecs_logs.name
        awslogs-region        = "us-east-1"
        awslogs-stream-prefix = "xray"
      }
    }
  }])

  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  execution_role_arn       = var.execution_role

  tags = {
    Name = var.task_name
  }

  volume {
    name = "cloudwatch-config-volume"
    host_path {
      path = "/opt/aws/amazon-cloudwatch-agent/etc/"
    }
  }
}
resource "aws_ecs_task_definition" "patient_service" {
  family                   = var.task_name
  cpu                      = 512
  memory                   = 1024
  container_definitions    = jsonencode([{
    name       = var.patient_container_name
    image      = var.image_url_patient
    memory     = 512
    cpu        = 256   
    essential  = true
    portMappings = [
      {
        containerPort = 3000
        hostPort      = 3000
        protocol      = "tcp"
      }
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.ecs_logs.name
        "awslogs-region"        = "us-east-1"
        "awslogs-stream-prefix" = "ecs"
      }
    }
  }, {
    # CloudWatch Agent sidecar container definition
    name      = "cloudwatch-agent"
    image     = "amazon/cloudwatch-agent:latest"
    cpu       = 50
    memory    = 128
    essential = false
    environment = [
      {
        name  = "CW_CONFIG_CONTENT"
        value = filebase64("${path.module}/../../environments/dev/cloudwatch-config.json")
       # value = filebase64("cloudwatch-config.json")  # Reference the CloudWatch config file
      }
    ]
    mountPoints = [
      {
        sourceVolume = "cloudwatch-config-volume"
        containerPath = "/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json"
      }
    ]
  }, {
    # X-Ray Daemon sidecar container definition
    name      = "xray-daemon"
    image     = "amazon/aws-xray-daemon"
    cpu       = 50
    memory    = 128
    essential = false
    portMappings = [
      {
        containerPort = 2000
        hostPort      = 2000
      }
    ]
    environment = [
      {
        name  = "AWS_XRAY_DAEMON_ADDRESS"
        value = "xray.us-east-1.amazonaws.com:2000"
      },
      {
        name  = "AWS_XRAY_TRACING_NAME"
        value = "patient-service-trace"
      },
      {
        name  = "AWS_XRAY_DAEMON_DISABLE_METADATA"
        value = "true"
      }
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.ecs_logs.name
        awslogs-region        = "us-east-1"
        awslogs-stream-prefix = "xray"
      }
    }
  }])

  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  execution_role_arn       = var.execution_role

  tags = {
    Name = var.task_name
  }

  volume {
    name = "cloudwatch-config-volume"
    host_path {
      path = "/opt/aws/amazon-cloudwatch-agent/etc/"
    }
  }
}

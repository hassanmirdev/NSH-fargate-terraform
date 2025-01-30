resource "aws_security_group" "app_alb_sg" {
  name_prefix = "app-alb-sg"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0          # Allow all ports for egress traffic
    to_port     = 0          # Allow all ports for egress traffic
    protocol    = "-1"       # All protocols
    cidr_blocks = ["0.0.0.0/0"]  # Allow traffic to anywhere
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow HTTP traffic from anywhere
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow HTTPS traffic from anywhere
  }
  
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow HTTPS traffic from anywhere
  }

  ingress {
    from_port   = 3001
    to_port     = 3001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow HTTPS traffic from anywhere
  }

  tags = {
    Name = "app-alb-sg"
  }
}


resource "aws_lb" "app_alb" {
  name               = var.alb_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.app_alb_sg.id]
  subnets            = var.subnets
  enable_deletion_protection = false
  enable_cross_zone_load_balancing = true
  enable_http2               = true

  tags = {
    Name = var.alb_name
  }
}

resource "aws_lb_target_group" "patient_tg" {
  name     = "patient-tg"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type = "ip"
  health_check {
    path                = "/health"      # Define the health check path
    protocol            = "HTTP"
    interval            = 30              # Health check interval (seconds)
    timeout             = 5               # Timeout for health check (seconds)
    healthy_threshold   = 3               # Consecutive healthy checks before considering healthy
    unhealthy_threshold = 3               # Consecutive unhealthy checks before considering unhealthy
    matcher             = "200"           # Health check response code (can be a specific code or range)
  }
}

resource "aws_lb_target_group" "appointment_tg" {
  name     = "appointment-tg"
  port     = 3001
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type = "ip"
  health_check {
    path                = "/health"      # Define the health check path
    protocol            = "HTTP"
    interval            = 30              # Health check interval (seconds)
    timeout             = 5               # Timeout for health check (seconds)
    healthy_threshold   = 3               # Consecutive healthy checks before considering healthy
    unhealthy_threshold = 3               # Consecutive unhealthy checks before considering unhealthy
    matcher             = "200"           # Health check response code (can be a specific code or range)
  }
}

# Define a single listener for HTTP traffic on port 80
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      status_code = 200
      content_type = "text/plain"
      message_body = "Welcome to the Service"
    }
  }
}

# Listener rule for Appointment Service
resource "aws_lb_listener_rule" "appointment_rule" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 10

  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.appointment_tg.arn
  }

  condition {
    path_pattern {
      values = ["/appointments"]
    }
  }
}

# Listener rule for Patient Service
resource "aws_lb_listener_rule" "patient_rule" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 20

  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.patient_tg.arn
  }

  condition {
    path_pattern {
      values = ["/patients"]
    }
  }
}

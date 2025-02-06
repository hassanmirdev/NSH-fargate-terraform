output "alb_dns_name" {
  value = aws_lb.app_alb.dns_name
}

output "sg_id" {
  description = "List of security group IDs for ALB"
  value       = [aws_security_group.app_alb_sg.id]  # Ensure it's a list
}

output "appointment_tg_arn" {
  value = aws_lb_target_group.appointment_tg.arn
}

output "patient_tg_arn" {
  value = aws_lb_target_group.patient_tg.arn
}

output "prometheus_tg_arn" {
  value = aws_lb_target_group.prometheus.arn
}


output "grafana_tg_arn" {
  value = aws_lb_target_group.grafana.arn
}

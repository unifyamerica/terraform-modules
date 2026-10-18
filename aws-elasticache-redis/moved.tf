# Preserve existing consumers when the legacy ingress rule becomes optional.
moved {
  from = aws_security_group_rule.redis_ingress_from_sg
  to   = aws_security_group_rule.redis_ingress_from_sg[0]
}

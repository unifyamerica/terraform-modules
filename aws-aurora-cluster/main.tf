resource "aws_db_subnet_group" "this" {
  name       = "${var.environment}-${var.cluster_id}"
  subnet_ids = var.private_subnets
  tags       = var.tags
}

resource "aws_rds_cluster" "this" {
  cluster_identifier      = "${var.environment}-${var.cluster_id}-cluster"
  engine                  = "aurora-postgresql"
  engine_mode             = "provisioned"
  engine_version          = var.engine_version

  database_name           = var.db_name
  db_subnet_group_name    = aws_db_subnet_group.this.name
  skip_final_snapshot     = true

  apply_immediately       = var.apply_immediately
  snapshot_identifier     = var.snapshot_identifier
  tags                    = var.tags
}

resource "aws_rds_cluster_instance" "this" {
  count              = var.instance_count
  identifier         = "${var.environment}-${var.cluster_id}-instance-${count.index}"
  cluster_identifier = aws_rds_cluster.this.id
  instance_class     = var.db_instance_class
  engine             = aws_rds_cluster.this.engine
  publicly_accessible = false
  tags                = var.tags
}

resource "aws_appautoscaling_target" "this" {
  count = var.autoscaling_enabled ? 1 : 0

  max_capacity       = var.autoscaling_max_capacity
  min_capacity       = var.autoscaling_min_capacity
  resource_id        = "cluster:${aws_rds_cluster.this.id}"
  scalable_dimension = "rds:cluster:ReadReplicaCount"
  service_namespace  = "rds"

  tags = var.tags

  lifecycle {
    ignore_changes = [
      tags_all,
    ]
  }
}

resource "aws_appautoscaling_policy" "this" {
  count = var.autoscaling_enabled ? 1 : 0

  name               = var.autoscaling_policy_name
  policy_type        = "TargetTrackingScaling"
  resource_id        = "cluster:${aws_rds_cluster.this.id}"
  scalable_dimension = "rds:cluster:ReadReplicaCount"
  service_namespace  = "rds"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = var.predefined_metric_type
    }

    scale_in_cooldown  = var.autoscaling_scale_in_cooldown
    scale_out_cooldown = var.autoscaling_scale_out_cooldown
    target_value       = var.predefined_metric_type == "RDSReaderAverageCPUUtilization" ? var.autoscaling_target_cpu : var.autoscaling_target_connections
  }

  depends_on = [
    aws_appautoscaling_target.this
  ]
}

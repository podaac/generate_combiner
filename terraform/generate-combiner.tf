# ECR
resource "aws_ecr_repository" "combiner" {
  name = "${var.prefix}-combiner"
  image_scanning_configuration {
    scan_on_push = true
  }
  image_tag_mutability = "MUTABLE"
  encryption_configuration {
    encryption_type = "AES256"
  }
}

# Job Definition
resource "aws_batch_job_definition" "generate_batch_jd_combiner" {
  name                  = "${var.prefix}-combiner"
  type                  = "container"
  container_properties  = <<CONTAINER_PROPERTIES
  {
    "image": "${aws_ecr_repository.combiner.repository_url}:latest",
    "jobRoleArn": "${data.aws_iam_role.batch_job_role.arn}",
    "logConfiguration": {
        "logDriver" : "awslogs",
        "options": {
            "awslogs-group" : "${data.aws_cloudwatch_log_group.cw_log_group.name}"
        }
    },
    "mountPoints": [
        {
            "sourceVolume": "combiner",
            "containerPath": "/data",
            "readOnly": false
        },
        {
            "sourceVolume": "processor",
            "containerPath": "/data/scratch",
            "readOnly": false
        }
    ],
    "resourceRequirements" : [
        { "type": "MEMORY", "value": "1024"},
        { "type": "VCPU", "value": "1024" }
    ],
    "volumes": [
        {
            "name": "combiner",
            "efsVolumeConfiguration": {
            "fileSystemId": "${data.aws_efs_file_system.aws_efs_generate.file_system_id}",
            "rootDirectory": "/combiner"
            }
        },
        {
            "name": "processor",
            "efsVolumeConfiguration": {
            "fileSystemId": "${data.aws_efs_file_system.aws_efs_generate.file_system_id}",
            "rootDirectory": "/processor/input"
            }
        }
    ]
  }
  CONTAINER_PROPERTIES
  platform_capabilities = ["EC2"]
  propagate_tags        = true
  retry_strategy {
    attempts = 3
  }
}
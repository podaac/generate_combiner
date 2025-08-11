# Job Definition
resource "aws_batch_job_definition" "generate_batch_jd_combiner" {
  name                  = "${var.prefix}-combiner"
  type                  = "container"
  container_properties  = <<CONTAINER_PROPERTIES
  {
    "image": "${data.aws_ecr_repository.combiner.repository_url}:latest",
    "jobRoleArn": "${data.aws_iam_role.batch_job_role.arn}",
    "executionRoleArn": "${data.aws_iam_role.batch_ecs_execution_role.arn}",
    "environment": [
        {
            "name": "AWS_DEFAULT_REGION",
            "value": "us-west-2"
        }
    ],
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
        { "type": "MEMORY", "value": "2048"},
        { "type": "VCPU", "value": "1" }
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
  platform_capabilities = ["FARGATE"]
  propagate_tags        = true
  retry_strategy {
    attempts = 3
  }
}
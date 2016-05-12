[
  {
    "name": "jenkins",
    "image": "${jenkins_repository_url}",
    "cpu": 128,
    "memory": 1024,
    "essential": true,
    "portMappings": [
      {
        "containerPort": 8080,
        "hostPort": 8080
      },
      {
        "containerPort": 50000,
        "hostPort": 50000
      }
    ],
    "mountPoints": [
      {
        "sourceVolume": "jenkins-home",
        "containerPath": "/var/jenkins_home"
      }
    ]
  },
  {
    "name": "jenkins-backup",
    "image": "istepanov/backup-to-s3",
    "memory": 128,
    "cpu": 10,
    "essential": false,
    "environment": [
      {
        "name": "ACCESS_KEY",
        "value": "${aws_access_key}"
      },
      {
        "name": "SECRET_KEY",
        "value": "${aws_secret_key}"
      },
      {
        "name": "S3_PATH",
        "value": "s3://${s3_bucket}/jenkins/"
      },
      {
        "name": "CRON_SCHEDULE",
        "value": "0 12 * * *"
      }
    ],
    "mountPoints": [
      {
        "sourceVolume": "jenkins-home",
        "containerPath": "/data"
      }
    ]
  }
]

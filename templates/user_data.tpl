#!/bin/bash

echo ECS_CLUSTER='${ecs_cluster_name}' > /etc/ecs/ecs.config

# Create and set correct permissions for Jenkins mount directory
jenkins_host_dir=/ecs/jenkins-home
mkdir -p $jenkins_host_dir
chmod -R 777 $jenkins_host_dir
h
if ${restore_backup}
then
    docker run \
    --env aws_key=${access_key} \
    --env aws_secret=${secret_key} \
    --env cmd=sync-s3-to-local \
    --env SRC_S3=s3://${s3_bucket}/${ecs_cluster_name}/jenkins-home/  \
    -v /ecs/jenkins-home:/opt/dest \
    garland/docker-s3cmd
fi

# Create cron job for data backup as ec2-user
su ec2-user <<'EOF'
(crontab -l 2>/dev/null; echo "0 */2 * * *      /usr/bin/docker run --rm --env aws_key=${access_key} --env aws_secret=${secret_key} --env cmd=sync-local-to-s3 --env DEST_S3=s3://${s3_bucket}/${ecs_cluster_name}/ -v /ecs/jenkins-home:/opt/src/jenkins-home garland/docker-s3cmd") | crontab -
EOF

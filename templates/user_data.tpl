#!/bin/bash

echo ECS_CLUSTER='${ecs_cluster_name}' > /etc/ecs/ecs.config

# Create and set correct permissions for Jenkins mount directory
sudo mkdir -p ${jenkins_host_dir}
sudo chmod -R 777 ${jenkins_host_dir}

# Install and configure Weave Scope
# sudo wget -O /usr/local/bin/scope https://git.io/scope
# sudo chmod a+x /usr/local/bin/scope
# sudo scope launch
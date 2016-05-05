#!/bin/bash

repository_url=`echo $1 | sed 's~http[s]*://~~g'`
image_name=$2

eval $(aws ecr get-login --region us-east-1)

# If the image doesn't exists, we build it and push it to the repository.
if [[ "$(docker images -q ${repository_url} 2> /dev/null)" == "" ]]; then
  docker build -t ${image_name} .
  docker tag ${image_name}:latest ${repository_url}:latest
  docker push ${repository_url}:latest
fi

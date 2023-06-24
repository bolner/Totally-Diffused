#!/usr/bin/env bash

docker stop totally-diffused 2>/dev/null 2>&1
docker image rm totally-diffused --force
docker system prune --force

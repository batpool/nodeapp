#!/bin/bash
sed "s/tagVersion/$1/g" deployments.yml > node-app-deployments.yml
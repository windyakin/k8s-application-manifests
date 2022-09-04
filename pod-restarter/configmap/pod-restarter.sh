#!/bin/sh

kubectl get deployments -o=jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' | xargs -I "{}" kubectl rollout restart deployments {}

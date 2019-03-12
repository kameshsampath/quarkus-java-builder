#!/bin/bash

set -eu

KNATIVE_BUILD_VERSION=${KNATIVE_BUILD_VERSION:-v0.4.0}


minikube start -p quarkus-java-builder-demo \
  --memory=8192 \
  --cpus=4 \
  --kubernetes-version=v1.12.0 \
  --vm-driver=hyperkit \
  --disk-size=50g \
  --extra-config=apiserver.enable-admission-plugins="LimitRanger,NamespaceExists,NamespaceLifecycle,ResourceQuota,ServiceAccount,DefaultStorageClass,MutatingAdmissionWebhook"

kubectl apply --filename https://github.com/knative/build/releases/download/${KNATIVE_BUILD_VERSION}/build.yaml
# TODO just to make sure all missing ones are upated - just to avoid  errors/warnings
kubectl apply --filename https://github.com/knative/build/releases/download/${KNATIVE_BUILD_VERSION}/build.yaml

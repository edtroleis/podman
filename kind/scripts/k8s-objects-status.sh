#!/bin/bash

echo "🔍 Checking current Kubernetes resources..."
echo ""

echo "📋 Resources in system1 namespace:"
kubectl get all,pvc,ingress,cronjobs -n system1 2>/dev/null || echo "   No resources found in system1 namespace"

echo ""
echo "🗄️  Persistent Volumes (cluster-wide):"
kubectl get pv | grep -E "(simple-app|NAME)" || echo "   No simple-app persistent volumes found"

echo ""
echo "🌐 Ingress Controllers:"
kubectl get pods -n ingress-nginx 2>/dev/null | head -3 || echo "   No ingress-nginx namespace found"

echo ""
echo "📊 Summary of all namespaces with resources:"
kubectl get namespaces --show-labels | grep -E "(NAME|system1)"

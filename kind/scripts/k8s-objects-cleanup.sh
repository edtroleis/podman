#!/bin/bash

echo "🗑️  Deleting Kubernetes objects in system1 namespace..."

# Function to check if a resource exists before trying to delete it
check_and_delete() {
    local resource_type=$1
    local resource_name=$2
    local namespace=${3:-"system1"}
    
    if kubectl get $resource_type $resource_name -n $namespace &> /dev/null; then
        echo "   Deleting $resource_type/$resource_name..."
        kubectl delete $resource_type $resource_name -n $namespace
    else
        echo "   $resource_type/$resource_name not found, skipping..."
    fi
}

# Function to delete by file if it exists
delete_by_file() {
    local file=$1
    if [ -f "$file" ]; then
        echo "   Deleting resources from $file..."
        kubectl delete -f "$file" --ignore-not-found=true
    else
        echo "   File $file not found, skipping..."
    fi
}

echo ""
echo "📋 Step 1: Deleting CronJob and Jobs..."
check_and_delete "cronjob" "simple-maintenance-cronjob"
check_and_delete "job" "simple-backup-job"

# Delete any jobs created by the cronjob
echo "   Deleting any cronjob-created jobs..."
kubectl delete jobs -n system1 -l app=maintenance-job --ignore-not-found=true

echo ""
echo "🌐 Step 2: Deleting Ingress..."
check_and_delete "ingress" "simple-app-ingress"

echo ""
echo "🔗 Step 3: Deleting Service..."
check_and_delete "service" "simple-app-service"

echo ""
echo "📦 Step 4: Deleting Deployment..."
check_and_delete "deployment" "simple-app"

echo ""
echo "💾 Step 5: Deleting Persistent Volume Claim..."
check_and_delete "pvc" "simple-app-pvc"

echo ""
echo "🗄️  Step 6: Deleting Persistent Volume..."
# PV is cluster-scoped, no namespace needed
if kubectl get pv simple-app-pv &> /dev/null; then
    echo "   Deleting pv/simple-app-pv..."
    kubectl delete pv simple-app-pv
else
    echo "   pv/simple-app-pv not found, skipping..."
fi

echo ""
echo "🏷️  Step 7: Deleting Namespace (optional - uncomment if desired)..."
# Uncomment the next line if you want to delete the entire namespace
kubectl delete namespace system1 --ignore-not-found=true

echo ""
echo "🎛️  Step 8: Deleting NGINX Ingress Controller (optional - uncomment if desired)..."
echo "   Note: This will affect other applications using the ingress controller"
# Uncomment the next line if you want to remove the ingress controller entirely
kubectl delete -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml --ignore-not-found=true

echo ""
echo "🧹 Step 9: Cleaning up completed and failed pods..."
kubectl delete pods -n system1 --field-selector=status.phase=Succeeded --ignore-not-found=true
kubectl delete pods -n system1 --field-selector=status.phase=Failed --ignore-not-found=true

echo ""
echo "✅ Cleanup completed!"
echo ""
echo "📊 Remaining resources in system1 namespace:"
kubectl get all -n system1 2>/dev/null || echo "   No resources found or namespace doesn't exist"

echo ""
echo "💡 To verify complete cleanup, run:"
echo "   kubectl get all,pvc,pv,ingress,jobs,cronjobs -n system1"
echo "   kubectl get pv | grep simple-app"

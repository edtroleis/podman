#!/bin/bash

echo "🚀 Deploying Kubernetes objects to system1 namespace..."

# Set the path to the k8s YAML files (relative to this script)
K8S_DIR="../k8s"

# Function to apply a file with error checking and feedback
apply_file() {
    local file=$1
    local description=$2
    local full_path="$K8S_DIR/$file"
    
    if [ ! -f "$full_path" ]; then
        echo "   ❌ File $full_path not found, skipping..."
        return 1
    fi
    
    echo "   📄 Applying $full_path ($description)..."
    if kubectl apply -f "$full_path"; then
        echo "   ✅ Successfully applied $full_path"
    else
        echo "   ❌ Failed to apply $full_path"
        return 1
    fi
}

# Function to check if ingress controller is already installed
check_ingress_controller() {
    if kubectl get namespace ingress-nginx &> /dev/null; then
        echo "   ℹ️  NGINX Ingress Controller namespace already exists"
        if kubectl get pods -n ingress-nginx -l app.kubernetes.io/component=controller --no-headers | grep -q "Running"; then
            echo "   ✅ NGINX Ingress Controller is already running"
            return 0
        else
            echo "   ⚠️  NGINX Ingress Controller exists but may not be ready"
            return 1
        fi
    else
        echo "   📦 NGINX Ingress Controller not found, will install..."
        return 1
    fi
}

# Function to wait for ingress controller with better feedback
wait_for_ingress_controller() {
    echo "   ⏳ Waiting for NGINX Ingress Controller to be ready (timeout: 90s)..."
    
    local timeout=90
    local elapsed=0
    local interval=5
    
    while [ $elapsed -lt $timeout ]; do
        if kubectl get pods -n ingress-nginx -l app.kubernetes.io/component=controller --no-headers 2>/dev/null | grep -q "1/1.*Running"; then
            echo "   ✅ NGINX Ingress Controller is ready!"
            return 0
        fi
        
        echo "   ⌛ Still waiting... ($elapsed/$timeout seconds)"
        sleep $interval
        elapsed=$((elapsed + interval))
    done
    
    echo "   ⚠️  Timeout waiting for ingress controller, but continuing..."
    return 1
}

echo ""
echo "🏷️  Step 1: Creating Namespace..."
apply_file "namespace.yaml" "Namespace for system1"

echo ""
echo "💾 Step 2: Setting up Persistent Storage..."
apply_file "pv.yaml" "Persistent Volume"
apply_file "pvc.yaml" "Persistent Volume Claim"

echo ""
echo "📦 Step 3: Deploying Application..."
apply_file "deployment.yaml" "Application Deployment"

echo ""
echo "🔗 Step 4: Creating Service..."
apply_file "service.yaml" "Service for load balancing"

echo ""
echo "🌐 Step 5: Setting up Ingress..."
if ! check_ingress_controller; then
    echo "   📦 Installing NGINX Ingress Controller..."
    if kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml; then
        echo "   ✅ NGINX Ingress Controller installation initiated"
        wait_for_ingress_controller
    else
        echo "   ❌ Failed to install NGINX Ingress Controller"
    fi
fi

apply_file "ingress.yaml" "Ingress rules"

echo ""
echo "⚡ Step 6: Creating Jobs..."
apply_file "job.yaml" "One-time backup Job"
apply_file "cronjob.yaml" "Scheduled maintenance CronJob"

echo ""
echo "🧪 Step 7: Verification and Setup..."
echo "   Waiting for deployment to be ready..."
kubectl wait --for=condition=available deployment/simple-app -n system1 --timeout=60s

echo ""
echo "   📄 Creating initial web content..."
if kubectl exec -n system1 deployment/simple-app -- sh -c 'echo "<h1>Hello from Kubernetes!</h1><p>This application is running with persistent storage.</p><p>Setup completed successfully at $(date)</p>" > /usr/share/nginx/html/index.html' 2>/dev/null; then
    echo "   ✅ Initial content created successfully"
else
    echo "   ⚠️  Could not create initial content (deployment may still be starting)"
fi

echo ""
echo "   Checking deployment status..."
kubectl get pods -n system1 --no-headers 2>/dev/null | head -3 || echo "   No pods found yet"

echo ""
echo "   Checking services..."
kubectl get svc -n system1 --no-headers 2>/dev/null || echo "   No services found"

echo ""
echo "   Checking ingress..."
kubectl get ingress -n system1 --no-headers 2>/dev/null || echo "   No ingress found"

echo ""
echo "✅ Deployment completed!"
echo ""
echo "📋 Quick Status Summary:"
kubectl get all,pvc,ingress -n system1 2>/dev/null || echo "   Unable to fetch status"

echo ""
echo "🌐 Access Information:"
echo "   Application URL: http://localhost:9090"

echo ""
echo "🔌 Testing connectivity..."
if curl -s --max-time 10 http://localhost:9090 | grep -q "Hello from Kubernetes"; then
    echo "   ✅ Application is accessible and responding correctly!"
else
    echo "   ⚠️  Application may not be ready yet. Try again in a few minutes."
    echo "   💡 You can check status with: kubectl get pods -n system1"
fi

echo ""
echo "💡 Useful commands:"
echo "   Check status: ./k8s-objects-status.sh"
echo "   View logs: kubectl logs -n system1 -l app=simple-app"
echo "   Test application: curl http://localhost:9090"
echo "   Cleanup: ./k8s-objects-cleanup.sh"

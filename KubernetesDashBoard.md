# Kubernetes Dashboard Setup on GCP Ubuntu VM

## 1. Install Helm

```
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
sudo apt-get install apt-transport-https --yes
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm
```

## 2. Add Kubernetes Dashboard Helm Repo and Install Dashboard

```
helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
helm upgrade --install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard --create-namespace --namespace kubernetes-dashboard
```

## 3. Check Your Public IP (optional)

```
curl icanhazip.com
```

## Access via 
```
https://localhost:8443
```

# On local machine 


## 5. Change Dashboard Service to NodePort (for external access)

```
kubectl -n kubernetes-dashboard patch svc kubernetes-dashboard-kong-proxy -p '{"spec": {"type": "NodePort"}}'
kubectl -n kubernetes-dashboard get svc kubernetes-dashboard-kong-proxy
```

### Access the DashBoard via 

#### https://<your-vm-external-ip>:<NodePort>

## 6. Create admin-user ServiceAccount and ClusterRoleBinding for Dashboard access

```
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard
EOF
```

## 7. Generate Dashboard Login Token

```
kubectl -n kubernetes-dashboard create token admin-user
```

#### NOW LOGIN VIA TOKEN ACCESS


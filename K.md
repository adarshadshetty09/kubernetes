Statefulsets with Dynamically Provisioned Volumes


apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: dynamic-pv-example
spec:
  resources:
    requests:
      storage: 1Gi
  volumeMode: Filesystem
  storageClassName: standard
  accessModes:
    - ReadWriteOnce



Apply the stateful-set.yaml file 

kubectl apply -f stateful-set.yaml 

kubectl get pod 
kubectl get pvc
kubectl describe pod local-volume-ss-0


ssh into minikube 

cd /tmp/hostpath-provisioner/default/
You will find the two files here. 

kubectl delete pvc --all
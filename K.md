Dynamically Provisioning the persistent volume.


Kubectl get storageclass 

kubectl describe storageclass standard(default)

Read all the information


dynamic.yml 

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


Apply this file dynamic.yml 

kubectl get pvc
kubectl describe pv <pv volume ID>




minikube ssh 

cd /tmp/hostpath-provisioner/default/
ls 

dynami-pv-example   you will find this 

exit


kubectl get storageclass standard -o yaml 

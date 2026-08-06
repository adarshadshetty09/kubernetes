Handson on the mountung the volume to the POD.


apiVersion: v1
kind: PersistentVolume
metadata:
  name: local-volume
spec:
  capacity:
    storage: 1Gi
  volumeMode: Filesystem
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: local-storage
  local:
    path: /mnt/disks/local1
  nodeAffinity:
    required:
      nodeSelectorTerms:
        - matchExpressions:
            - key: kubernetes.io/hostname
              operator: In
              values: ['minikube']
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: local-volume-claim
spec:
  resources:
    requests:
      storage: 1Gi
  volumeMode: Filesystem
  accessModes:
    - ReadWriteOnce
  storageClassName: local-storage
---
apiVersion: v1
kind: Pod
metadata:
  name: local-vol-pod
  labels:
    name: local-vol-pod
spec:
  containers:
    - name: local-vol
      image: busybox:1.36.1
      command:
        - 'sh'
        - '-c'
        - 'sleep 3600'
      resources:
        limits:
          memory: '128Mi'
          cpu: '500m'
      volumeMounts:
        - name: local-volume
          mountPath: /mnt/local
  volumes:
    - name: local-volume
      persistentVolumeClaim:
        claimName: local-volume-claim
---
apiVersion: v1
kind: Pod
metadata:
  name: local-vol-pod2
  labels:
    name: local-vol-pod2
spec:
  containers:
    - name: local-vol
      image: busybox:1.36.1
      command:
        - 'sh'
        - '-c'
        - 'sleep 3600'
      resources:
        limits:
          memory: '128Mi'
          cpu: '500m'
      volumeMounts:
        - name: local-volume
          mountPath: /mnt/local2
  volumes:
    - name: local-volume
      persistentVolumeClaim:
        claimName: local-volume-claim



kubectl apply file.yaml 

kubectl get pod   you will get the container creating error 

kubectl describe pod local-vol-pod  -> at the end you will see the error. failedMount.  the path that you want to mount does not exist   /mnt/disks/local1 


kubectl delete pod local-vol-pod 


kubectl get node 

mninikube ssh 
sudo mkdir -p /mnt/disks/local1
sudo chmod 777 /mnt/disks/local1


cd /mnt/disks/local1
ls 
exit 

kubectl apply -f local-vol-example.yaml   -> successs 


exec into pod 
kubectl exec -it local-vol-pod -- sh 
cd /mnt/local 
echo "Hello" > hello.txt

exit

minikube ssh  

cd /mnt/disks/local1 

ls 
you will find the hello.txt file here 

let's delete pods local-vol-pod

kubectl delete pod --force local-vol-pod 

apply again 
kubectl apply -f local-vol-example.yaml 

exec into pod 

cat /mnt/local/hello.txt   content file still exist here 



create the pod2 with same config 


apiVersion: v1
kind: PersistentVolume
metadata:
  name: local-volume
spec:
  capacity:
    storage: 1Gi
  volumeMode: Filesystem
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: local-storage
  local:
    path: /mnt/disks/local1
  nodeAffinity:
    required:
      nodeSelectorTerms:
        - matchExpressions:
            - key: kubernetes.io/hostname
              operator: In
              values: ['minikube']
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: local-volume-claim
spec:
  resources:
    requests:
      storage: 1Gi
  volumeMode: Filesystem
  accessModes:
    - ReadWriteOnce
  storageClassName: local-storage
---
apiVersion: v1
kind: Pod
metadata:
  name: local-vol-pod
  labels:
    name: local-vol-pod
spec:
  containers:
    - name: local-vol
      image: busybox:1.36.1
      command:
        - 'sh'
        - '-c'
        - 'sleep 3600'
      resources:
        limits:
          memory: '128Mi'
          cpu: '500m'
      volumeMounts:
        - name: local-volume
          mountPath: /mnt/local
  volumes:
    - name: local-volume
      persistentVolumeClaim:
        claimName: local-volume-claim
---
apiVersion: v1
kind: Pod
metadata:
  name: local-vol-pod2
  labels:
    name: local-vol-pod2
spec:
  containers:
    - name: local-vol
      image: busybox:1.36.1
      command:
        - 'sh'
        - '-c'
        - 'sleep 3600'
      resources:
        limits:
          memory: '128Mi'
          cpu: '500m'
      volumeMounts:
        - name: local-volume
          mountPath: /mnt/local2
  volumes:
    - name: local-volume
      persistentVolumeClaim:
        claimName: local-volume-claim


that pod1 data will also available to pod2 data 
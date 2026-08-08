Headless Services

mkdir HEADLESS-SERVICE

touch svc.yaml 

apiVersion: v1
kind: Service
metadata:
  name: color-svc
spec:
  clusterIP: None
  ports:
    - port: 80
      targetPort: 80
  selector:
    app: color-api


kubectl apply -f svc.yaml 

kubectl get svc 

touch color-ss.yaml 

apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: color-ss
spec:
  selector:
    matchLabels:
      app: color-api
  serviceName: color-svc
  replicas: 3
  template:
    metadata:
      labels:
        app: color-api
    spec:
      containers:
        - name: color-api
          image: lmacademy/color-api:1.2.1
          ports:
            - containerPort: 80
              name: web
          volumeMounts:
            - name: dummy-data
              mountPath: /tmp/data
  volumeClaimTemplates:
    - metadata:
        name: dummy-data
      spec:
        accessModes: ['ReadWriteOnce']
        storageClassName: standard
        resources:
          requests:
            storage: 1Gi

kubectl apply -f color-ss.yaml 

kubectl get pod --watch 

kubctl describe svc color-svc


touch debug.yaml 

apiVersion: v1
kind: Pod
metadata:
  name: curl
  labels:
    name: curl
spec:
  containers:
    - name: curl
      image: lmacademy/alpine-curl:1.0.0
      resources:
        limits:
          memory: '128Mi'
          cpu: '500m'


kubectl apply -f debug.yaml
kubectl exec -it curl -- sh 

curl color-ss-0.color-svc 

curl color-ss-0.color-svc/api 

curl color-ss-2.color-svc/api 


curl color-ss-2.color-svc.default.svc.cluster.local  this is FQDN
what is this 
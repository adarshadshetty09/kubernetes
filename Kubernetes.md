# Storage and Persistence

## Section Overview

### 1. Discuss how persistent storage is handled in Kubernetes

### 2. Practice working with the EmptyDir volume

### 3. Explore Persistent Volumes (PVs) and Persistent Volume Claims (PVCs)

1. Work with local volumes
2. Practice dynamically creating Persistent Volumes in Minikube*
3. Understand the configuration and lifecycle of Persistent Volumes and Persistent Volume Claims

### 4. Explore StatefulSets

1. Understand the main characteristics and use cases for StatefulSets
2. Understand how headless services facilitate communication with StatefulSets
3. Practice creating and managing StatefulSets and dynamic Persistent Volumes (PVs)

---

**Note:** *We'll also explore dynamic Persistent Volumes (PVs) when deploying our applications in GKE.*




# Kubernetes Storage and Persistence - Detailed Notes

---

# 1. Why Do We Need Volumes?

## Problem with Containers

Containers are **ephemeral** (temporary).

This means:

* Data stored inside a container is **lost** when the container stops.
* If a Pod is deleted or recreated, all container data disappears unless it is stored externally.

Example:

```
Container
│
├── /app
├── /logs
└── /data
```

If the Pod dies:

```
Pod Deleted
        ↓
Container Deleted
        ↓
All internal data is lost
```

This is why Kubernetes provides **Volumes**.

---

# 2. What is a Volume?

A Kubernetes Volume is simply a **directory** that is mounted inside a container.

From the container's point of view:

```
/data
```

is just another folder.

The container doesn't know:

* where the data comes from
* how it is stored
* whether it is local disk
* AWS EBS
* Azure Disk
* Google Persistent Disk
* Network Storage

It only sees a directory.

---

# 3. What Does a Volume Provide?

Volumes solve two major problems.

## A. Persistent Storage

Store data even after Pod restarts.

Example:

Database

```
MySQL
│
└── /var/lib/mysql
```

Without volume:

```
Delete Pod
↓

Database Lost
```

With volume:

```
Delete Pod
↓

New Pod

↓

Mount Same Volume

↓

Database Still Exists
```

---

## B. Sharing Data Between Containers

A Pod can have multiple containers.

Example

```
Pod

├── App Container
└── Log Collector Container
```

Both can mount the same volume.

```
Shared Volume

App writes logs

↓

Log Collector reads logs
```

---

# 4. Kubernetes Volume Architecture

```
Pod

spec:
  volumes:

Container

volumeMounts:
```

Volumes are defined once.

Containers mount them wherever needed.

---

## Example

```
Pod

spec:
  volumes:
      - name: data-volume

containers:

- name: app

  volumeMounts:
      - name: data-volume
        mountPath: /app/data
```

Notice

Volume Name

```
data-volume
```

must match

```
volumeMounts.name
```

---

# 5. How Volumes Work

Step 1

Create volume.

```
Volumes
```

↓

Step 2

Mount into container.

```
Container

/app/data
```

↓

Step 3

Application reads/writes files.

---

# 6. Where Can Kubernetes Store Data?

Kubernetes supports many storage backends.

Examples

* Local SSD
* Local HDD
* AWS EBS
* AWS EFS
* Google Persistent Disk
* Azure Disk
* NFS
* Ceph
* GlusterFS
* SAN Storage
* CSI Drivers

Container doesn't care.

It only sees:

```
/data
```

---

# 7. Pod Example

```
Kubernetes Cluster

        Node

          │

       ┌──────────┐
       │   Pod    │
       └──────────┘

Volumes

├── EmptyDir
├── ConfigMap
├── Secret
├── Local Volume
└── Persistent Volume
```

Containers mount these.

```
Container

/data

/config

/secret
```

---

# 8. Volume Mount

Example

```
Volume

database-storage
```

Mounted as

```
/var/lib/mysql
```

Application writes here.

Actually stored on

AWS EBS

or

Local SSD

or

Azure Disk

The application doesn't know.

---

# 9. Types of Kubernetes Volumes

---

## 1. EmptyDir

Most basic volume.

Created when Pod starts.

Destroyed when Pod ends.

```
Pod Starts

↓

EmptyDir Created

↓

Containers Use It

↓

Pod Deleted

↓

EmptyDir Deleted
```

### Characteristics

✔ Temporary

✔ Shared between containers

✔ Exists only during Pod lifetime

---

### Use Cases

Scratch files

Temporary cache

Log sharing

Intermediate processing

Example

```
Container A

Writes

/tmp/data.txt

↓

EmptyDir

↓

Container B

Reads

/tmp/data.txt
```

---

### Lifecycle

```
Pod Running

↓

Volume Exists

↓

Pod Deleted

↓

Volume Deleted
```

---

# 2. Local Volume

Stores data on a local directory inside a Kubernetes node.

```
Node

/home/data

↓

Persistent Volume
```

Unlike EmptyDir,

Data survives Pod deletion.

---

Advantages

Persistent

Fast

Uses local SSD

---

Disadvantages

If Pod moves to another node

↓

Data unavailable

Therefore

Node Affinity is required.

---

# 3. hostPath (Older Method)

Older way of mounting node directories.

Example

```
/var/log

↓

Mounted inside container
```

Problems

Security risks

Can expose host filesystem

Not recommended

Instead use

Local Volume

---

# 4. Persistent Volume (PV)

A Persistent Volume is cluster storage.

Think of it as

```
Hard Disk
```

inside Kubernetes.

Created independently from Pods.

---

Characteristics

Persistent

Independent

Reusable

Can survive Pod deletion

Can use cloud storage

---

Example

```
AWS EBS

↓

Persistent Volume

↓

Pod

↓

Container
```

---

# 5. Persistent Volume Claim (PVC)

PVC is a request for storage.

Think

```
Developer

↓

"I need 20GB"

↓

PVC

↓

Kubernetes

↓

Find Matching PV
```

Pod never directly uses PV.

It uses PVC.

```
Pod

↓

PVC

↓

PV

↓

Storage
```

---

# 6. ConfigMap Volume

Stores configuration.

Instead of hardcoding

```
DATABASE_URL=abc
```

inside image,

Store in ConfigMap.

Mount as

```
/config
```

Application reads configuration files.

---

Benefits

No rebuild needed

Easy updates

Environment independent

---

# 7. Secret Volume

Similar to ConfigMap.

But for sensitive information.

Examples

Passwords

API Keys

Certificates

SSH Keys

Tokens

Mounted inside

```
/etc/secrets
```

instead of hardcoding.

---

# 10. Persistent Volume Provisioning

There are two methods.

---

## Static Provisioning

Administrator creates PV first.

```
Admin

↓

Create PV

↓

Developer Creates PVC

↓

PVC Binds PV
```

Flow

```
PV

↓

PVC

↓

Pod
```

---

## Dynamic Provisioning

Developer creates PVC only.

```
PVC

↓

StorageClass

↓

Automatically Create PV

↓

Bind

↓

Pod
```

Much easier.

Mostly used in Cloud.

---

# 11. CSI (Container Storage Interface)

CSI is a standard interface that lets Kubernetes communicate with storage providers.

Example

```
AWS CSI Driver

↓

AWS EBS
```

```
Azure CSI Driver

↓

Azure Disk
```

```
Google CSI Driver

↓

Persistent Disk
```

You can even create your own storage driver.

---

# 12. Node Affinity with Local Volumes

Since Local Volume exists only on one node,

Pods must run on the same node.

```
Node A

SSD

↓

Local Volume

↓

Pod Must Run Here
```

Otherwise

```
Node B

↓

Volume Missing
```

---

# 13. Summary Table

| Volume Type       | Persistent | Shared | Lifetime        | Common Use               |
| ----------------- | ---------- | ------ | --------------- | ------------------------ |
| EmptyDir          | ❌ No       | ✅ Yes  | Pod lifetime    | Temporary files          |
| Local Volume      | ✅ Yes      | Yes    | Node lifetime   | Local SSD storage        |
| hostPath          | ✅ Yes      | Yes    | Node lifetime   | Legacy (not recommended) |
| Persistent Volume | ✅ Yes      | Yes    | Independent     | Databases, storage       |
| ConfigMap         | N/A        | Yes    | Config lifetime | Configuration            |
| Secret            | N/A        | Yes    | Secret lifetime | Passwords, API Keys      |

---

# 14. Important Interview Questions

### Q1. Why do we need Volumes?

* Containers are ephemeral.
* Volumes provide persistent storage and data sharing.

---

### Q2. What is EmptyDir?

* Temporary storage.
* Created when Pod starts.
* Deleted when Pod is deleted.
* Shared among containers in the same Pod.

---

### Q3. Difference between EmptyDir and Persistent Volume?

| EmptyDir                     | Persistent Volume          |
| ---------------------------- | -------------------------- |
| Temporary                    | Permanent                  |
| Pod lifetime                 | Independent of Pod         |
| Data lost after Pod deletion | Data survives Pod deletion |

---

### Q4. Why use PVC instead of directly using PV?

PVC abstracts the storage.

Developers request storage without worrying about the underlying implementation.

---

### Q5. Difference between Static and Dynamic Provisioning?

**Static Provisioning**

* Admin manually creates the PV.
* PVC binds to an existing PV.

**Dynamic Provisioning**

* PVC triggers automatic PV creation using a `StorageClass`.

---

### Q6. Why is `hostPath` discouraged?

* Can expose the host filesystem.
* Security risks.
* Pods become tightly coupled to a node.
* `Local` volumes are the recommended alternative.

---

### Q7. What is CSI?

CSI (Container Storage Interface) is the standard that allows Kubernetes to integrate with different storage providers like AWS EBS, Azure Disk, GCP Persistent Disk, NFS, Ceph, and custom storage systems.

---

# Quick Revision (Exam/Interview)

* **Volume** = Directory mounted inside a container.
* Containers are **ephemeral**; volumes provide persistence.
* Define volumes under `spec.volumes`.
* Mount them using `containers.volumeMounts`.
* **EmptyDir** = Temporary storage for a Pod.
* **Local Volume** = Persistent storage on a specific node.
* **Persistent Volume (PV)** = Cluster-wide storage resource.
* **Persistent Volume Claim (PVC)** = Storage request made by applications.
* **ConfigMap** = Configuration data as a volume.
* **Secret** = Sensitive data as a volume.
* **Static Provisioning** = Admin creates the PV first.
* **Dynamic Provisioning** = Kubernetes creates the PV automatically through a `StorageClass`.
* **CSI** enables Kubernetes to work with different storage backends (AWS, Azure, GCP, NFS, etc.).

These notes cover both the conceptual understanding and the practical points commonly asked in Kubernetes and DevOps interviews.


# Kubernetes Volumes – Complete Notes (With Diagrams)

---

# Introduction to Volumes

## What is a Volume?

A **Volume** in Kubernetes is simply a **directory** that is mounted inside one or more containers in a Pod.

Unlike Docker containers, Kubernetes volumes can persist data beyond the lifetime of a container and can also be shared among containers in the same Pod.

> **Definition:**
> A Kubernetes Volume is a storage mechanism that allows containers to store, share, and persist data.

---

# Why Do We Need Volumes?

Containers are **ephemeral**.

That means:

```
Container Starts
       │
       ▼
Application Creates Files
       │
       ▼
Container Stops
       │
       ▼
All Files are LOST ❌
```

Example

```
Container

/app
/logs
/data

User uploads images

↓

Pod crashes

↓

Images disappear
```

To avoid this problem, Kubernetes provides **Volumes**.

---

# What Problems Do Volumes Solve?

Volumes solve two important problems.

### 1. Persistent Storage

Store data permanently.

Example

```
MySQL Database

Without Volume

Database Files
        │
        ▼
Container Deleted
        │
        ▼
Database Lost ❌
```

With Volume

```
Database Files
        │
        ▼
Persistent Volume
        │
        ▼
Container Deleted
        │
        ▼
New Container
        │
        ▼
Database Still Exists ✅
```

---

### 2. Sharing Data Between Containers

One Pod can have multiple containers.

```
            Pod

   ┌───────────────────┐

   App Container
         │
         │ writes logs
         ▼

   Shared Volume

         ▲
         │ reads logs

 Log Collector Container

   └───────────────────┘
```

Both containers access the same directory.

---

# Kubernetes Volume Architecture

```
                  Kubernetes Cluster
                         │
                         ▼
                    Worker Node
                         │
                         ▼
                   ┌───────────────┐
                   │      Pod      │
                   └───────────────┘
                          │
          ┌───────────────┼────────────────┐
          │               │                │
          ▼               ▼                ▼

     EmptyDir        ConfigMap        Persistent Volume

          │               │                │
          └─────── Mounted into Containers ───────┘

                         │
                         ▼

                 /data
                 /config
                 /db
```

The container only sees folders.

It never knows where the data is actually stored.

---

# How Kubernetes Uses Volumes

Volumes are declared in

```
spec.volumes
```

They are mounted inside containers using

```
spec.containers[].volumeMounts
```

Flow

```
Create Volume

        │

        ▼

spec.volumes

        │

        ▼

Mount into Container

        │

        ▼

Application Reads/Writes Data
```

---

# Pod Volume Architecture

```
                    Pod

        ┌────────────────────────┐

Volumes

├── pod-temp-storage
├── local-dir-in-node
├── config-map
└── aws-ebs

        │

        ▼

Container 1

Volume Mounts

pod-temp-storage
      │
      ▼
/tmp

local-dir-in-node
      │
      ▼
/usr/data

config-map
      │
      ▼
/config

aws-ebs
      │
      ▼
/data/db

        └────────────────────────┘
```

Notice

Volume Name

```
aws-ebs
```

must match

```
volumeMounts

name: aws-ebs
```

---

# Storage Backends Supported by Kubernetes

Volumes can be backed by many storage systems.

```
                    Kubernetes

                          │

     ┌────────────┬─────────────┬──────────────┐

     ▼            ▼             ▼

 Local SSD      AWS EBS      Google PD

     ▼            ▼             ▼

 Azure Disk     NFS         Ceph

     ▼

 CSI Drivers

     ▼

 Custom Storage
```

The container never knows.

It simply sees

```
/data
```

---

# Common Kubernetes Volume Types

---

# 1. EmptyDir

An EmptyDir volume is created when the Pod starts.

Deleted when the Pod is deleted.

```
Pod Starts

      │

      ▼

EmptyDir Created

      │

      ▼

Containers Share Files

      │

      ▼

Pod Deleted

      │

      ▼

Volume Deleted ❌
```

### Characteristics

✔ Temporary

✔ Shared among containers

✔ Exists only while Pod exists

### Use Cases

* Cache
* Temporary files
* Scratch space
* Log sharing

Example

```
Container A

writes

/tmp/report.txt

       │

       ▼

EmptyDir

       ▲

       │

Container B

reads

/tmp/report.txt
```

---

# 2. Local Volume

Stores data inside a specific Kubernetes node.

```
Worker Node

SSD

↓

/mnt/storage

↓

Persistent Volume

↓

Pod
```

Advantages

* Very fast
* Persistent
* Local SSD performance

Disadvantages

If Pod moves

```
Node A

Volume Exists

↓

Pod Scheduled

↓

Works
```

```
Node B

No Volume

↓

Application Fails
```

Therefore

Node Affinity is required.

---

# hostPath (Older Method)

```
Host Machine

/var/log

↓

Mounted

↓

Container
```

Problems

❌ Security risks

❌ Can expose host filesystem

❌ Not recommended

Preferred replacement

```
Local Volume
```

---

# Persistent Volume (PV)

Think of a PV as a real hard disk inside Kubernetes.

```
Cloud Storage

AWS EBS

↓

Persistent Volume

↓

Persistent Volume Claim

↓

Pod

↓

Container
```

Characteristics

✔ Persistent

✔ Independent

✔ Survives Pod deletion

✔ Cluster resource

---

# Persistent Volume Claim (PVC)

A PVC is a request for storage.

Developer never directly uses PV.

```
Developer

↓

PVC

↓

Kubernetes

↓

Find Matching PV

↓

Mount into Pod
```

Relationship

```
Application

↓

Pod

↓

PVC

↓

PV

↓

Storage
```

---

# ConfigMap Volume

ConfigMaps store application configuration.

Instead of

```
DATABASE_URL=abc
```

inside the image,

Store it in ConfigMap.

```
ConfigMap

↓

Mounted

↓

/config

↓

Application Reads Config
```

Advantages

* No image rebuild
* Easy updates
* Environment-specific configuration

---

# Secret Volume

Secrets store sensitive data.

Examples

* Passwords
* API Keys
* Certificates
* SSH Keys
* Tokens

```
Secret

↓

Mounted

↓

/etc/secrets

↓

Application Reads Secret
```

Never hardcode secrets inside YAML files or images.

---

# Static Provisioning

Administrator creates storage first.

```
Administrator

↓

Create PV

↓

Developer

↓

Create PVC

↓

PVC Binds PV

↓

Pod Uses Storage
```

---

# Dynamic Provisioning

No need to create PV manually.

```
Developer

↓

Create PVC

↓

StorageClass

↓

Automatically Creates PV

↓

Pod Uses Storage
```

Most cloud providers use this approach.

---

# CSI (Container Storage Interface)

CSI is a standard interface used by Kubernetes to communicate with storage providers.

```
                Kubernetes

                     │

                     ▼

          CSI Driver

     ┌────────┬────────┬─────────┐

     ▼        ▼        ▼

 AWS EBS   Azure Disk  GCP PD

     ▼

 NFS

     ▼

 Ceph

     ▼

 Custom Storage
```

You can even write your own CSI driver.

---

# Lifecycle Comparison

```
EmptyDir

Pod Created
      │
      ▼
Volume Created
      │
      ▼
Pod Deleted
      │
      ▼
Volume Deleted
```

```
Persistent Volume

PV Created
      │
      ▼
Pod Created
      │
      ▼
Pod Deleted
      │
      ▼
PV Still Exists ✅
```

---

# Complete Storage Flow

```
Developer

     │

Create Deployment

     │

     ▼

Pod

     │

Needs Storage

     │

     ▼

PVC

     │

Requests Storage

     │

     ▼

Persistent Volume

     │

Backed By

     │

     ▼

AWS EBS
Azure Disk
Google PD
NFS
Local SSD

     │

Mounted Into

     │

     ▼

Container

     │

Application Reads/Writes Data
```

---

# Summary Table

| Volume Type             | Persistent     | Shared | Lifetime        | Use Case        |
| ----------------------- | -------------- | ------ | --------------- | --------------- |
| EmptyDir                | ❌ No           | ✅ Yes  | Pod lifetime    | Temporary files |
| Local Volume            | ✅ Yes          | Yes    | Node lifetime   | Local storage   |
| hostPath                | ✅ Yes          | Yes    | Node lifetime   | Legacy (avoid)  |
| Persistent Volume       | ✅ Yes          | Yes    | Independent     | Databases       |
| Persistent Volume Claim | Request        | -      | -               | Access PV       |
| ConfigMap               | Config         | Yes    | Config lifetime | Configuration   |
| Secret                  | Sensitive Data | Yes    | Secret lifetime | Passwords       |

---

# Interview Questions

### Why are Volumes needed?

Because containers are ephemeral. Volumes provide persistent storage and allow data sharing between containers.

---

### What is the difference between EmptyDir and Persistent Volume?

| EmptyDir            | Persistent Volume                       |
| ------------------- | --------------------------------------- |
| Temporary           | Permanent                               |
| Deleted with Pod    | Exists independently                    |
| Used for cache/logs | Used for databases and application data |

---

### What is the difference between PV and PVC?

* **PV (Persistent Volume):** The actual storage resource provided by the cluster or cloud.
* **PVC (Persistent Volume Claim):** A request for storage made by an application.

---

### Why is `hostPath` discouraged?

* Security risks.
* Tight coupling to a specific node.
* Can expose the host filesystem.
* Use **Local Volumes** or **Persistent Volumes** instead.

---

### What is CSI?

CSI (Container Storage Interface) is the standard that allows Kubernetes to work with storage systems such as AWS EBS, Azure Disk, Google Persistent Disk, NFS, Ceph, and custom storage providers.

---

# Quick Revision

```
Container
      │
No Persistent Storage
      │
      ▼
Volume
      │
      ▼
Persistent Storage
      │
      ▼
PVC
      │
      ▼
PV
      │
      ▼
Storage Backend
      │
      ▼
AWS EBS / GCP PD / Azure Disk / Local SSD / NFS
```

This diagram summarizes the complete Kubernetes storage flow from the application down to the underlying storage backend.

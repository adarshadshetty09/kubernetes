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


# Kubernetes Volumes – Different Types of Volumes (Detailed Notes)

---

# Different Types of Kubernetes Volumes

Kubernetes supports multiple types of volumes depending on the application's storage requirements.

| Volume Type                | Purpose                         | Persistence | Common Use                                              |
| -------------------------- | ------------------------------- | ----------- | ------------------------------------------------------- |
| **EmptyDir**               | Temporary storage               | ❌ No        | Cache, temporary files, sharing data between containers |
| **Local Volume**           | Persistent storage on a node    | ✅ Yes       | Local SSD/HDD                                           |
| **Persistent Volume (PV)** | Cluster-wide persistent storage | ✅ Yes       | Databases, applications                                 |
| **ConfigMap**              | Configuration storage           | N/A         | Config files                                            |
| **Secret**                 | Sensitive information           | N/A         | Passwords, API keys                                     |

---

# 1. EmptyDir Volume

## What is EmptyDir?

`emptyDir` is a temporary volume that is created **when a Pod starts** and deleted **when the Pod is removed**.

It follows the **lifecycle of the Pod**.

---

## Lifecycle

```text
Pod Created
      │
      ▼
EmptyDir Created
      │
      ▼
Application Stores Files
      │
      ▼
Pod Deleted
      │
      ▼
EmptyDir Deleted ❌
```

---

## Characteristics

* Temporary storage
* Exists only while the Pod exists
* Shared by all containers inside the Pod
* Initially empty
* Data is lost when the Pod is deleted

---

## Use Cases

* Cache
* Temporary files
* Scratch space
* Log sharing between containers
* Intermediate processing

Example

```text
Container A

Writes

/tmp/output.txt

        │

        ▼

EmptyDir

        ▲

        │

Container B

Reads

/tmp/output.txt
```

---

## Advantages

✔ Very fast

✔ Easy to use

✔ Shared among containers

---

## Disadvantages

❌ Data lost after Pod deletion

❌ Not suitable for databases

---

# 2. Local Volume

## What is Local Volume?

A Local Volume stores data on a **specific Kubernetes worker node**.

Unlike EmptyDir, the data **survives Pod deletion**.

---

## Architecture

```text
Worker Node

SSD

↓

/mnt/storage

↓

Persistent Volume

↓

Pod

↓

Container
```

---

## Characteristics

* Persistent storage
* Uses node's local disk
* Faster than network storage
* Requires Node Affinity

---

## Why Node Affinity?

Since the data exists only on one node,

Pods must run on the same node.

```text
Node A

Local Disk

↓

Pod Runs Here ✅
```

If Pod moves

```text
Node B

No Local Disk

↓

Application Cannot Access Data ❌
```

---

## Advantages

✔ High Performance

✔ Low Latency

✔ Persistent

---

## Disadvantages

❌ Node failure can cause data unavailability

❌ Pod cannot freely move to another node

---

# hostPath vs Local Volume

Older Kubernetes versions commonly used **hostPath**.

```text
Host Machine

/var/log

↓

Mounted

↓

Container
```

### Problems with hostPath

* Security risk
* Container can access host filesystem
* Breaks portability
* Not recommended

**Recommendation:** Use **Local Volumes** instead.

---

# 3. Persistent Volume (PV)

## What is a Persistent Volume?

A **Persistent Volume (PV)** is a storage resource managed by Kubernetes.

Unlike Local Volume, it can use many storage backends.

Examples

* AWS EBS
* AWS EFS
* Azure Disk
* Google Persistent Disk
* NFS
* Ceph
* Local Storage

---

## Architecture

```text
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

---

## Characteristics

* Cluster resource
* Independent of Pods
* Data survives Pod deletion
* Can be shared (depending on access mode)
* Supports multiple storage providers

---

## Provisioning Methods

### Static Provisioning

Administrator creates the PV first.

```text
Admin

↓

Create PV

↓

Developer Creates PVC

↓

PVC Uses PV
```

---

### Dynamic Provisioning

Developer creates only a PVC.

```text
Developer

↓

Create PVC

↓

StorageClass

↓

PV Automatically Created

↓

Pod Uses Storage
```

Dynamic provisioning is commonly used in cloud environments.

---

## Use Cases

* Databases
* File storage
* Enterprise applications
* Stateful applications

---

# 4. ConfigMap Volume

## What is ConfigMap?

A ConfigMap stores **configuration data** separately from the application.

Instead of hardcoding configuration inside the image,

store it in a ConfigMap.

---

## Architecture

```text
ConfigMap

↓

Mounted

↓

/config

↓

Application Reads Configuration
```

---

## Example

Instead of

```properties
DATABASE_URL=db.company.com
```

inside the Docker image,

Store it in ConfigMap.

---

## Advantages

* No image rebuild
* Easy configuration updates
* Different configuration for Dev/Test/Prod
* Better configuration management

---

## Common Uses

* Database URLs
* Application properties
* Environment-specific settings
* Configuration files

---

# 5. Secret Volume

## What is Secret?

Secrets store **confidential information** securely.

Examples

* Passwords
* API Keys
* Certificates
* SSH Keys
* OAuth Tokens

---

## Architecture

```text
Secret

↓

Mounted

↓

/etc/secrets

↓

Application Reads Secret
```

---

## Why Secrets?

Instead of writing

```yaml
password: admin123
```

inside Deployment YAML,

store it in a Secret.

---

## Advantages

* Keeps sensitive data separate
* Better security
* Easy to rotate credentials
* Mounted as files or environment variables

---

## Common Uses

* Database passwords
* TLS certificates
* API tokens
* Kubernetes service account tokens

---

# Volume Comparison

| Feature                   | EmptyDir | Local Volume | Persistent Volume | ConfigMap     | Secret         |
| ------------------------- | -------- | ------------ | ----------------- | ------------- | -------------- |
| Stores Data               | ✅        | ✅            | ✅                 | Configuration | Sensitive Data |
| Persistent                | ❌        | ✅            | ✅                 | N/A           | N/A            |
| Pod Independent           | ❌        | ✅            | ✅                 | Yes           | Yes            |
| Shared Between Containers | ✅        | ✅            | Depends           | Yes           | Yes            |
| Used for Database         | ❌        | Sometimes    | ✅                 | ❌             | ❌              |
| Uses Cloud Storage        | ❌        | ❌            | ✅                 | ❌             | ❌              |

---

# Interview Questions

### Q1. When should you use `emptyDir`?

Use `emptyDir` for:

* Temporary storage
* Cache
* Scratch space
* Sharing files between containers in the same Pod

---

### Q2. Why is `hostPath` discouraged?

* Security vulnerabilities
* Tight coupling to a specific node
* Difficult to manage
* Local Volumes are the recommended replacement

---

### Q3. What is the difference between Local Volume and Persistent Volume?

| Local Volume           | Persistent Volume                |
| ---------------------- | -------------------------------- |
| Uses node's local disk | Can use cloud or network storage |
| Requires Node Affinity | Can be dynamically provisioned   |
| Node-specific          | Cluster-wide resource            |

---

### Q4. What is the difference between ConfigMap and Secret?

| ConfigMap                          | Secret                                                                                       |
| ---------------------------------- | -------------------------------------------------------------------------------------------- |
| Stores non-sensitive configuration | Stores sensitive information                                                                 |
| Database URL, app settings         | Passwords, API keys, certificates                                                            |
| Plain text                         | Base64 encoded in Kubernetes (not encrypted by default unless encryption at rest is enabled) |

---

### Q5. What is the difference between Static and Dynamic Provisioning?

* **Static Provisioning:** Administrator manually creates the Persistent Volume (PV).
* **Dynamic Provisioning:** Kubernetes automatically creates the PV when a Persistent Volume Claim (PVC) is created, using a `StorageClass`.

---

# Quick Revision

```text
EmptyDir
│
├── Temporary
├── Pod lifetime
└── Cache / Logs

Local Volume
│
├── Node storage
├── Persistent
└── Requires Node Affinity

Persistent Volume
│
├── Cluster storage
├── Cloud Storage
├── Static or Dynamic
└── Databases

ConfigMap
│
├── Configuration
└── App settings

Secret
│
├── Passwords
├── Certificates
└── API Keys
```

> **Remember:**
>
> * **EmptyDir** = Temporary storage for a Pod.
> * **Local Volume** = Persistent storage tied to one node.
> * **Persistent Volume (PV)** = Cluster-wide persistent storage.
> * **ConfigMap** = Non-sensitive configuration.
> * **Secret** = Sensitive information such as passwords and certificates.







# Kubernetes `emptyDir` and `local` Volumes - Detailed Notes

---

# Pod-Level and Node-Level Storage

Kubernetes provides different types of storage depending on how long you want your data to live.

The two simplest storage types are:

* **emptyDir** (Ephemeral Storage)
* **local Volume** (Persistent Storage on a Node)

The biggest difference between them is **how long the data survives**.

---

# 1. emptyDir Volume

## Definition

`emptyDir` is an **ephemeral (temporary)** volume.

It is created **when a Pod is assigned to a node**.

The volume exists **only as long as the Pod exists**.

---

## How emptyDir Works

```
Pod Created
      │
      ▼
emptyDir Volume Created
      │
      ▼
Containers Read & Write Data
      │
      ▼
Pod Deleted
      │
      ▼
Data Deleted Forever
```

---

## Key Characteristics

### 1. Pod-Level Storage

The volume belongs to the **Pod**, not to individual containers.

If the Pod has multiple containers, all containers can use the same volume.

Example

```
Pod

 ├── Container A
 │      │
 │      ▼
 ├── emptyDir
 │      ▲
 │      │
 └── Container B
```

Both containers can

* Read files
* Write files
* Modify files

because they share the same volume.

---

### 2. Created Automatically

The volume is created automatically when Kubernetes schedules the Pod on a node.

Initially the volume contains **no files**.

```
emptyDir

(empty)
```

---

### 3. Shared Between Containers

All containers inside the same Pod can access the same data.

Example

Container A

```
echo "Hello" > /shared/file.txt
```

Container B

```
cat /shared/file.txt

Output:
Hello
```

Both containers are reading the same storage.

---

### 4. Different Mount Paths

Containers do not need to mount the volume at the same location.

Example

Container A

```
/cache
```

Container B

```
/data
```

Internally they both refer to the same volume.

```
Container A

/cache
     │
     ▼
 emptyDir
     ▲
     │
/data

Container B
```

---

### 5. Data Exists Only While Pod Exists

If the Pod is deleted

```
kubectl delete pod mypod
```

Then

* Pod disappears
* emptyDir disappears
* All files disappear

Nothing is saved.

---

## What Happens During Restart?

### Container Restart

If only a container crashes

```
Container Restart

✓ Data remains
```

Because the Pod still exists.

---

### Pod Restart (Same Pod)

If the Pod is still alive

```
✓ Data remains
```

---

### Pod Deleted

```
Pod Deleted

❌ Data Lost
```

---

## Advantages

* Very fast
* Easy to use
* Great for temporary storage
* Good for sharing data between containers

---

## Disadvantages

* Data is temporary
* Cannot survive Pod deletion
* Cannot be shared across Pods

---

## Common Use Cases

### Temporary Files

```
Logs

Cache

Scratch Space
```

---

### Sharing Data Between Containers

Example

```
Container A

Downloads files

↓

emptyDir

↓

Container B

Processes files
```

---

### Cache

Applications can store cache inside emptyDir because cache can always be recreated.

---

# 2. Local Volume

## Definition

A Local Volume stores data on the **Node's local disk**.

Unlike emptyDir, it is a **Persistent Volume (PV).**

The data survives Pod deletion.

---

## How Local Volume Works

```
Node

──────────────

Local Disk

      │

Persistent Volume

      │

Persistent Volume Claim

      │

Pod
```

The storage belongs to the Node.

---

## Data Lifecycle

```
Pod Deleted

↓

Data Still Exists

↓

New Pod Uses Same Data
```

Because the storage belongs to the Node.

---

## Key Characteristics

### 1. Node-Level Storage

The volume belongs to the Node.

It does **not** belong to the Pod.

---

### 2. Persistent

Deleting the Pod does not delete the data.

Example

```
Pod

writes

database.db

↓

Delete Pod

↓

database.db still exists
```

---

### 3. Requires Persistent Volume

Unlike emptyDir, Kubernetes requires

* PersistentVolume (PV)
* PersistentVolumeClaim (PVC)

```
PV

↓

PVC

↓

Pod
```

---

### 4. Requires Node Affinity

Since the storage exists only on one Node,

Kubernetes must schedule the Pod onto that Node.

This is done using

```
nodeAffinity
```

Example

```
Node 1

Has Local Volume

↓

Pod must run here

✓
```

```
Node 2

No Local Volume

↓

Pod cannot run

✗
```

---

### Why Node Affinity is Required

Imagine

```
Node A

Disk:
database.db
```

Pod accidentally moves to

```
Node B
```

Node B doesn't have the file.

Application fails.

Therefore Kubernetes forces scheduling to the correct Node.

---

### 5. Static Provisioning Only

Local Volumes do not support dynamic provisioning.

Administrator must manually create

```
Persistent Volume
```

before creating

```
Persistent Volume Claim
```

---

## Advantages

* Faster than network storage
* Uses local SSD/HDD
* Persistent across Pod restarts
* Good performance

---

## Disadvantages

* Tied to one Node
* Node failure means data loss
* Cannot move easily between Nodes

---

# What Happens in Different Scenarios?

| Event             | emptyDir                              | Local Volume   |
| ----------------- | ------------------------------------- | -------------- |
| Container Restart | ✅ Data remains                        | ✅ Data remains |
| Pod Restart       | ✅ Data remains (if same Pod instance) | ✅ Data remains |
| Pod Deleted       | ❌ Data lost                           | ✅ Data remains |
| Node Failure      | ❌ Data lost                           | ❌ Data lost    |
| Node Replacement  | ❌ Data lost                           | ❌ Data lost    |

---

# Data Lifecycle Comparison

## emptyDir

```
Pod Created
      │
Volume Created
      │
Write Data
      │
Pod Deleted
      │
Data Deleted
```

Data follows the **Pod lifecycle**.

---

## Local Volume

```
Node Created
      │
Volume Created
      │
Pods Use Storage
      │
Pod Deleted
      │
Data Still Exists
      │
Node Deleted
      │
Data Deleted
```

Data follows the **Node lifecycle**.

---

# Why Are These Not Recommended for Production?

## emptyDir

Suppose your application stores customer data.

```
Customer Orders

↓

emptyDir

↓

Pod Crash

↓

All Orders Lost
```

This is unacceptable.

---

## Local Volume

Suppose your Node fails.

```
Node Disk

↓

Hardware Failure

↓

Data Lost
```

Since the storage exists only on that Node, recovery is difficult unless backups exist.

---

# Recommended Production Storage

Instead of using `emptyDir` or `local` volumes for important data, Kubernetes typically uses network-backed persistent storage such as:

* Amazon EBS
* Google Persistent Disk (GCE PD)
* Azure Disk
* NFS
* Ceph
* Longhorn
* Portworx

These storage systems can survive Pod rescheduling and, depending on the backend, even Node failures.

---

# Interview Questions

### 1. What is `emptyDir`?

A temporary Pod-level volume created when the Pod starts and deleted when the Pod is removed.

---

### 2. Can multiple containers share an `emptyDir`?

Yes. All containers in the same Pod can read and write to the same `emptyDir` volume.

---

### 3. Does `emptyDir` survive Pod deletion?

No. All data is permanently deleted when the Pod is deleted.

---

### 4. What is a Local Volume?

A Persistent Volume that stores data on a specific Node's local disk.

---

### 5. Why is `nodeAffinity` mandatory for Local Volumes?

Because the data exists on only one Node. Kubernetes must schedule the Pod onto that same Node to access the data.

---

### 6. Do Local Volumes require PVCs?

Yes. Like other Persistent Volumes, Pods access them through a Persistent Volume Claim (PVC).

---

### 7. Does a Local Volume survive Pod deletion?

Yes. The data remains because it is stored on the Node, not inside the Pod.

---

### 8. What happens if the Node is deleted?

The Local Volume data is also lost because it is physically stored on that Node.

---

# Quick Revision

| Feature                   | emptyDir                                  | Local Volume                                                           |
| ------------------------- | ----------------------------------------- | ---------------------------------------------------------------------- |
| Storage Type              | Ephemeral                                 | Persistent                                                             |
| Scope                     | Pod                                       | Node                                                                   |
| Created When              | Pod starts                                | Admin creates PV                                                       |
| Requires PV/PVC           | No                                        | Yes                                                                    |
| Shared Between Containers | Yes                                       | Yes (through PVC)                                                      |
| Survives Pod Deletion     | ❌ No                                      | ✅ Yes                                                                  |
| Survives Node Failure     | ❌ No                                      | ❌ No                                                                   |
| Node Affinity Required    | No                                        | Yes                                                                    |
| Provisioning              | Automatic                                 | Static only                                                            |
| Best Use Case             | Cache, temporary files, container sharing | High-performance node-local storage, non-critical persistent workloads |



This is one of the **most important Kubernetes storage concepts**. In interviews and production, you'll often be asked:

> **"What is emptyDir? When do you use it? What happens when the Pod is deleted?"**

Let's understand it like you're actually working as a DevOps Engineer.

---

# What is emptyDir?

`emptyDir` is a **temporary volume** that Kubernetes creates **when a Pod starts**.

Think of it as:

```
Pod Starts
      │
      ▼
Creates an Empty Folder
      │
Containers use it
      │
Pod Deleted
      │
Folder Deleted
```

So,

* Pod starts → empty folder created
* Containers can write/read
* Pod deleted → everything inside disappears

This is why it is called **emptyDir**.

---

# Real World Example

Suppose you have

```
Nginx
+
Log Processor
```

```
             Pod

      +-------------------+

      Nginx Container

        writes logs

             │

             ▼

        emptyDir Volume

             ▲

             │

      Fluentd Container

       reads logs
```

Instead of saving logs inside nginx container,

both containers use the same folder.

---

# Lab 1

Create directory

```bash
mkdir storage-persistence
cd storage-persistence
```

Create file

```bash
touch empty-dir-example.yaml
```

---

# YAML Explained

```yaml
apiVersion: v1
```

Using Kubernetes Core API.

---

```yaml
kind: Pod
```

Create one Pod.

---

```yaml
metadata:
  name: empty-dir-demo
```

Pod name.

---

```yaml
labels:
  name: empty-dir-demo
```

Label for identification.

---

## Container

```yaml
containers:
```

Only one container.

---

```yaml
image: busybox:1.36.1
```

Busybox is a tiny Linux image.

Think of it as Ubuntu with basic commands.

---

```yaml
command:
- sh
- -c
- sleep 3600
```

Normally Busybox exits immediately.

This command tells it

```
Sleep for 1 hour
```

so the Pod remains Running.

---

Resources

```yaml
resources:
  limits:
```

Limit memory and CPU.

---

Now important part

```yaml
volumeMounts:
```

This tells the container

> Mount a storage volume here.

```
Container

/usr/share/tmp

↓

Mounted Volume
```

---

This line

```yaml
mountPath: /usr/share/tmp
```

means

```
Container filesystem

/usr/share/tmp

↓

actually points to

emptyDir volume
```

---

Now volume

```yaml
volumes:
```

Create storage.

```
temporary-storage
```

is simply a name.

---

```yaml
emptyDir: {}
```

Means

```
Create temporary storage
```

No size specified.

---

# Apply

```bash
kubectl apply -f empty-dir-example.yaml
```

Check

```bash
kubectl get pod
```

Output

```
NAME

empty-dir-demo

Running
```

---

Describe

```bash
kubectl describe pod empty-dir-demo
```

Scroll until

```
Volumes:

temporary-storage

Type: EmptyDir
```

You'll also see

```
Mounted at

/usr/share/tmp
```

---

# Login

```bash
kubectl exec -it empty-dir-demo -- sh
```

Now you're inside container.

---

Move

```bash
cd /usr/share/tmp
```

Notice: your notes have `/usr/shared/temp` and `/usr/share/temp` in places. Use the same path that you configured in `mountPath` (for example, `/usr/share/tmp` or change the YAML consistently to `/usr/share/temp`).

---

List

```bash
ls -l
```

Output

```
total 0
```

Because Kubernetes created an empty folder.

---

Create file

```bash
echo "Hello from temp storage" > demo.txt
```

Check

```bash
cat demo.txt
```

Output

```
Hello from temp storage
```

---

Exit

```bash
exit
```

---

Delete Pod

```bash
kubectl delete -f empty-dir-example.yaml
```

(`--force` is usually unnecessary here because `sleep` exits cleanly when the Pod is deleted.)

Pod disappears.

Storage disappears.

---

Apply again

```bash
kubectl apply -f empty-dir-example.yaml
```

Login again.

```bash
kubectl exec -it empty-dir-demo -- sh
```

Go to directory

```bash
cd /usr/share/tmp
ls
```

Output

```
nothing
```

Why?

Because

```
Old Pod

↓

Deleted

↓

Storage Deleted

↓

New Pod

↓

New Empty Storage
```

This is the biggest property of emptyDir.

---

# Lab 2

Now you have

```
Writer Container

+

Reader Container
```

inside one Pod.

```
                Pod

+-------------------------------------+

Writer Container

      │

      ▼

    emptyDir

      ▲

      │

Reader Container

+-------------------------------------+
```

Both share the same storage.

---

Writer

```yaml
mountPath: /usr/share/temp
```

Reader

```yaml
mountPath: /temp
```

Notice

Different paths

Same storage.

Think like

```
Windows

D:\Data

Linux

/home/data
```

Different path

Same disk.

---

Writer

```yaml
readOnly: false
```

Can

* create
* modify
* delete

---

Reader

```yaml
readOnly: true
```

Can only

* read

Cannot

* create
* modify
* delete

---

Apply

```bash
kubectl apply -f empty-dir-example.yaml
```

---

Describe

```bash
kubectl describe pod empty-dir-demo
```

Notice

```
Containers

empty-dir-writer

empty-dir-reader
```

Both mount same volume.

---

Open writer

```bash
kubectl exec -it empty-dir-demo -c empty-dir-writer -- sh
```

Create

```bash
cd /usr/share/temp

echo "Hello" > hello.txt
```

Exit

---

Login reader

```bash
kubectl exec -it empty-dir-demo -c empty-dir-reader -- sh
```

Go

```bash
cd /temp
```

List

```bash
ls
```

Output

```
hello.txt
```

Read

```bash
cat hello.txt
```

Output

```
Hello
```

Now try

```bash
echo "Hi" > hello-reader.txt
```

Output

```
Read-only file system
```

Exactly as expected.

---

# Why does it work?

```
Writer

writes

↓

emptyDir

↓

Reader

reads
```

Not

```
Writer

↓

Reader
```

Both communicate through shared storage.

---

# Production Example 1 (Log Sharing)

```
App Container

writes

/application.log

↓

emptyDir

↓

Fluent Bit

reads logs

↓

ElasticSearch
```

Almost every company uses something similar.

---

# Production Example 2 (File Processing)

```
Container A

Downloads PDF

↓

emptyDir

↓

Container B

Reads PDF

↓

Converts to Image
```

---

# Production Example 3 (Machine Learning)

```
Downloader

↓

Downloads Model

↓

emptyDir

↓

Inference Server

Loads Model
```

Avoids downloading twice.

---

# Production Example 4 (Init Container)

```
Init Container

↓

Downloads Config

↓

emptyDir

↓

Main Application

Uses Config
```

This is a very common interview scenario.

---

# Practice Lab 1: Notes Sharing

Create two containers:

```
Writer

writes

notes.txt
```

Reader

```bash
cat notes.txt
```

Goal:

Understand shared volume behavior.

---

# Practice Lab 2: Image Sharing

Container A

```bash
touch image1.png
```

Container B

```bash
ls
```

Verify file is visible.

---

# Practice Lab 3: Read-Only Test

Reader

Try

```bash
rm hello.txt
```

Expected

```
Read-only file system
```

---

# Practice Lab 4: Multiple Files

Writer

```bash
for i in 1 2 3 4 5
do
echo File$i > file$i.txt
done
```

Reader

```bash
ls
cat file3.txt
```

---

# Practice Lab 5: Pod Restart Behavior

1.

Create

```
100 files
```

2.

Delete Pod

3.

Create Pod again

4.

Observe

```
Everything gone
```

---

# Practice Lab 6: Compare emptyDir vs Container Filesystem

Inside the writer container:

```bash
echo "inside volume" > /usr/share/temp/volume.txt
echo "inside container" > /root/container.txt
```

Verify both files exist.

Delete and recreate the Pod, then check again:

* `/usr/share/temp/volume.txt` → gone
* `/root/container.txt` → also gone (because the container filesystem is recreated too)

This helps you understand that **both are ephemeral**, but `emptyDir` is specifically designed to be **shared across containers in the same Pod**.

---

# Interview Questions

**Q1. When is emptyDir created?**

**Answer:** When the Pod is scheduled onto a node and starts.

---

**Q2. When is it deleted?**

**Answer:** When the Pod is removed from the node (deleted or permanently terminated).

---

**Q3. Can multiple containers use the same emptyDir?**

**Answer:** Yes. That's one of its main purposes.

---

**Q4. Is emptyDir persistent?**

**Answer:** No. It is ephemeral storage.

---

**Q5. Can one container be read-only?**

**Answer:** Yes, by mounting the volume with `readOnly: true`.

---

# Key Takeaways

| Feature                       | `emptyDir`                                                  |
| ----------------------------- | ----------------------------------------------------------- |
| Created when                  | Pod starts                                                  |
| Deleted when                  | Pod is deleted                                              |
| Shared between containers     | ✅ Yes                                                       |
| Persistent after Pod deletion | ❌ No                                                        |
| Supports read-only mounts     | ✅ Yes                                                       |
| Common production use         | Shared logs, temporary files, caches, init-container output |

For a DevOps Engineer, mastering `emptyDir` is the first step in understanding Kubernetes storage. The next concepts to learn are **hostPath**, **PersistentVolume (PV)**, **PersistentVolumeClaim (PVC)**, **StorageClass**, and **dynamic provisioning**, which are the storage mechanisms most commonly used in production clusters.


Yes. I also noticed a few mistakes in the YAML you pasted:

* `cpu: "500m"empty` → should be `cpu: "500m"`
* You used both `/usr/share/tmp` and `/usr/share/temp`. Use **one path consistently**.
* `cd /usr/shared/temp` → should be `cd /usr/share/temp`
* `labels: name: -dir-demo` → should be `labels: name: empty-dir-demo`

Below are the corrected YAML files that you can use directly. These match the hands-on lab you shared. 

---

# Lab 1 - Single Container using emptyDir

**empty-dir-example.yaml**

```yaml
apiVersion: v1
kind: Pod

metadata:
  name: empty-dir-demo
  labels:
    app: empty-dir-demo

spec:
  containers:
    - name: empty-dir-demo
      image: busybox:1.36.1

      command:
        - sh
        - -c
        - sleep 3600

      resources:
        limits:
          memory: "128Mi"
          cpu: "500m"

      volumeMounts:
        - name: temporary-storage
          mountPath: /usr/share/temp

  volumes:
    - name: temporary-storage
      emptyDir: {}
```

---

## Apply

```bash
kubectl apply -f empty-dir-example.yaml
```

Check

```bash
kubectl get pods
```

Describe

```bash
kubectl describe pod empty-dir-demo
```

Look for

```
Volumes:
  temporary-storage
    Type: EmptyDir
```

---

## Login

```bash
kubectl exec -it empty-dir-demo -- sh
```

Go inside mounted directory

```bash
cd /usr/share/temp
```

Verify

```bash
ls -l
```

Output

```
total 0
```

Create file

```bash
echo "Hello from temp storage" > demo.txt
```

Read

```bash
cat demo.txt
```

Exit

```bash
exit
```

Delete pod

```bash
kubectl delete -f empty-dir-example.yaml
```

Create again

```bash
kubectl apply -f empty-dir-example.yaml
```

Login

```bash
kubectl exec -it empty-dir-demo -- sh
```

Check

```bash
cd /usr/share/temp

ls
```

Output

```
Nothing
```

Because the Pod was deleted, the `emptyDir` was also deleted. 

---

# Lab 2 - Two Containers Sharing emptyDir

**empty-dir-example.yaml**

```yaml
apiVersion: v1
kind: Pod

metadata:
  name: empty-dir-demo
  labels:
    app: empty-dir-demo

spec:
  containers:

    - name: empty-dir-writer
      image: busybox:1.36.1

      command:
        - sh
        - -c
        - sleep 3600

      resources:
        limits:
          memory: "128Mi"
          cpu: "500m"

      volumeMounts:
        - name: temporary-storage
          mountPath: /usr/share/temp
          readOnly: false

    - name: empty-dir-reader
      image: busybox:1.36.1

      command:
        - sh
        - -c
        - sleep 3600

      resources:
        limits:
          memory: "128Mi"
          cpu: "500m"

      volumeMounts:
        - name: temporary-storage
          mountPath: /temp
          readOnly: true

  volumes:
    - name: temporary-storage
      emptyDir: {}
```

---

## Apply

```bash
kubectl apply -f empty-dir-example.yaml
```

Check

```bash
kubectl get pods
```

Describe

```bash
kubectl describe pod empty-dir-demo
```

Notice there are **two containers**.

```
Containers

empty-dir-writer

empty-dir-reader
```

---

## Login to Writer

```bash
kubectl exec -it empty-dir-demo -c empty-dir-writer -- sh
```

Go

```bash
cd /usr/share/temp
```

Create file

```bash
echo "Hello Kubernetes" > hello.txt
```

Check

```bash
ls

cat hello.txt
```

Exit

```bash
exit
```

---

## Login to Reader

```bash
kubectl exec -it empty-dir-demo -c empty-dir-reader -- sh
```

Go

```bash
cd /temp
```

Check

```bash
ls
```

Output

```
hello.txt
```

Read

```bash
cat hello.txt
```

Output

```
Hello Kubernetes
```

Now try writing

```bash
echo "Reader data" > hello-reader.txt
```

Output

```
sh: can't create hello-reader.txt: Read-only file system
```

Because the reader mounted the volume with

```yaml
readOnly: true
```

it cannot create, modify, or delete files. 

---

# Production Example

A common production pattern is an application container writing logs while a log collector reads the same files:

```yaml
apiVersion: v1
kind: Pod

metadata:
  name: nginx-logging

spec:
  containers:

    - name: nginx
      image: nginx

      volumeMounts:
        - name: logs
          mountPath: /var/log/nginx

    - name: fluent-bit
      image: fluent/fluent-bit

      volumeMounts:
        - name: logs
          mountPath: /var/log/nginx
          readOnly: true

  volumes:
    - name: logs
      emptyDir: {}
```

Flow:

```
Nginx
   │
Writes logs
   │
emptyDir
   │
Fluent Bit
   │
ElasticSearch / OpenSearch
```

This pattern is widely used for temporary log sharing inside a Pod. 

---

After you finish `emptyDir`, the next hands-on labs I recommend are:

1. `hostPath` volume
2. PersistentVolume (PV)
3. PersistentVolumeClaim (PVC)
4. StorageClass and dynamic provisioning
5. StatefulSet with persistent storage

These build directly on `emptyDir` and represent how persistent storage is implemented in production Kubernetes clusters.


mkdir storage-persistence
cd storage-persistence

touch empty-dir-example.yaml

```
apiVersion: v1
kind: Pod 
metadata:
  name: empty-dir-demo
  labels:
    name: empty-dir-demo
spec: 
  containers:
  - name: empty-dir-demo 
    image: busybox:1.36.1
    command:
      - 'sh'
      - '-c'
      - 'sleep 3600'
    resources: 
      limits: 
        memory: "128Mi"
        cpu: "500m"empty
    volumeMounts: 
      - name: temporary-storage
        mountPath: /usr/share/tmp 

  volumes: 
  - name: temporary-storage
    emptyDir: {}

```

kubectl apply -f empty-dir-example.yaml

kubectl get pod 
kubectl describe pod empty-dir-demo

look for volume section read everything

kubectl exec -it empty-dir-demo -- sh 

cd /usr/shared/temp 
ls -l --> empty dir 

create new file here 

echo "Hello from temp storage" > demo.txt

cat /usr/share/temp/demo.txt


exit 

kubectl delete --force -f empty-dir-example.yaml   (--force because sleep )


apply this file once again kubectl apply -f empty-dir-example.yaml

and exec into it. and see the demo.txt file exist or not file will be deleted.

When pod delted the data also lost. 


```
apiVersion: v1
kind: Pod 
metadata:
  name: empty-dir-demo
  labels:
    name: -dir-demo
spec: 
  containers:
  - name: empty-dir-writer 
    image: busybox:1.36.1
    command:
      - 'sh'
      - '-c'
      - 'sleep 3600'
    resources: 
      limits: 
        memory: "128Mi"
        cpu: "500m"
    volumeMounts: 
      - name: temporary-storage
        mountPath: /usr/share/temp 
        readOnly: false

  - name: empty-dir-reader 
    image: busybox:1.36.1
    command:
      - 'sh'
      - '-c'
      - 'sleep 3600'
    resources: 
      limits: 
        memory: "128Mi"
        cpu: "500m"
    volumeMounts: 
      - name: temporary-storage
        mountPath: /temp 
        readOnly: true

  volumes: 
  - name: temporary-storage
    emptyDir: {}
  
```
kubectl apply -f empty-dir-example.yaml

kubectl get pod 

kubectl describe pod empty-dir-demo


Now we have 2 container inside the container 

kubectl exec -it  empty-dir-demo -c empty-dir-writer -- sh 

cd /usr/share/temp 
echo "Hello" > hello.txt

exit
kubectl exec -it  empty-dir-demo -c empty-dir-reader -- sh 
cd /temp
ls 
you will see the hello.txt

echo "Hello" > hello-reader.txt you will get the error beacuase it only reader file 



=================================================================

Persistent Volume Claims 
Below are **detailed study notes** based on the lecture you shared, with **ASCII block diagrams** that you can save as a `.txt` file. These notes follow the concepts presented in the lecture and expand them for easier understanding.

---

# Persistent Volume Claims (PVC) - Complete Notes

```
===========================================================
          KUBERNETES PERSISTENT VOLUME CLAIMS (PVC)
===========================================================
```

## What Problem Does PVC Solve?

Containers are **ephemeral**.

If a Pod is deleted:

```
Pod
 |
 +----> Container Files
 |
 +----> emptyDir Data
```

Everything is lost.

Applications like:

* MySQL
* PostgreSQL
* MongoDB
* Jenkins
* Elasticsearch

cannot lose data.

So Kubernetes introduced **Persistent Storage**.

---

# Kubernetes Storage Components

```
+-------------+
|    POD      |
+-------------+
       |
       |
       v
+-----------------------+
| PersistentVolumeClaim |
|         PVC           |
+-----------------------+
       |
       |
       v
+-----------------------+
|  PersistentVolume     |
|         PV            |
+-----------------------+
       |
       |
       v
Physical Storage

Examples

Local Disk
AWS EBS
Azure Disk
Google PD
NFS
Ceph
SAN
```

Think of it like this:

```
Customer
   |
   | asks for room
   v
Reception (PVC)
   |
allocates room
   v
Hotel Room (PV)
```

The customer never directly chooses a room.

The receptionist assigns one.

PVC works exactly like the receptionist.

---

# What is a Persistent Volume (PV)?

A PV is the **actual storage**.

Examples:

```
100GB SSD

50GB NFS

20GB AWS EBS

500GB SAN
```

A PV exists inside Kubernetes as a storage resource.

---

# What is a Persistent Volume Claim (PVC)?

PVC is a **request for storage**.

Example:

```
I need

10GB

ReadWriteOnce
```

PVC does **not** contain storage.

It only requests storage.

---

# Why Can't Pods Use PV Directly?

Kubernetes does not allow this:

```
Pod
 |
 X
 |
PV
```

Instead:

```
Pod
 |
PVC
 |
PV
 |
Disk
```

Reason:

Pods should not know where storage physically exists.

PVC hides those implementation details.

---

# Static Provisioning

Static means:

Administrator creates storage first.

```
Administrator

Creates PV

      |

      v

+----------------+
| PV-1 (10GB)    |
+----------------+

+----------------+
| PV-2 (20GB)    |
+----------------+

+----------------+
| PV-3 (50GB)    |
+----------------+
```

Later

Developer creates PVC.

```
PVC

Need 20GB
```

Kubernetes searches.

```
PVC

20GB

      |

      v

PV-1 10GB

No

PV-2 20GB

YES

Bind

PV-3 50GB

Ignored
```

Finally

```
Pod

↓

PVC

↓

PV-2

↓

Disk
```

---

# Static Provisioning Flow

```
Admin

↓

Create PV

↓

Developer

↓

Create PVC

↓

Kubernetes

↓

Find Matching PV

↓

Bind

↓

Pod Uses Storage
```

---

# If No Matching PV Exists

Suppose

Existing PVs

```
5GB

10GB
```

PVC requests

```
50GB
```

Result

```
PVC

Status

Pending
```

Because Kubernetes cannot find matching storage.

---

# Dynamic Provisioning

Dynamic provisioning is completely different.

Administrator **does not** create PV.

Instead

Developer creates PVC.

```
PVC

↓

StorageClass

↓

Automatically Creates PV

↓

Pod Uses PVC
```

No manual work.

---

# Dynamic Provisioning Diagram

```
Developer

Creates PVC

↓

StorageClass

↓

Cloud Provider

↓

Creates New Disk

↓

Creates PV

↓

Binds PVC

↓

Pod Starts
```

This is how AWS EKS

Azure AKS

Google GKE

usually work.

---

# Static vs Dynamic

```
STATIC

Admin

↓

PV

↓

PVC

↓

Pod
```

```
DYNAMIC

PVC

↓

StorageClass

↓

PV

↓

Pod
```

---

# Relationship Between PV and PVC

One PV

can have

ONLY ONE PVC

```
PVC

↓

PV
```

Allowed

---

Not allowed

```
PVC-1

     \

      \

       PV

      /

     /

PVC-2
```

One PV cannot serve multiple PVCs.

---

# Wasted Capacity Example

PV

```
100GB
```

PVC

```
10GB
```

After binding

```
100GB PV

↓

10GB Used

↓

90GB Cannot Be Used
```

Because

One PV

One PVC

This problem mostly happens in **Static Provisioning**.

Dynamic provisioning avoids this by creating storage of the requested size.

---

# Reclaim Policies

When PVC is deleted,

What should happen to the PV?

Three options.

---

## 1. Retain

```
PVC Deleted

↓

PV Stays

↓

Admin Checks Data

↓

Deletes Later
```

Useful for databases.

---

## 2. Delete (Default)

```
PVC Deleted

↓

PV Deleted

↓

Cloud Disk Deleted
```

Saves money.

---

## 3. Recycle (Deprecated)

Old Kubernetes feature.

```
PVC Deleted

↓

Delete Files

↓

Reuse PV
```

Not recommended anymore.

---

# Access Modes

## ReadWriteOnce (RWO)

```
Node-1

+------------------+

Pod A

Pod B

Pod C

+------------------+

        |

        |

       PV
```

Many Pods

Same Node

Read Write

Allowed

Different Node

Not Allowed

---

## ReadOnlyMany (ROX)

```
Node1

↓

Read

PV

↑

Node2

↓

Read

↑

Node3
```

Everyone can read.

Nobody writes.

---

## ReadWriteMany (RWX)

```
Node1

↓

Read Write

PV

↑

Node2

↓

Read Write

↑

Node3
```

Everyone can read and write.

Usually supported by

NFS

CephFS

Azure Files

Amazon EFS

---

## ReadWriteOncePod (RWOP)

```
Pod A

↓

PV

Pod B

×

Denied
```

Only one Pod can use it.

Even if another Pod is on the same node,

it cannot mount it.

---

# Best-Effort Matching (Static Provisioning)

Suppose

PVC asks

```
20GB

ReadWriteOnce
```

Available PVs

```
10GB RWO

50GB RWX

30GB ROX
```

No exact match.

PVC stays Pending.

---

# Dynamic Provisioning Always Creates Storage

PVC

```
Need

20GB

ReadWriteOnce
```

StorageClass

```
AWS EBS
```

Automatically

```
Creates

20GB Disk

↓

PV

↓

PVC Bound
```

---

# Production Example 1 - MySQL

```
MySQL Pod

↓

PVC

↓

AWS EBS

↓

Database Files
```

If Pod crashes

```
Delete Pod

↓

Create New Pod

↓

Attach Same Disk

↓

Database Continues
```

No data loss.

---

# Production Example 2 - Jenkins

```
Jenkins Pod

↓

PVC

↓

Build History

Plugins

Workspace
```

Without PVC

```
Pod Deleted

↓

Everything Lost
```

---

# Production Example 3 - Elasticsearch

```
Elasticsearch Pod

↓

PVC

↓

Indices

↓

Disk
```

---

# Interview Questions

**Q1. Can Pod directly use PV?**

No.

```
Pod

↓

PVC

↓

PV
```

---

**Q2. Difference between PV and PVC?**

PV

```
Actual Storage
```

PVC

```
Storage Request
```

---

**Q3. Static vs Dynamic?**

Static

```
Admin Creates PV
```

Dynamic

```
PVC Creates PV Automatically
```

---

**Q4. Why PVC?**

* Decouples Pods from storage
* Makes storage portable
* Supports dynamic provisioning

---

**Q5. Why is StorageClass used?**

StorageClass defines **how** Kubernetes should dynamically create storage (for example, AWS EBS, Azure Disk, or Google Persistent Disk).

---

# Complete Kubernetes Storage Architecture

```
                     Kubernetes Cluster

+---------------------------------------------------------+

          Developer

               |

               v

     +----------------------+

     |   Create PVC         |

     +----------------------+

               |

               v

     +----------------------+

     | StorageClass         |

     +----------------------+

               |

               v

     +----------------------+

     | Persistent Volume    |

     +----------------------+

               |

               v

      AWS EBS / Azure Disk / GCE PD / NFS

               |

               v

     +----------------------+

     |        Pod           |

     +----------------------+

               |

               v

          Application

           (MySQL)

+---------------------------------------------------------+
```

---

# Key Points to Remember

```
PV = Actual Storage

PVC = Request for Storage

StorageClass = Template used to create storage dynamically

Pod always uses PVC

PVC binds to one PV

One PV binds to one PVC

Dynamic Provisioning is preferred in production

Delete is the default reclaim policy

RWO = One Node

RWX = Many Nodes

ROX = Many Nodes (Read Only)

RWOP = One Pod Only
```

These notes cover the concepts shown in your lecture and expand them with additional explanations and block diagrams to make the storage flow easier to visualize and revise.



Hands on PVC

kubectl get pods

touch local-vol-example.yaml 

Your YAML mixes **`local`** and **`hostPath`** volumes. A PersistentVolume can only use **one volume source**. If you're creating a **Local PersistentVolume**, use `local` with `nodeAffinity` and **remove `hostPath`**.

Here's the corrected YAML:

```yaml
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
    path: /mnt/disk/local1   # This directory must exist on the node.

  nodeAffinity:
    required:
      nodeSelectorTerms:
        - matchExpressions:
            - key: kubernetes.io/hostname
              operator: In
              values:
                - minikube
```

### Before applying this PV

**1. Create the directory on the node**

```bash
sudo mkdir -p /mnt/disk/local1
sudo chmod 777 /mnt/disk/local1
```

For Minikube:

```bash
minikube ssh
sudo mkdir -p /mnt/disk/local1
sudo chmod 777 /mnt/disk/local1
exit
```

---

**2. Get the node label**

```bash
kubectl get nodes --show-labels
```

or

```bash
kubectl describe node minikube
```

Look for a label like:

```text
kubernetes.io/hostname=minikube
```

Use that value in:

```yaml
values:
  - minikube
```

---

**3. Create the StorageClass**

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: local-storage
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: WaitForFirstConsumer
```

---

**4. Create the PersistentVolumeClaim**

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: local-pvc
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: local-storage
  resources:
    requests:
      storage: 1Gi
```

### Difference between `local` and `hostPath`

| Feature                    | `hostPath`                                     | `local`                |
| -------------------------- | ---------------------------------------------- | ---------------------- |
| Use case                   | Single-node testing (Minikube, Docker Desktop) | Production local disks |
| Requires `nodeAffinity`    | ❌ No                                           | ✅ Yes                  |
| Scheduler aware            | ❌ No                                           | ✅ Yes                  |
| Recommended for production | ❌ No                                           | ✅ Yes                  |

**Key corrections to your YAML:**

* ❌ Remove `hostPath` when using `local`.
* ✅ `path` under `local` must exist on the target node.
* ✅ Use the node label key `kubernetes.io/hostname`.
* ✅ Format `values` as a YAML list:

  ```yaml
  values:
    - minikube
  ```
* ✅ Create a `StorageClass` with `provisioner: kubernetes.io/no-provisioner` for local volumes.


Below is the same YAML with comments explaining **what each field does**. This is useful for interview preparation and understanding the purpose of every field.

```yaml
apiVersion: v1                    # API version used for PersistentVolume
kind: PersistentVolume            # Defines this resource as a PersistentVolume (PV)

metadata:
  name: local-volume              # Name of the PersistentVolume

spec:
  capacity:
    storage: 1Gi                  # Total storage capacity provided by this PV

  volumeMode: Filesystem          # Exposes the volume as a mounted filesystem
                                  # (Other option: Block)

  accessModes:
    - ReadWriteOnce               # Volume can be mounted as read-write by only one node

  persistentVolumeReclaimPolicy: Retain
                                  # What happens when the PVC is deleted
                                  # Retain -> Keeps the data
                                  # Delete -> Deletes the underlying storage (if supported)
                                  # Recycle -> Deprecated

  storageClassName: local-storage # StorageClass this PV belongs to
                                  # PVC must use the same StorageClass to bind

  local:
    path: /mnt/disk/local1        # Directory on the node where data is stored
                                  # This directory MUST already exist on the node

  nodeAffinity:                   # Restricts this PV to a specific node
                                  # Required for Local PersistentVolumes

    required:
      nodeSelectorTerms:
        - matchExpressions:
            - key: kubernetes.io/hostname
                                  # Node label used to identify the node
                                  # Find it using:
                                  # kubectl get nodes --show-labels
                                  # or
                                  # kubectl describe node <node-name>

              operator: In        # Match if the node label value is in the list below

              values:
                - minikube        # Only the node whose hostname label is "minikube"
                                  # can use this PersistentVolume
```

### Flow of how this works

```text
Node (minikube)
│
├── /mnt/disk/local1  <-- Actual directory on the node
│
└── PersistentVolume (PV)
      │
      └── StorageClass = local-storage
             │
             └── PersistentVolumeClaim (PVC)
                    │
                    └── Pod
                           │
                           └── Mounted inside the container
```

### Interview Questions

**Q1. Why is `nodeAffinity` mandatory for Local PersistentVolumes?**

* Because the storage exists on **only one node**. Kubernetes needs to know which node contains the data so it schedules the Pod there.

**Q2. Why do we specify `storageClassName`?**

* It ensures that only PVCs requesting the same StorageClass can bind to this PV.

**Q3. What happens if `/mnt/disk/local1` does not exist?**

* The PV may be created, but Pods using it will fail to mount the volume until the directory exists.

**Q4. Why use `Retain`?**

* It preserves the data even after the PVC is deleted, allowing manual recovery or reuse.

**Q5. Why use `ReadWriteOnce`?**

* A local disk is attached to a single node, so it can only be mounted as read-write by one node at a time.


Below are your notes rewritten with explanations and comments for each step.

---

# Step 1: Verify the PersistentVolume (PV)

Apply the PV YAML.

```bash
kubectl apply -f local-vol-example.yaml
```

Check whether the PV has been created.

```bash
kubectl get pv
```

Expected output:

```text
NAME           CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      STORAGECLASS
local-volume   1Gi        RWO            Retain           Available   local-storage
```

Get detailed information about the PV.

```bash
kubectl describe pv local-volume
```

This shows:

* Capacity
* Access Mode
* StorageClass
* Node Affinity
* Events
* Current Status (Available/Bound)

---

# Step 2: Create a PersistentVolumeClaim (PVC)

Create a new file.

```bash
touch local-pvc.yaml
```

Add the following YAML.

```yaml
apiVersion: v1                         # Kubernetes API version
kind: PersistentVolumeClaim            # Creates a PersistentVolumeClaim (PVC)

metadata:
  name: local-volume-claim             # Name of the PVC

spec:
  accessModes:
    - ReadWriteOnce                    # Request ReadWriteOnce access

  storageClassName: local-storage      # Must match the PV StorageClass

  resources:
    requests:
      storage: 2Gi                     # Requesting 2Gi of storage

  volumeMode: Filesystem               # Request a filesystem volume
```

---

# Step 3: Apply the PVC

```bash
kubectl apply -f local-pvc.yaml
```

Check the PVC.

```bash
kubectl get pvc
```

Describe the PVC.

```bash
kubectl describe pvc local-volume-claim
```

---

# Why does it fail?

Your **PersistentVolume (PV)** is:

```text
1Gi
```

But your **PersistentVolumeClaim (PVC)** requests:

```text
2Gi
```

Kubernetes **cannot bind** a PVC requesting more storage than the PV provides.

Expected status:

```text
STATUS: Pending
```

Events may include messages similar to:

```text
waiting for a volume to be created
no persistent volumes available for this claim
```

or

```text
requested storage exceeds available capacity
```

---

# Step 4: Delete the PVC

```bash
kubectl delete pvc local-volume-claim
```

---

# Step 5: Update the PVC

Modify the storage request to **1Gi**, matching the PV.

```yaml
apiVersion: v1                         # Kubernetes API version
kind: PersistentVolumeClaim            # Creates a PVC

metadata:
  name: local-volume-claim             # PVC name

spec:
  accessModes:
    - ReadWriteOnce                    # Same access mode as the PV

  storageClassName: local-storage      # Must match the PV StorageClass

  resources:
    requests:
      storage: 1Gi                     # Matches the PV capacity

  volumeMode: Filesystem               # Filesystem volume
```

---

# Step 6: Apply the PVC Again

```bash
kubectl apply -f local-pvc.yaml
```

Check the PVC.

```bash
kubectl get pvc
```

Expected output:

```text
NAME                 STATUS   VOLUME         CAPACITY   ACCESS MODES   STORAGECLASS
local-volume-claim   Bound    local-volume   1Gi        RWO            local-storage
```

---

# Verify the Binding

Describe the PVC.

```bash
kubectl describe pvc local-volume-claim
```

Describe the PV.

```bash
kubectl describe pv local-volume
```

You should see:

```text
Status: Bound
Claim: default/local-volume-claim
```

---

# What does `STATUS=Bound` mean?

When the PVC status is **Bound**, it means:

* ✅ Kubernetes found a matching PersistentVolume.
* ✅ The PV and PVC are successfully linked.
* ✅ A Pod can now mount this PVC and use the storage.

---

# Interview Questions

### Q1. Why did the first PVC fail?

Because the PVC requested **2Gi**, but the available PV had only **1Gi** of storage.

---

### Q2. What conditions must match for a PV and PVC to bind?

* StorageClass
* Requested storage must be **less than or equal to** the PV capacity
* AccessModes must be compatible
* VolumeMode must match

---

### Q3. What does `Pending` mean?

The PVC is waiting for a suitable PersistentVolume and has not yet been bound.

---

### Q4. What does `Bound` mean?

The PVC has successfully claimed a matching PersistentVolume and is ready for use by Pods.

---

### Q5. Can a PVC request less storage than the PV?

Yes. For example:

* PV = **10Gi**
* PVC = **5Gi**

The PVC can bind successfully. The remaining capacity is not automatically available to another PVC because a PV can be bound to only one PVC at a time.



Once your **PersistentVolume (PV)** and **PersistentVolumeClaim (PVC)** are in the **Bound** state, you can mount the PVC into a Pod.

---

# Step 1: Verify the PVC is Bound

```bash
kubectl get pvc
```

Expected output:

```text
NAME                 STATUS   VOLUME         CAPACITY   ACCESS MODES   STORAGECLASS
local-volume-claim   Bound    local-volume   1Gi        RWO            local-storage
```

If the status is **Bound**, you're ready to use it in a Pod.

---

# Step 2: Create a Pod YAML

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
spec:
  containers:
    - name: nginx
      image: nginx:latest

      volumeMounts:
        - name: my-storage
          mountPath: /usr/share/nginx/html
          # Directory inside the container where the PVC is mounted

  volumes:
    - name: my-storage
      persistentVolumeClaim:
        claimName: local-volume-claim
        # Name of the PVC to attach
```

---

# Step 3: Apply the Pod

```bash
kubectl apply -f pod.yaml
```

Verify the Pod is running:

```bash
kubectl get pods
```

Expected output:

```text
NAME        READY   STATUS    RESTARTS   AGE
nginx-pod   1/1     Running   0          20s
```

---

# Step 4: Verify the Volume is Mounted

Open a shell inside the Pod:

```bash
kubectl exec -it nginx-pod -- /bin/bash
```

If `/bin/bash` isn't available:

```bash
kubectl exec -it nginx-pod -- /bin/sh
```

Check the mounted directory:

```bash
cd /usr/share/nginx/html
ls -l
```

Create a test file:

```bash
echo "Hello Kubernetes" > test.txt
```

Verify it exists:

```bash
cat test.txt
```

Output:

```text
Hello Kubernetes
```

---

# Step 5: Verify the Data on the Node

Since this is a **Local PersistentVolume**, the data is stored on the node.

If you're using **Minikube**:

```bash
minikube ssh
```

Check the directory:

```bash
cd /mnt/disk/local1
ls -l
cat test.txt
```

Output:

```text
Hello Kubernetes
```

This confirms the Pod is writing directly to the local disk.

---

# How It Works

```text
                Pod
        +------------------+
        |      nginx       |
        |                  |
        | /usr/share/      |
        | nginx/html       |
        +--------+---------+
                 |
           volumeMount
                 |
        +--------v---------+
        | PersistentVolume |
        |      Claim       |
        | local-volume-claim |
        +--------+---------+
                 |
             Bound to
                 |
        +--------v---------+
        | PersistentVolume |
        |  local-volume    |
        +--------+---------+
                 |
          local.path
                 |
        /mnt/disk/local1
        (Node filesystem)
```

---

## Interview Questions

**Q1. What is `volumeMounts`?**

* It specifies **where inside the container** the storage is mounted.

**Q2. What is `volumes`?**

* It defines **which storage source** the Pod uses (in this case, a PVC).

**Q3. What is `claimName`?**

* It is the name of the **PersistentVolumeClaim** that the Pod should use.

**Q4. Does the Pod use the PV directly?**

* No. The Pod always uses a **PersistentVolumeClaim (PVC)**. Kubernetes binds the PVC to the appropriate PV.

**Q5. What happens if the Pod is deleted?**

* The data remains on the PersistentVolume because the storage is independent of the Pod. If the PV's reclaim policy is `Retain`, the data is preserved even after the PVC is deleted until you clean it up manually.


# Hands-on: Mounting a PersistentVolume to a Pod (Local PersistentVolume)

In this hands-on, you'll learn:

* Create a Local PersistentVolume (PV)
* Create a PersistentVolumeClaim (PVC)
* Mount the PVC inside a Pod
* Verify data persistence
* Verify the same PVC can be accessed by another Pod on the same node
* Understand **why** each step is required

---

# Architecture

```text
                  Kubernetes Cluster

        +------------------------------------+

             PersistentVolume (PV)
        +------------------------------------+
        | local-volume                       |
        | Storage: 1Gi                       |
        | Path: /mnt/disks/local1            |
        +----------------+-------------------+
                         |
                    Bound To
                         |
        +----------------v-------------------+
        | PersistentVolumeClaim (PVC)        |
        | local-volume-claim                 |
        +----------------+-------------------+
                         |
             Mounted inside Pods
                /mnt/local
                /mnt/local2
         +---------------+---------------+
         |                               |
+--------v--------+             +--------v--------+
| local-vol-pod   |             | local-vol-pod2  |
+-----------------+             +-----------------+

Both Pods read/write the same storage.
```

---

# Complete YAML

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: local-volume                 # Name of the PersistentVolume

spec:
  capacity:
    storage: 1Gi                     # Total storage available

  volumeMode: Filesystem             # Expose storage as a filesystem

  accessModes:
    - ReadWriteOnce                  # Read/Write by one node

  persistentVolumeReclaimPolicy: Retain
                                    # Keep data even after PVC deletion

  storageClassName: local-storage    # StorageClass

  local:
    path: /mnt/disks/local1          # Actual directory on the node

  nodeAffinity:                      # Required for Local PV
    required:
      nodeSelectorTerms:
        - matchExpressions:
            - key: kubernetes.io/hostname
              operator: In
              values:
                - minikube
---
apiVersion: v1
kind: PersistentVolumeClaim

metadata:
  name: local-volume-claim

spec:
  resources:
    requests:
      storage: 1Gi                  # Must be <= PV size

  volumeMode: Filesystem

  accessModes:
    - ReadWriteOnce

  storageClassName: local-storage
---
apiVersion: v1
kind: Pod

metadata:
  name: local-vol-pod

spec:
  containers:
    - name: busybox
      image: busybox:1.36.1

      command:
        - sh
        - -c
        - sleep 3600

      volumeMounts:
        - name: local-storage
          mountPath: /mnt/local      # Mounted inside container

  volumes:
    - name: local-storage
      persistentVolumeClaim:
        claimName: local-volume-claim
---
apiVersion: v1
kind: Pod

metadata:
  name: local-vol-pod2

spec:
  containers:
    - name: busybox
      image: busybox:1.36.1

      command:
        - sh
        - -c
        - sleep 3600

      volumeMounts:
        - name: local-storage
          mountPath: /mnt/local2

  volumes:
    - name: local-storage
      persistentVolumeClaim:
        claimName: local-volume-claim
```

---

# Step 1 Apply everything

```bash
kubectl apply -f local-vol-example.yaml
```

Check resources.

```bash
kubectl get pv
kubectl get pvc
kubectl get pods
```

---

# Problem 1

Pod stays in

```
ContainerCreating
```

Why?

Describe the pod.

```bash
kubectl describe pod local-vol-pod
```

Near the bottom you'll see

```
Warning FailedMount
MountVolume.NewMounter initialization failed
```

or

```
path "/mnt/disks/local1" does not exist
```

---

# Why did this happen?

Your PV says

```yaml
local:
  path: /mnt/disks/local1
```

Kubernetes expects this directory to already exist.

Unlike hostPath, Kubernetes **does not create it automatically**.

Since the folder doesn't exist,

the volume cannot be mounted.

---

# Step 2 Delete the pod

```bash
kubectl delete pod local-vol-pod
```

---

# Step 3 Login into Minikube

Find node

```bash
kubectl get nodes
```

SSH

```bash
minikube ssh
```

Create the directory

```bash
sudo mkdir -p /mnt/disks/local1
```

Give permissions

```bash
sudo chmod 777 /mnt/disks/local1
```

Verify

```bash
cd /mnt/disks/local1

ls
```

Exit

```bash
exit
```

---

# Step 4 Apply Again

```bash
kubectl apply -f local-vol-example.yaml
```

Now check

```bash
kubectl get pods
```

Output

```
NAME
local-vol-pod

STATUS
Running
```

Why?

Now Kubernetes successfully mounted

```
/mnt/disks/local1
```

into

```
/mnt/local
```

inside the container.

---

# Step 5 Enter the Pod

```bash
kubectl exec -it local-vol-pod -- sh
```

Go to mount point

```bash
cd /mnt/local
```

Create a file

```bash
echo "Hello" > hello.txt
```

Verify

```bash
cat hello.txt
```

Output

```
Hello
```

Exit

```bash
exit
```

---

# Step 6 Verify on the Node

SSH

```bash
minikube ssh
```

Go to directory

```bash
cd /mnt/disks/local1
```

List files

```bash
ls
```

Output

```
hello.txt
```

Read it

```bash
cat hello.txt
```

Output

```
Hello
```

---

# Why?

Inside the Pod

```
/mnt/local
```

is simply another view of

```
/mnt/disks/local1
```

on the node.

They point to the same storage.

```
Pod

/mnt/local
     |
     |
     V

Node

/mnt/disks/local1
```

---

# Step 7 Delete the Pod

```bash
kubectl delete pod local-vol-pod --force
```

Check

```bash
kubectl get pods
```

No pod exists.

---

# Step 8 Create Pod Again

```bash
kubectl apply -f local-vol-example.yaml
```

Wait

```bash
kubectl get pods
```

Running

---

# Step 9 Verify Data

Enter pod

```bash
kubectl exec -it local-vol-pod -- sh
```

Read

```bash
cat /mnt/local/hello.txt
```

Output

```
Hello
```

---

# Why didn't the file disappear?

Deleting a Pod deletes

* Container
* Process
* Memory

It **does not delete the PersistentVolume**.

The data lives on

```
/mnt/disks/local1
```

outside the Pod.

This is exactly why PersistentVolumes exist.

---

# Step 10 Create Pod2

Apply again with Pod2.

```bash
kubectl apply -f local-vol-example.yaml
```

Check

```bash
kubectl get pods
```

```
local-vol-pod
local-vol-pod2
```

---

# Enter Pod2

```bash
kubectl exec -it local-vol-pod2 -- sh
```

Go to

```bash
cd /mnt/local2
```

List

```bash
ls
```

Output

```
hello.txt
```

Read

```bash
cat hello.txt
```

Output

```
Hello
```

---

# Why does Pod2 see the same file?

Both Pods mount the **same PVC**, which is already bound to the same PV. Since both mount the same underlying directory (`/mnt/disks/local1`) on the same node, they see the same files.

```
                  Node

          /mnt/disks/local1
          ------------------
          hello.txt
          notes.txt
          logs/

                ▲
                │
      +---------+---------+
      |                   |
      |                   |
+-----+------+     +------+------+
| Pod 1       |     | Pod 2       |
| /mnt/local  |     | /mnt/local2 |
+-------------+     +-------------+
```

---

# Important Note About `ReadWriteOnce (RWO)`

`ReadWriteOnce` means the volume can be mounted as read-write by **one node** at a time.

* ✅ Multiple Pods **on the same node** can use the same RWO volume if Kubernetes allows the workload placement.
* ❌ Pods on **different nodes** cannot simultaneously mount the same RWO volume.

---

# Interview Questions

### Why do we use a PVC instead of directly mounting a PV?

Pods should not depend directly on specific storage. A PVC acts as an abstraction layer, allowing Kubernetes to bind an appropriate PV and making applications portable.

---

### Why did the Pod fail with `FailedMount`?

Because the local path `/mnt/disks/local1` did not exist on the node. Local PersistentVolumes require the directory to be created manually.

---

### Why does the file still exist after deleting the Pod?

The data is stored on the PersistentVolume, which exists independently of the Pod. Deleting the Pod only removes the container, not the underlying storage.

---

### Why can Pod2 read the same file?

Because both Pods are mounting the same PVC, which is bound to the same PV backed by the same local directory.

---

### What is the difference between `mountPath` and `local.path`?

| Field        | Location             | Purpose                                                   |
| ------------ | -------------------- | --------------------------------------------------------- |
| `local.path` | Node                 | The actual directory where data is stored.                |
| `mountPath`  | Inside the container | The location where the application accesses that storage. |

For example:

```
Node:
/mnt/disks/local1

Container:
/mnt/local
```

Both paths reference the same underlying data.





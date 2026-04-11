Good question — this is **very important for DevOps + Linux fundamentals**.
Let’s go step by step to **see VM config (CPU, RAM, Disk) in RHEL** 👇

---

# 🖥️ ✅ 1. Check CPU details

```bash
lscpu
```

👉 Shows:

* CPU cores
* Architecture
* vCPU count
* Hypervisor (GCP/AWS etc.)

---

# 🧠 ✅ 2. Check RAM (Memory)

### Simple view:

```bash
free -h
```

👉 Output:

* total RAM
* used / free
* swap

---

### Detailed view:

```bash
cat /proc/meminfo
```

---

# 💽 ✅ 3. Check Disk (Storage)

### Disk usage:

```bash
df -h
```

👉 Shows:

* total disk
* used
* available
* mount points

---

### Disk devices:

```bash
lsblk
```

👉 Shows:

* disks (sda, vda)
* partitions
* sizes

---

# ⚙️ ✅ 4. Full system hardware info

```bash
sudo lshw -short
```

👉 Shows:

* CPU
* RAM
* disk
* network

(If not installed 👇)

```bash
sudo dnf install lshw -y
```

---

# 🧾 ✅ 5. Complete VM summary (BEST COMMAND 🔥)

```bash
hostnamectl
```

👉 Shows:

* OS
* kernel
* architecture

---

# 🧠 ✅ 6. Check virtualization (very important in cloud)

```bash
systemd-detect-virt
```

👉 Output examples:

* `kvm`
* `vmware`
* `gcp`

---

# 🔥 ✅ 7. One-liner (Quick overview)

```bash
echo "CPU:" && lscpu | grep 'CPU(s)' && echo "RAM:" && free -h && echo "Disk:" && df -h /
```

---

# 📊 ✅ Example Output (what you’ll see)

```
CPU: 2
RAM: 1.0G
Disk: 10G
```

---

# 🚀 Pro DevOps Commands (useful in real projects)

### Check running processes using RAM

```bash
top
```

or

```bash
htop
```

---

### Check disk I/O

```bash
iostat
```

---

### Check inode usage (important for servers)

```bash
df -i
```

---

# 🎯 Summary


| Resource       | Command   |
| -------------- | --------- |
| CPU            | `lscpu`   |
| RAM            | `free -h` |
| Disk usage     | `df -h`   |
| Disk structure | `lsblk`   |
| Full hardware  | `lshw`    |

---

## 👍 My Recommendation (for you)

Since you're learning DevOps:

👉 Use these daily:

```bash
lscpu
free -h
df -h
lsblk
top
```

---

If you want next level 🔥
I can teach you:

✅ Monitor VM like production (Grafana + Prometheus)
✅ Check bottlenecks (CPU vs RAM vs Disk)
✅ Real-world debugging commands

Just tell 👍

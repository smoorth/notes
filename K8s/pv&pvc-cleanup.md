# Kubernetes PV & PVC Cleanup Guide

## Overview

This guide provides steps to clean up **Released** Persistent Volumes (PVs), unbound Persistent Volume Claims (PVCs), and orphaned cloud storage resources in **AWS, GCP, and Azure**.

---

## List Released PVs

Before deletion, check which PVs are in `Released` state:

```sh
kubectl get pv | grep Released
```

---

## Delete All Released PVs

To remove all **Released** PVs:

```sh
kubectl get pv --no-headers | awk '$5=="Released" {print $1}' | xargs kubectl delete pv
```

---

## Cleanup Any Orphaned PVCs

List all PVCs:

```sh
kubectl get pvc --all-namespaces
```

To delete all unused PVCs:

```sh
kubectl delete pvc --all
```

Or delete selectively:

```sh
kubectl delete pvc <pvc-name> -n <namespace>
```

---

## Ensure Cloud Storage Is Released (For Cloud Users)

### AWS: Find & Delete Orphaned Volumes

List **unattached** AWS EBS volumes:

```sh
aws ec2 describe-volumes --filters Name=status,Values=available
```

Delete unused volumes:

```sh
aws ec2 delete-volume --volume-id <volume-id>
```

### GCP: Find & Delete Orphaned Disks

List unattached disks:

```sh
gcloud compute disks list --filter="-users:*"
```

Delete unused disks:

```sh
gcloud compute disks delete <disk-name> --zone=<zone>
```

### Azure: Find & Delete Unused Disks

List unattached disks:

```sh
az disk list --query "[?managedBy==null].{name:name, resourceGroup:resourceGroup}"
```

Delete a disk:

```sh
az disk delete --name <disk-name> --resource-group <resource-group> --yes
```

---

## Automating Cleanup

If this is a recurring issue, consider:

- Using a **StorageClass with `Delete` reclaim policy** for automatic cleanup.
- Setting up a **cron job** to periodically clean up unused PVs and PVCs.

Example cron job to delete Released PVs every day at midnight:

```sh
0 0 * * * kubectl get pv --no-headers | awk '$5=="Released" {print $1}' | xargs kubectl delete pv
```

---

## Important Notes

- **Double-check before deleting!** This action permanently removes storage and cannot be undone.
- If needed, manually back up important data before proceeding.

# Certified Kubernetes Administrator (CKA) Study Guide

## 1. Overview of the CKA Exam

- **Exam Format**: Performance-based, ~15–20 tasks, 2 hours.
- **Topics**:
  - Cluster Architecture, Installation & Configuration (25%)
  - Workloads & Scheduling (15%)
  - Services & Networking (20%)
  - Storage (10%)
  - Troubleshooting (30%)

---

## 2. Study Path

### Phase 1: Understanding Kubernetes Basics

Start with foundational knowledge to understand Kubernetes architecture and concepts.

#### Pluralsight Courses - Basics

- [Kubernetes Fundamentals](https://www.pluralsight.com/courses/kubernetes-fundamentals)
  Covers the core concepts of Kubernetes, including Pods, Deployments, and Services.

#### External Tools & Resources

- **Minikube**: Set up a single-node Kubernetes cluster locally for practice.
  [Minikube Installation Guide](https://minikube.sigs.k8s.io/docs/start/)
- **Kubernetes Documentation**:
  [Kubernetes Concepts](https://kubernetes.io/docs/concepts/)

---

### Phase 2: Core Kubernetes Administration Skills

Deepen your understanding of core administrative tasks.

#### Pluralsight Courses - Core skills

- [Managing Kubernetes Applications](https://www.pluralsight.com/courses/managing-kubernetes-applications)
  Focuses on configuring and managing workloads.

- [Kubernetes Networking](https://www.pluralsight.com/courses/kubernetes-networking)
  Learn how networking works within Kubernetes clusters.

- [Kubernetes Storage](https://www.pluralsight.com/courses/kubernetes-storage)
  Understand persistent and ephemeral storage in Kubernetes.

#### Practice Tools

- **Kind**: Set up multi-node clusters using Kubernetes in Docker.
  [Kind Installation Guide](https://kind.sigs.k8s.io/)
- **Katacoda**: Free, browser-based Kubernetes practice environments.
  [Katacoda Kubernetes Scenarios](https://www.katacoda.com/courses/kubernetes)

---

### Phase 3: Troubleshooting and Advanced Topics

This phase focuses on troubleshooting, which is 30% of the exam.

#### Pluralsight Courses - Advanced

- [Kubernetes Troubleshooting](https://www.pluralsight.com/courses/kubernetes-troubleshooting)
  Learn how to debug and resolve common Kubernetes issues.

#### External Tools

- **Killer.sh**: Official exam simulator to practice troubleshooting in a real exam-like environment.
  [Killer.sh Website](https://killer.sh/)

#### Documentation

- [Troubleshooting Applications](https://kubernetes.io/docs/tasks/debug-application-cluster/debug-application/)

---

### Phase 4: Exam Simulation

Time management and familiarity with the exam interface are critical.

#### Steps

1. Complete the **Killer.sh Simulator** (available free with your exam registration).
2. Use the [CKA Practice Exam from KodeKloud](https://kodekloud.com/courses/certified-kubernetes-administrator-cka-practice-exam/) for additional practice.

---

## 3. Tools and Setup

### Tools to Install Locally

- **kubectl**: Command-line tool for Kubernetes.
  [Install kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

- **Minikube**: Lightweight Kubernetes for local practice.
  [Install Minikube](https://minikube.sigs.k8s.io/docs/start/)

- **Kind**: Kubernetes in Docker for multi-node clusters.
  [Install Kind](https://kind.sigs.k8s.io/)

- **VS Code with Kubernetes Extension**: For easier YAML editing and cluster management.
  [Install VS Code](https://code.visualstudio.com/)

### Online Resources

- **Kubernetes Documentation**:
  [Kubernetes Official Docs](https://kubernetes.io/docs/)

- **CKA Exam Tips**:
  [CKA Tips and Tricks](https://kodekloud.com/cka-tips/)

---

## 4. Study Schedule

| Week | Focus Area                                      | Resources                                    | Practice Tasks                                 |
|------|------------------------------------------------|---------------------------------------------|-----------------------------------------------|
| 1    | Kubernetes Basics                              | Kubernetes Fundamentals (Pluralsight)       | Set up Minikube and deploy simple workloads.  |
| 2    | Workloads & Scheduling                         | Managing Kubernetes Applications            | Practice Pod, Deployment, and CronJob tasks. |
| 3    | Services & Networking                          | Kubernetes Networking                       | Explore Services, Ingress, and NetworkPolicies. |
| 4    | Storage & Persistent Volumes                   | Kubernetes Storage                          | Practice creating PersistentVolumes and Claims. |
| 5    | Troubleshooting                                | Kubernetes Troubleshooting                  | Debug failed Pods, troubleshoot Services.    |
| 6    | Exam Simulation                                | Killer.sh + KodeKloud Practice Exams        | Complete full-length mock exams.             |

---

## 5. Additional Tips

1. **Time Management**: Prioritize easier questions during the exam to secure marks early.
2. **Documentation Familiarity**: Practice using Kubernetes documentation efficiently during preparation.
3. **Aliases and Shortcuts**: Set up `kubectl` aliases for faster commands, e.g., `alias k=kubectl`.
4. **Mock Exams**: Simulate real exam conditions to build confidence.

# LLMs on EKS

**Hands-on guide series for running open-source Large Language Models on Amazon EKS.**

Each guide is a self-contained directory with working infrastructure code, Kubernetes manifests,
shell scripts, real benchmark results, and a detailed README. Provision the shared EKS cluster
once in Guide 001 — every subsequent guide deploys a new workload on top of it.

![Guides Released](https://img.shields.io/badge/guides_released-2-brightgreen)
![EKS](https://img.shields.io/badge/Amazon_EKS-1.32-FF9900?logo=amazon-aws&logoColor=white)
![Karpenter](https://img.shields.io/badge/Karpenter-v1.15.1-326CE5?logo=kubernetes&logoColor=white)
![vLLM](https://img.shields.io/badge/vLLM-0.32.0-7B2FBE)
![License](https://img.shields.io/badge/license-Apache_2.0-blue)

---

## Quick Start

```bash
git clone https://github.com/paularinzee/llm-on-eks-project.git
cd llm-on-eks-project

export AWS_PROFILE=your-aws-profile
export AWS_REGION=us-east-1

# Step 1: Deploy the shared EKS cluster (once, ~25 min)
bash guides/001-prerequisites/scripts/deploy.sh
bash guides/001-prerequisites/scripts/verify.sh

# Step 2: Run Llama 3.2 1B on CPU — no GPU, no quota needed
bash guides/002-cpu-inference-vllm/scripts/deploy.sh

# Step 3: Test it
kubectl port-forward -n llm-serving svc/vllm-cpu 8000:8000 &
curl http://localhost:8000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"model":"llama-3.2-1b","messages":[{"role":"user","content":"What is Karpenter?"}],"max_tokens":150}'
```

---

## Available Guides

| # | Guide | What you learn | GPU | Cost/hr | Time |
|---|-------|---------------|:---:|---------|------|
| [001](guides/001-prerequisites/README.md) | Prerequisites & Cluster Setup | EKS 1.32, Karpenter v1.15.1, NodePools, CloudFormation | ❌ |
| [002](guides/002-cpu-inference-vllm/README.md) | CPU Inference with vLLM | vLLM CPU backend, OpenAI API, EBS model cache, benchmarks | ❌ |
<!-- | [003](guides/003-gpu-inference-vllm/README.md) | GPU Inference with vLLM | NVIDIA A10G, GPU scheduling, 200× throughput vs CPU | ✅ | ~$1.24 | ~15 min | -->

---

## How the Shared Cluster Works

One EKS cluster, provisioned once in Guide 001. All guides reuse it.

```
EKS: llms-on-eks  (EKS 1.32, Terraform-managed)
│
├── System Managed Node Group
│     2x t3.medium, always-on ($0.04/hr)
│     Hosts: CoreDNS, aws-node, Karpenter controller
│
└── Karpenter NodePools  (zero nodes when idle — $0 cost)
      ┌─────────────┬──────────────────────────────────────────┐
      │ NodePool    │ Instances           │ Used by             │
      ├─────────────┼──────────────────────────────────────────┤
      │ cpu         │ t3.xlarge/2xlarge   │ Guide 002 CPU infer │
      │ gpu         │ g5.xlarge/12xlarge  │ Guide 003+ GPU infer│
      │ gpu-spot    │ g5/g4dn spot        │ Guide 009 load test │
      │ system      │ t3.medium/large     │ monitoring, gateway │
      └─────────────┴──────────────────────────────────────────┘
```

GPU nodes are terminated within ~5 minutes of deleting a workload.
You only pay for compute while an LLM is actually running.

---

## Technology Stack

| Layer | Technology | Version |
|-------|-----------|---------|
| Kubernetes | Amazon EKS | 1.32 |
| Node autoscaling | Karpenter | v1.15.1 |
| GPU management | NVIDIA GPU Operator | 24.x |
| Primary inference | vLLM | 0.32.0 |
| Advanced inference | SGLang | — |
| API gateway | LiteLLM | — |
| Autoscaling | KEDA | — |
| Observability | Prometheus + Grafana + DCGM | — |
| Model storage | Amazon EFS | — |
| Load testing | genai-perf, Locust | — |
| Infrastructure | Terraform | — |


---

## Repository Structure

```
llms-on-eks/
├── README.md                         ← you are here
├── .gitignore
├── LICENSE
│
├── guides/                           ← one self-contained guide per directory
│   ├── 001-prerequisites/
│   │   ├── k8s/                      ← karpenter-nodepool.yaml
│   │   └── scripts/                  ← deploy.sh / verify.sh / destroy.sh
│   │   ├── terraform/                ← backend.tf / data.tf / eks.tf / iam.tf / karpenter.tf / main.tf / outputs.tf / security-groups.tf / variables.tf / versions.tf / vpc.tf
│   ├── 002-cpu-inference-vllm/
│   │   ├── k8s/                      ← vllm-cpu.yaml
│   │   └── scripts/                  ← deploy.sh / test.sh
```

---

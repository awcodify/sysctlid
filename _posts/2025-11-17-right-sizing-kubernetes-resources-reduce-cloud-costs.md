---
layout: post
title: "Right-Sizing Kubernetes Resources: Cut Cloud Costs by 30–50% Without Performance Loss"
categories: [kubernetes, performance, cost-optimization]
tags: [kubernetes, right-sizing, kubecost, vpa, prometheus]
description: "Step-by-step guide to audit Kubernetes resource requests, identify over-provisioning waste, and implement safe right-sizing strategies using Prometheus, VPA, and Kubecost."
image: right-sizing-kubernetes.webp
---

Kubernetes is powerful, but it's easy to pay for capacity you don't use. This guide shows how to audit actual resource usage, identify over-provisioning, and apply safe right-sizing strategies that cut cloud costs while preserving performance.
<!--more-->

Why this matters: many teams discover clusters running far below requested CPU and memory, causing avoidable cloud bills. The steps below are pragmatic and designed for engineering teams and SREs who need measurable results, not theory.

## Why Most Kubernetes Deployments Waste Resources

Over-provisioning usually comes from three causes: conservative default requests carried over from legacy apps, fear of OOMKill or throttling, and lack of visibility into actual usage. Teams duplicate safety margins across many services and environments, and the waste compounds.

Before you change anything, measure. Right-sizing starts with good metrics, then you make incremental, validated changes.

## Establishing a Baseline: Measure Actual vs Requested

You need to compare observed usage with requested resources. If you rely on Prometheus and the Kubernetes metrics pipeline, start with these PromQL queries (copy-paste into Grafana or Prometheus UI):

CPU utilization ratio (per pod):

```
sum by (pod) (rate(container_cpu_usage_seconds_total{image!="",container!=""}[5m]))
/
sum by (pod) (kube_pod_container_resource_requests_cpu_cores)
```

Find low-CPU pods (example: under 100m average):

```
avg_over_time(rate(container_cpu_usage_seconds_total{image!="",container!=""}[5m])[1h:]) < 0.1
```

Memory utilization ratio (per pod):

```
sum by(pod) (container_memory_usage_bytes{container!="",pod!=""})
/
sum by(pod) (kube_pod_container_resource_requests_memory_bytes)
```

Collect 1–4 weeks of production data to capture periodic peaks (daily/weekly/monthly). Short samples hide bursty workloads.

### Tools to consider

- Kubecost: per-pod cost attribution and right-sizing recommendations.
- Vertical Pod Autoscaler (VPA): run in recommendation mode to generate safe suggestions without applying them.
- DIY: Prometheus + Grafana dashboards if you prefer full control.

## What Good Utilization Looks Like

- Stateless services: aim for 60–75% peak CPU utilization (headroom for spikes).
- Statefull databases/caches: keep higher safety margins (50–70%).
- Memory: target 40–70% typical usage; memory doesn't release like CPU, so be conservative when lowering limits.

Benchmarks vary by workload. Use these as starting points, then validate with latency and error metrics.

## Identify Over-Provisioning Patterns

Common patterns:
- Legacy migration: microservices inherit monolithic resource estimates.
- Safety-margin fallacy: doubling/tripling requests to avoid OOMKill.
- No accountability: multi-team clusters without cost attribution.

Recognize which pattern matches your environment, each needs a slightly different remediation approach.

## Step-by-Step: Right-Sizing Without Downtime

This is a phased, low-risk approach you can replicate across teams.

### Phase 1 ,  Audit and Baseline (1–2 weeks)

1. Collect metrics for at least one week (four is better) from production and high-load windows.
2. Run VPA in `recommendation` mode to gather per-deployment suggestions:
  ```yaml
  apiVersion: autoscaling.k8s.io/v1
  kind: VerticalPodAutoscaler
  metadata:
    name: audit-vpa
  spec:
    targetRef:
      apiVersion: "apps/v1"
      kind: Deployment
      name: my-service
    updatePolicy:
      updateMode: "off"  # recommendation mode only
  ```
3. Use Kubecost (or your billing source) to map resource requests to dollars so you can quantify impact.

### Phase 2 ,  Validate Recommendations (1 week)

Before applying recommendations, cross-check them against application-level SLIs:

- P95 latency and error rate: these should not increase after a resource reduction.
- CPU throttling / OOMKill correlation: if throttling correlates with higher latency, keep the higher request or tune the code.

If performance degrades, rollback or increase limits for that workload. The goal is safe, validated reductions, never aggressive blanket changes.

### Phase 3 ,  Incremental Application (2–4 weeks)

Roll changes out in stages:

- Start with non-customer-facing services (CI runners, internal tools).
- Apply 20–30% reductions first, monitor for 48–72 hours, then continue.
- Track every change: service name, old/new request, percent change, metrics observed, owner.

This gives a clear audit trail and reduces blast radius.

### Phase 4 ,  Continuous Optimization (Ongoing)

- Set alerts for pods running consistently below 30% of requested CPU or above 90% memory.
- Schedule monthly reviews; automate reports for teams showing their cost and utilization trends.

## Quantifying Savings: From Metrics to Budget Impact

Example (simplified):

- Before: 200 requested CPUs, 400 GB memory at on-demand pricing.
- Observed: 25 CPUs and 80 GB actual usage.
- After right-sizing (plus 20% safety margin): ~30 CPUs, 96 GB.

The monthly savings can be dramatic. Use your cloud provider pricing to convert cores/GB-hours to dollars and present an ROI to stakeholders (engineering hours invested vs. monthly savings).

## Tools and Automation

- VPA: safe for recommendations and automation when paired with careful validation.
- Kubecost: best for cost attribution and easy dashboards.
- Cast AI and similar platforms: deeper automation (spot instances, predictive scaling) but need evaluation.

Pick tools that fit your team's comfort with operational overhead vs. managed convenience.

## Common Pitfalls and How to Avoid Them

- Over‑aggressive memory reductions → OOMKill. Mitigation: keep 20–30% headroom and monitor OOM events.
- Ignoring burst patterns → time-windowed analysis (at least 4 weeks).
- Forgetting to adjust HPA after changing requests. Recalibrate HPA thresholds and min/max replicas.

## Need help implementing this?

If you'd rather not run the full audit yourself, consider a lightweight implementation engagement at [optimize](https://optimize.sysctl.id). We offer short audits, VPA recommendation validation, Kubecost dashboard setup, and incremental rollout support, practical help designed to deliver measurable savings without disrupting production.

# Terraform EKS Cluster Creation

---

This folder contains some studies following the tutorial:

Terraform EKS Cluster Creation by **Anton Putra**

- **Youtube Playlist:** [Terraform EKS Cluster Creation](https://www.youtube.com/playlist?list=PLiMWaCMwGJXkeBzos8QuUxiYT6j8JYGE5)

- **GitHub lesson:** [Tutorial Terraform EKS Cluster](https://github.com/antonputra/tutorials/tree/main/lessons/138/terraform)

# My Structure

- s3-bucket.sh: Shell Script to create/destroy backend s3 bucket
  - Script requirement
    - **`BUCKET_NAME`**="`add-backend-s3-bucket-for-terraform-here`"
    - **`REGION`**="`add-aws-region-here`"
- terraform: Terraform source-code directory
- k82: Kubernetes manifest for testing.

```shell
.
├── k8s
│   └── demo-app.yaml
├── README.md
├── s3-bucket.sh
└── terraform
    ├── 00-backend.tf
    ├── 00-provider.tf
    ├── 01-vpc.tf
    ├── 02-int-gateway.tf
    ├── 03-subnets.tf
    ├── 04-nat-gateway.tf
    ├── 05-route-tables.tf
    ├── 07-eks-cluster.tf
    ├── 08-eks-nodes.tf
    ├── 09-nlb-security-group.tf
    └── variables.tf

3 directories, 13 files
```

---

## EKS connection

---

List Available EKS Clusters

```shell
aws eks list-clusters --region <region> --profile <aws_profile>
```

Connecting to EKS cluster

```shell
aws eks update-kubeconfig --name <cluster-name> --region <region> --profile <aws_profile>
```

Verifying Configuration:

```shell
kubectl config get-contexts
```

- <https://docs.aws.amazon.com/eks/latest/userguide/create-kubeconfig.html>

- <https://docs.aws.amazon.com/eks/latest/userguide/connecting-cluster.html>

> **TO DO:** Fix the internal load balancer TAG/Provision (it is not being created).

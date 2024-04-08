
# Terraform EKS Cluster Creation

---

This folder contains some studies following the tutorial:

Terraform EKS Cluster Creation by **Anton Putra**

- **Youtube Playlist:** [Terraform EKS Cluster Creation](https://www.youtube.com/playlist?list=PLiMWaCMwGJXkeBzos8QuUxiYT6j8JYGE5)

- **GitHub lesson:** [Tutorial Terraform EKS Cluster](https://github.com/antonputra/tutorials/tree/main/lessons/138/terraform)

---

## EKS connection

---

Connecting to EKS cluster

```shell
aws eks --region <region> update-kubeconfig --name <cluster-name> --profile <aws_profile>
```

Verifying Configuration:

```shell
kubectl config get-contexts
```

- <https://docs.aws.amazon.com/eks/latest/userguide/create-kubeconfig.html>

- <https://docs.aws.amazon.com/eks/latest/userguide/connecting-cluster.html>

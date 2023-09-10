# Flux ops layer

## Bootstrapping a Kubernetes Cluster

1. export CLUSTER_NAME="test-cluster";export CLUSTER_REGION="eu-west-2"
3. Generate a kubeconfig ```aws eks update-kubeconfig --name ${CLUSTER_NAME} --region ${CLUSTER_REGION} --profile=playground```
4. Ensure your kubectl context is pointing at the new cluster
5. Ensure you are in the root of this repo
6. Run the bootstrap command:
```
flux bootstrap github \
  --owner=tovern \
  --repository=aws-terraform-eks-example \
  --branch=main \
  --path=flux-ops/clusters/${CLUSTER_NAME}
```

7. The previous command will cause Flux to commit directly to the remote repo. Pull the latest main branch from remote.
8. Add the cluster ops kustomizations into the new cluster by running ```./new_cluster.sh -n ${CLUSTER_NAME} -r ${CLUSTER_REGION}```
9. Push the changes to remote and ensure that flux has applied them
10. You can now start hosting apps on the cluster by populating the apps directory

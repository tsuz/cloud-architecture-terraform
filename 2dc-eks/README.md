# 2 Data Center Architecture with AWS EKS Setup

## Architecture

## How to run

1. Review `variable.tf`

1. Run `terraform apply`

1. Run `kubectl get pods -n kube-system` to see if the pods are in `Pending` state

3b. If the CoreDNS are in pending state, validate the following:

3c. `kubectl describe pod/coredns-8496bbc677-8stf6  -n kube-system | grep compute-type` and see if you get `eks.amazonaws.com/compute-type: ec2`. This means CoreDNS won't run on Fargate instances so we need to manually patch this.

3d. If the CoreDNS pods are in a `Ready` state, then ignore this. If not, run:

```
kubectl patch deployment coredns \
-n kube-system \
--type json \
-p='[{"op": "remove", "path": "/spec/template/metadata/annotations/eks.amazonaws.com~1compute-type"}]'
```




## Limitations

- This does not handle multiple accounts. 
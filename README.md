# Hellow World API Runner

A simple API Runner web pp built with flask and can run on a Kubernetes cluster.

## Pre-requisites

- python at least 3.9
- kubectl
- docker desktop - make sure to tick the checkboxes for enabling Kubernetes
  ![Enabling k8s on Docker Desktop](/assets/docker-desktop.png)

## Procedure on local application testing via flask run

1. Clone Git repository to get the files

```
git clone git@github.com:zbrondial/helloworld-apirunner.git
cd helloworld-apirunner
```

2. Install python packages and run the flask webapp locally

```
pip3 install -r requirements.txt
pip3 install flask
pip3 install requests
flask run
```

## Procedure on local application testing via docker

1. After cloning the git repository, we can now proceed on building the docker image.

```
docker build -t zeepeebee30/hw-flask:latest .
```

2. Run the docker container to check the flask webapp

```
docker run -p 5000:5000 zeepeebee30/hw-flask:latest
```

3. Once verified that the webapp has no isses on the running container, we can now push the container image to docker hub. This container image will be used on local k8s testing and AWS EKS deployment.

```
docker push zeepeebee30/hw-flask:latest
```

## Procedure on local application testing via k8s of docker desktop

Once we have a clean image in docker hub, we can now try deploying the app on our local k8s

1. Switch first to docker desktop kubeconfig context.

```
kubectl config use-context docker-desktop
```

2. Deploy the flask webapp in k8s using the flaskapp-local.yml. This yaml file is intended for testing the flask container in a local k8s cluster.

```
kubectl create -f flaskapp-local.yml
```

3. Check the deployment and services created

```
kubectl get deployments
kubectl get svc
```

4. Expose the k8s service for local access testing. The flask webapp should be accessible now via http://localhost:5000

```
kubectl expose deployment flask-webapp --type=LoadBalancer --port 5000 --target-port 5000
```

## Procedure on deploying the flask webapp on AWS EKS

### Things to do before proceeding on the next steps

If you are building your container image in a Mac computer with Apple Silicon CPU , chances are these images will not run on AWS EKS. You will hit bellow errors,

- Deployment will not change to READY status
- Pod will be stuck on CrashLoopBackOff
- kubectl logs on pod will prompt 'standard_init_linux.go:228: exec user process caused: exec format error'

To fix this, build the container image with "--platform linux/amd64" parameter

```
docker build --platform linux/amd64 -t zeepeebee30/hw-flask:latest .
docker push zeepeebee30/hw-flask:latest
```

The AWS Resources for this project were provisioned using the terraform codes from this repo:

- https://github.com/zbrondial/helloworld-lambda-eks

Now we are ready to deploy our flask webapp in AWS EKS.

1. Update kubeconfig to add AWS EKS context

```
aws eks update-kubeconfig --region ap-southeast-1 --name hw-eks
```

2. Switch to AWS EKS kubeconfig context.

```
kubectl config use-context arn:aws:eks:ap-southeast-1:042468190057:cluster/hw-eks
```

3. Verify that you are now using the AWS EKS cluster

```
kubectl get nodes
NAME                                            STATUS   ROLES    AGE   VERSION
ip-10-0-4-197.ap-southeast-1.compute.internal   Ready    <none>   15h   v1.21.12-eks-5308cf7
ip-10-0-5-125.ap-southeast-1.compute.internal   Ready    <none>   15h   v1.21.12-eks-5308cf7
ip-10-0-6-10.ap-southeast-1.compute.internal    Ready    <none>   15h   v1.21.12-eks-5308cf7
```

4. Deploy the flask webapp using flaskapp-aws.yml. This yaml file is intended for AWS EKS deployment.

```
kubectl apply -f flaskapp-aws.yml
deployment.apps/flask-webapp created
service/flask-webapp-service created
```

5. Check the created deployment, pod and service

```
kubectl get deployment -n kube-system
NAME                         READY   UP-TO-DATE   AVAILABLE   AGE
aws-alb-ingress-controller   1/1     1            1           15h
coredns                      2/2     2            2           16h
flask-webapp                 1/1     1            1           3h4m
```

```
kubectl get pod -n kube-system
NAME                                          READY   STATUS    RESTARTS   AGE
aws-alb-ingress-controller-5dcd75d79f-8g7r2   1/1     Running   0          15h
aws-node-gb592                                1/1     Running   0          15h
aws-node-mh6jp                                1/1     Running   0          15h
aws-node-nhp46                                1/1     Running   0          15h
coredns-55b9c7d86b-mc9wz                      1/1     Running   0          16h
coredns-55b9c7d86b-nw8kl                      1/1     Running   0          16h
flask-webapp-649dfbf456-dpdb6                 1/1     Running   0          3h4m
```

```
kubectl get svc -n kube-system
NAME                   TYPE           CLUSTER-IP      EXTERNAL-IP                                                                   PORT(S)                      AGE
flask-webapp-service   LoadBalancer   172.20.155.57   a2d6c943b87554b48a2c7b1158d4d556-103598869.ap-southeast-1.elb.amazonaws.com   80:32020/TCP,443:32220/TCP   7h19m
kube-dns               ClusterIP      172.20.0.10     <none>                                                                        53/UDP,53/TCP                16h
```

6. Get the ELB Ingress URL

```
kubectl describe service flask-webapp-service -n kube-system | grep Ingress
LoadBalancer Ingress:     a2d6c943b87554b48a2c7b1158d4d556-103598869.ap-southeast-1.elb.amazonaws.com
```

# Kubernetes-Clique (Ethereum PoA)
쿠버네티스 환경에서 Clique(Ethereum PoA)를 배포/접속하고 관리하는 기본적인 방법을 살펴본다.

&nbsp;
## Part 1: Kubernetes 환경 설치하기 
### 1.1. Install the prerequisites
EKS Getting Started Page를 참조하여 VPC -> EKS Cluster -> EKS Nodes 순서대로 Cloudformation 구동시키고,
그 다음은  로컬 환경 설정과 Node를 클러스터에 붙이는 작업을 먼저 완료해야 합니다.
   
- 0단계: EKS Cluster용 VPC 생성 (선행요건)
- 1단계: EKS Cluster 구성
- 2단계: EKS용 kubectl 구성
- 3단계: Ethereum 네트워크 구성

☛ AWS EKS 시작하기 : https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/getting-started.html

## Part 2: Clique 애플리케이션 배포하기
### 2.1. Secret 생성                      
````
kubectl create secret generic bootkey1 --from-file=00-boot.key
kubectl create secret generic ethstats --from-file=00-ethstats
kubectl create secret generic genesis --from-file=00-genesis.json
kubectl create secret generic passfile --from-file=00-passfile

(keystore Secret 생성)
kubectl create secret generic signer1 --from-file=keystore/UTC--2018-10-12T06-34-18.611378736Z--62ee92100528dd25eaf47530ad224e5ad113d1eb
kubectl create secret generic signer2 --from-file=keystore/UTC--2018-10-12T06-34-50.784665133Z--16d3d8ccd2f4fc6234fdf9ba46b862d4d684ef4c
kubectl create secret generic signer3 --from-file=keystore/UTC--2018-10-12T06-34-56.753428101Z--69c573c467e679d9f795296e50f289e9ba03109e
````

### 2.2. Deployment 컨테이너 실행
````
kubectl apply -f 10-bootnode.yaml
kubectl apply -f 20-signer1.yaml
kubectl apply -f 20-signer2.yaml
kubectl apply -f 20-signer3.yaml
kubectl apply -f 30-node.yaml
kubectl apply -f 40-ethstats.yaml
````

### 2.3. Service 실행 
````
kubectl apply -f 50-ethstats-service.yaml
kubectl apply -f 50-node-service.yaml
````

### 2.4. 기타

* 컨테이너가 잘 돌고있는지 보려면:
````
kubectl get pods 
````
* 서비스가 잘 만들어졌는지 보려면:
````
 kubectl get svc
````
* 문제를 확인하려면:
  - kubectl get pods를 실행해서 pod 이름을 이용하여 log를 확인할 수 있다.
````                                            
kubectl get pods
kubectl logs [pod-name]
Kubectl describe pod
````
* Geth Console에 접속 방법:
  - kubectl get pods를 실행해서 pod 이름을 이용하여 ssh 혹은 geth로 접속할 수 있다.
````
kubectl get pods
kubectl exec -it [pod-name] -- /bin/sh     
kubectl exec -it [pod-name] -- geth attach /ethereum/geth.ipc 
````
* 마이너 및 노드 스케일링 방법:
````
kubectl scale deployment node --replicas=3
````       
* 리소스 삭제 방법 (만들어진 순서대로 지우면 됩니다):
````
kubectl delete -f 50-node-service.yaml
kubectl delete -f 50-ethstats-service.yaml
kubectl delete -f 40-ethstats.yaml
kubectl delete -f 30-node.yaml
kubectl delete -f 20-signer1.yaml
kubectl delete -f 20-signer2.yaml
kubectl delete -f 20-signer3.yaml
kubectl delete -f 10-bootnode.yaml
````


## Part 3: Clique 애플리케이션 확인하기
### 3.1. Ethstats Service 확인   

* 서비스가 잘 만들어졌는지 보려면 (ELB 콘솔에서도 확인 필요):
  - 브라우저 ethstats url:  http://< Ethstats Service ELB-endpoint >:3000
  - 브라우저 Geth RPC url:  http://< Node Service ELB-endpoint >:8545
````     
 ☛ Ethstats Example : http://a152b586ed49b11e88999068d49ab8ff-1678141883.us-west-2.elb.amazonaws.com:3000
 ☛ Geth RPC Example : http://a06710f6ed49c11e88999068d49ab8ff-754523919.us-west-2.elb.amazonaws.com:8545
````
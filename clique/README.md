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
kubectl apply -f 00-bootkey-secret.yml		
kubectl apply -f 00-ethstats-secret.yml		
kubectl apply -f 00-genesis-configmap.yml	
kubectl apply -f 00-node1-keystore-secret.yml	
kubectl apply -f 00-passfile-secret.yml		
kubectl apply -f 00-signer-secret.yml
kubectl apply -f 00-signer1-keystore-secret.yml	
kubectl apply -f 00-signer2-keystore-secret.yml
kubectl apply -f 00-signer3-keystore-secret.yml
````

### 2.2. Deployment 컨테이너 실행
````
kubectl apply -f 10-bootnode.yml
kubectl apply -f 20-signer1.yml
kubectl apply -f 20-signer2.yml
kubectl apply -f 20-signer3.yml
kubectl apply -f 30-node.yml
kubectl apply -f 40-ethstats.yml
````

### 2.3. Service 실행 
````
kubectl apply -f 50-ethstats-service.yml
````

### 2.4. 기타

* 컨테이너가 잘 돌고있는지 보려면:
````
kubectl get pods 
````
* 서비스가 잘 만들어졌는지 보려면:
````
 kubectl get svc
 kubectl get all
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
kubectl delete -f 50-ethstats-service.yml

kubectl delete -f 10-bootnode.yml
kubectl delete -f 20-signer1.yml
kubectl delete -f 20-signer2.yml
kubectl delete -f 20-signer3.yml
kubectl delete -f 30-node.yml
kubectl delete -f 40-ethstats.yml

혹은 (한번에 지우기)
kubectl delete all --all --include-uninitialized
````


## Part 3: Clique 애플리케이션 확인하기
### 3.1. Ethstats Service 확인   

* 서비스가 잘 만들어졌는지 보려면 
````
kubectl describe svc ethstats 
````
> (결과에서 LoadBalancer Ingress 정보가 < ELB-endpoint > 입니다.)

  - 브라우저 ethstats url:  http://< Ethstats Service ELB-endpoint > 
  - 브라우저 Geth RPC url:  http://< Node Service ELB-endpoint >:8545

 ☛ Ethstats 샘플보기:  [ethstats-service](http://a9a8dc62fe09d11e8b48f0afe50d04d1-1431212487.us-west-2.elb.amazonaws.com)
 
 ☛ Geth RPC 연결 방법
 
    - 리모트 연결 방법 : kubectl describe svc node
      RPC URL : http://<LoadBalancer Ingress>:8545 
    - 터널링 연결 방법 : kubectl port-forward node-74c65774d8-g92 8545:8545
      RPC URL : http://localhost:8545              
 

<H2>Kubernetes Debug </H2>

repo:
```
https://github.com/aylei/kubectl-debug
```

Установка cli kubectl-debug:
```
brew install aylei/tap/kubectl-debug
```

Вкатываем Debug Agent:
 ```
kubectl apply -f https://raw.githubusercontent.com/aylei/kubectl-debug/master/scripts/agent_daemonset.yml
или
./debug-agent.yml
 ```

Запускаем отладку в agentless режиме:
```
kubectl debug <POD_NAME> -n <Namespace> --port-forward
```

<H2>Kube-iptables-tailer </H2>


ставим Netperf-Operator:

```
git clone https://github.com/piontec/netperf-operator

kubectl apply -f ./deploy/crd.yaml 
kubectl apply -f ./deploy/rbac.yaml
kubectl apply -f ./deploy/operator.yaml
```

Запускаем Netperf-App:

```
kubectl apply -f ./deploy/cr.yaml
```

Проверим, что тестирование TCP-соединения между netperf-server и netperf-client прошли удачно: 
```
kubectl describe netperf.app.example.com/example 
```

Включаем сетевую политику Calico:
```
Для GKE нужно включить NetworkPolicy, тогда автоматически будет установлен Calico.
```

Настраиваем сетевое ограничение для Netperf-client:
```
apiVersion: crd.projectcalico.org/v1
kind: NetworkPolicy
metadata:
 name: netperf-calico-policy
 labels:
spec:
 order: 10
 selector: app == "netperf-operator" # Наше приложение!
 ingress:
   - action: Allow
     source:
       selector: netperf-role == "netperf-client"
   - action: Log
   - action: Deny
 egress:
   - action: Allow
     destination:
       selector: netperf-role == "netperf-client"
   - action: Log
   - action: Deny
```

Тестируем ограничение сетевой политики:
```
kubectl delete Netperf example
kubectl apply -f ./deploy/cr.yaml
kubectl describe pod --selector=app=netperf-operator
```

Подключимся к Ноде по SSH и проверим лог IPTABLES:
```
sudo iptables --list -nv | grep DROP
sudo iptables --list -nv | grep LOG

   0     0 LOG        all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:XWC9Bycp2Xf7yVk1 */ LOG flags 0 level 5 prefix "calico-packet: "
 245 14700 LOG        all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:B30DykF1ntLW86eD */ LOG flags 0 level 5 prefix "calico-packet: 
```


Ставим Kube-Iptables-Tailer:
```
kubectl apply -f ./kit/rbac.yml
kubectl apply -f ./kit/kube-iptables-tailer.yml
```

Тестируем наличие логов в iptables:
```
kubectl delete Netperf example 
kubectl apply -f ./deploy/cr.yaml

kubectl describe netperf.app.example.com/example
kubectl describe pod --selector=app=netperf-operator

```

```
Events:
  Type     Reason      Age   From                                                   Message
  ----     ------      ----  ----                                                   -------
  Normal   Scheduled   70s   default-scheduler                                      Successfully assigned default/netperf-server-42010a8001c8 to gke-green-cluster-default-pool-d7a0e5e3-xfk9
  Normal   Pulled      69s   kubelet, gke-green-cluster-default-pool-d7a0e5e3-xfk9  Container image "tailoredcloud/netperf:v2.7" already present on machine
  Normal   Created     69s   kubelet, gke-green-cluster-default-pool-d7a0e5e3-xfk9  Created container netperf-server-42010a8001c8
  Normal   Started     69s   kubelet, gke-green-cluster-default-pool-d7a0e5e3-xfk9  Started container netperf-server-42010a8001c8
  Warning  PacketDrop  67s   kube-iptables-tailer                                   Packet dropped when receiving traffic from 10.4.1.19
```


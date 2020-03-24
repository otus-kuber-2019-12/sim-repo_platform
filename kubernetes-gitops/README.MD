<H2>GitOps: FIF+GitLab для микро-сервисного приложения "HipsterShop" </H2>

(FIF - FluxCD, Istio, Flagger)

<H3>Dir: </H3>

   ./autodeploy - авторазвертывание FIF <br>
   ./deploy - version control repository для FLUXCD   <br>
   ./flagger - Canary-ресурсы, Alerts для Flagger<br>
   ./flux - values для установки FluxCD<br>
   ./src - кодовая база HipsterShop<br>



<H3>Настройка Проекта: </H3>

 Собрать docker-образы всех микросервисов с тегом v0.0.1 и запушить в Docker Hub <br>


<H3>Настройка Flux </H3>

Деплоим  CRD:

 ```
kubectl apply -f https://raw.githubusercontent.com/fluxcd/helm-operator/master/deploy/crds.yaml
 ```

Установим Flux:

 ```
helm repo add fluxcd https://charts.fluxcd.io
kubectl create namespace flux
helm upgrade --install flux fluxcd/flux -f ./flux/values.yml --namespace flux
helm upgrade --install helm-operator fluxcd/helm-operator -f ./flux/operator/helm-operator.values.yaml --namespace flux
 ```

Установим FluxCtl:

```
brew install fluxctl
```
Теперь законнектим fluxctl с flux daemon, который крутится на ns - flux:

```
fluxctl --k8s-fwd-ns=flux list-workloads
```

Настроим доступа flux-а к GitLab репозиторию:

```
 fluxctl identity --k8s-fwd-ns flux

 GitLab->Account->Settings->SSH Keys
```

Проверим, что интеграция успешна прошла: <br>

> kubectl get pods -n flux <br>
> kubectl logs flux-59bdc5d845-mt6kp -n flux --tail 1 <br>

output:
```
ts=2020-03-17T15:04:31.372157386Z caller=images.go:17 
component=sync-loop msg="polling for new images for automated workloads"
 ```

<H3>Установка Istio:</H3>

```
curl -L https://istio.io/downloadIstio | sh -
cd ./istio-1.5.0
export PATH=$PWD/bin:$PATH
```

Ставим Istio operator:

```
istioctl operator init
```

Ставим configuration profile:

```
kubectl apply -f - <<EOF
apiVersion: install.istio.io/v1alpha1
kind: IstioOperator
metadata:
  namespace: istio-system
  name: example-istiocontrolplane
spec:
  profile: default
EOF

```



Ставим Envoy:

```
apiVersion: v1
kind: Namespace
metadata:
 labels:
   istio-injection: enabled
 name: production
```

Проверим статус Sidecar в кластере:

> kubectl get ns production --show-labels

```
NAME         STATUS   AGE   LABELS
production   Active   81m   fluxcd.io/sync-gc-mark=sha256.FB1D6mLzJzRR_T1VrTcTV5jVhcaLSO93IO4KN_ohbUI,istio-injection=enabled

```

“Сбросим” все поды, чтобы они пересоздались, но уже с sidecar Envoy:

```
kubectl delete pods --all -n production
```


Настроим Frontend для Istio (Gateway+VirtualService):

```
./deploy/templates/frontend
```

Проверим состояние frontend HelmRelease:

```
kubectl get helmreleases frontend -n production
kubectl get gateway -n production
kubectl get svc istio-ingressgateway -n istio-system
kubectl get VirtualService -n production

```

<H3>Установка Flagger:/H3>

```
helm repo add flagger https://flagger.app

kubectl apply -f https://raw.githubusercontent.com/weaveworks/flagger/master/artifacts/flagger/crd.yaml

helm upgrade -i flagger flagger/flagger \
--namespace=istio-system \
--set crd.create=false \
--set meshProvider=istio \
--set metricsServer=http://prometheus:9090
```

<H3>Frontend для Flagger:/H3>

```
./flagger/frontend
```

<H3>Flagger: Alert to Slack/H3>

```
./flagger/alert
```
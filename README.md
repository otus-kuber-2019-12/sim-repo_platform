<H2>Kubernetes Controllers</H2>

1. с использованием манифеста frontend-replicaset.yaml сделаны проверки:\
1.1. развертывание 1-го Пода\
1.2. скалирование реплик с 1 до 3 императивно\
1.3. автоматическое восстановление 3х реплик после ручного удаления (kubectl delete pods ..)\
1.4. повторное примененеие манифеста с восстановлением состояния (п.1.1) согласно манифесту\
1.5. правка в манифесте - изменение реплик 1->3 и повторное применение\
1.6. ReplicaSet не может отслеживать обновленные Поды: обновление приложения до v0.0.2 с соотв-ей правкой в манифесте не привело к обновлению запущенных Подов

2. с использованием манифеста paymentservice-deployment.yaml сделаны проверки:\
2.1. применением манифеста создает RS и Поды\
2.2. обновление приложения до v0.0.2 с правкой в манифесте корректно обновляет все запущенные Поды, а также создает новый RS для управления ими (старый остается висеть для управления старыми Подами v0.0.1, которых уже нет)\
2.3. можно откатываться до предыдущей версии через kubectl rollout undo..

3. Deployment: maxSurge, maxUnavailable\
3.1. создание аналога blue-green - paymentservice-deployment-bg.yaml\
3.2. reverse rolling update - paymentservice-deployment-reverse.yaml

4. Probes на примере манифеста frontend-deployment.yaml:\
4.1. проверка readinessProbe для заведемо корректно работающих приложений: Running -> Ready \
4.2. readinessProbe для баговых приложений не даст перевести созданный Под в состояние Ready, он так останется в Running + тут же Deployment перестанет продолжать обновление


5. DaemonSet на примере node-exporter-daemonset.yaml:\
5.1. добавлена возможность развернуть Под на мастер- и воркер-нодах




<H2>Kubernetes-Security</H2>

1. 01-task:\
1.1. *-user.yaml - добавление ServiceAccount:\
1.2. *-binding.yaml - биндинг сервисных аккаунтов к существующим ролям\
1.3. *-role.yaml - добавление новой роли-пустышки\

2. 02-task:\
2.1. 01-namespace.yaml - создание namespace prometheus :\
2.2. 02-user.yaml - добавление юзера к этому namespace\
2.3. 03-role.yaml - создание роли на чтение всех POD-ов в кластере\
2.4. 04-binding.yaml - привязываем эту роль для всех service accounts, заведенных в namespace prometheus 

3. 03-task:\
3.1. 01-namespace.yaml - namespace dev
3.2. 02-user.yaml - SA jane
3.3. 03-binding.yaml - назначем jane роль admin для dev
3.4. 04-user.yaml создаем SA ken
3.5. 05-binding.yaml - даем права SA ken только на чтение в dev


<H2>Kubernetes Networks</H2>

1. Хеш-таблицы на основе IPVS:<br>
1.1. настройка: $ kubectl --namespace kube-systemedit configmap/kube-proxy <br>
1.2. рестарт kube-proxy: $ kubectl --namespace kube-system delete pod --selector='k8s-app=kube-proxy'<br>
1.3. создание bash-скрипта для cleanup iptables<br>
1.4. добавление ipvsadm в minikube<br>

2. Установка и настройка MetalLB:<br>
2.1. инсталяшка: kubectl apply -fhttps://raw.githubusercontent.com/google/metallb/v0.8.0/manifests/metallb.yaml <br>
2.2. metallb-config.yaml - настройка MetalLB <br>
2.3. проверка логов: kubectl --namespace metallb-system logs pod/controller-XXXXXXXX-XXXXXX <br>
2.4. проверка пинга ip балансировщика в хостовой ОС<br>
2.5. проверка доступа к приложению через http-запрос <br>

3. DNS через MetalLB : <br>
3.1. dns-service-tcp.yaml / dns-service-udp .yaml  - настройка для TCP/UDP <br>

4. Создание IngressСоздание Ingress : <br>
4.1. установка kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/mandatory.yaml <br>
4.2. nginx-lb.yaml - создание объекта LoadBalancer <br>
4.3. web-svc-headless.yaml - создание Headless сервиса <br>
4.4. web-ingress.yaml - создание Ingress-прокси <br>

5. Ingress для Dashboard: <br>
5.1. dashboard-ingress.yaml - настройка https-доступа к дашборду через Ingress-прокси <br>

6.  Canary для Ingress: <br>
6.1. preprod.yaml - конфигурация для развертывания препрод среды <br>
6.2. product.yaml - конфа для продукта <br>



<H2>Kubernetes Volumes</H2>

Пример монтирования объекта Secret через переменные среды <br>
1. minio-secret.yaml - secret-объекты <br>
2. minio-statefullset.yaml - statefullset приложение minio с сылкой на secret <br>
3. minio-headless.yaml -headless сервис для доступа к приложению <br>


<H2>Kubernetes Templating</H2>

1. деплой готовых helm-charts:\
1.1. подготовка кластера kubernetes на gcp\
1.2. установка google sdk для доступа к kubernetes из local\
1.3. монтирование chart-ов nginx-ingress, harbor, chartmuseum, cert-manager в локальный репо\
1.4. деплой чартов:\
требуется предварительно ручного создания namespaces;\
установка командой: helm upgrade --install;\
проверка корректной установки через флаг: --dry-run --debug;\
1.4.1.  nginx-ingress -  ставится по-дефолту\
1.4.2.  cert-manager -  настройка через ACME-issuer (Let's encrypted):\
(важно в spec.acme указать url для прод: https://acme-v02.api.letsencrypt.org/directory )\
1.4.3. chartmuseum \
(важно в values: ingress.annotations указать:\
cert-manager.io/cluster-issuer: letsencrypt-production\
cert-manager.io/acme-challenge-type: http01 \
иначе сертификат не будет выписан)\
1.4.4. harbor - по аналогии с chartmuseum\
2. свой helm-chart на примере hipster-shop:  выделить frontend и параметризовать число реплик,  версию образа, внешний порт (targetPort)\
2.1. удаляем работающий frontend: helm delete frontend -n hipster-shop\
2.2. берем исходники манифестов для frontend из all-hipster-shop.yaml + пишем отдельный nginx-ingress\
2.3. шаблонизируем frontend через values.yaml\
2.4. добавляем зависимость в hipster-shop/Chart.yaml\
3. helm-secrets:\
3.1. установка плагина\
3.2. генерация pgp-ключа\
3.3. создание секрета frontend/secrets.yaml  и его шифрование с помощью ключа\
3.4. протягивание секрета в helm \
4. jsonnet-kubecfg: шаблонизация hipster-shop/paymentservice + shippingservice\
4.1. установка плагина\
4.2. создание собственного шаблона: kubecfg/services.jsonnet\
4.3. проверка через команду: kubecfg show services.jsonnet\
4.4. деплой: kubecfg update services.jsonnet --namespace hipster-shop\
5. Kustomize: переводим hipster-shop/productcatalogservice на kustomize:\
5.1. установка плагина\
5.2. создаем ресурсы для базы kustomize/base на основе деплоймента и сервиса\
5.3. шаблонизируем по принципу окружений dev/prod: kustomize/overlays\


<H2>Kubernetes Operators</H2>

1. Для проекта создана папка kubernetes-operators и 2е поддиректории build и deploy <br>
2. . Простой пример создания cr: <br> 
2.1. в папке ./deploy заведены 2а манифеста CustomResourceDefinition + CustomResource: crd.yml, cr.yml <br>
2.2. crd  определяет с каким типом CR работает; проводит валидацию полей манифеста cr <br>
2.3. после применения проверка через: <br>
- kubectl get crd <br>
- kubectl get mysqls.otus.homework <br>
3. Разработка оператора через kopf-framework: <br>
3.1. для начала необходимо установить все python-библиотеки: jinja, "pip install kopf",  "pip install kubernetes" <br>
3.2. в папке ./build заведена подпапка templates для хранения шаблонов манифество, куда будет производится инъекция значений\
(Все шаблоны-манифестов с расширениями j2, чтобы их могла использовать библиотека Jinja.) <br>
3.3. создан python-скрипт "mysql-operator.py", в котором реализована логика создания kubernetes-оператора <br>
3.2.1. jinja - нужна для injection-pattern <br>
3.2.2. kopf - создает зависимости создаваемых CustomResources к управляемому.  Таким образом реализуется каскадное удаление через удаление CustomResource. <br>
3.2.3. kubernetes-client-sdk - библиотека взаимодействия с kubernetes-api из python <br>
4. Важные моменты: <br>
4.1. перед созданием оператора (kopf run mysql-operator.py) обязательно предварительно выкатить в кластер CRD, CR<br>
4.2. иногда возникает следующая проблема: при удалении CRD консоль сообщает что объект deleted, но не передает управление  и переходит в режим standby<br>
лечение: переустановить python: <br>
brew uninstall --ignore-dependencies python3 <br>
brew install python3 <br>
5. Вывод успешно выполненных джобов: <br>
(base) iMac-Igor:sim-repo_platform igorivanov$ kubectl get jobs <br>
NAME                         COMPLETIONS   DURATION   AGE <br>
backup-mysql-instance-job    1/1           1s         34m <br>
restore-mysql-instance-job   1/1           6m9s       36m <br>
6. Вывод успешно созданных записей в MySQL: <br>
(base) iMac-Igor:sim-repo_platform igorivanov$ kubectl exec -it $MYSQLPOD -- mysql -potuspassword -e "select * from test;" otus-database <br>
mysql: [Warning] Using a password on the command line interface can be insecure. <br>
+----+-------------+ <br>
| id | name        | <br>
+----+-------------+ <br>
|  1 | some data   | <br>
|  2 | some data-2 | <br>
+----+-------------+ <br>




<H2>Kubernetes Monitoring</H2>
1. Развертывание Prometheus Operator производится через helm2 <br>
2. Для установки helm в папке ./helm2 находится RBAC-настройка <br>
3. Папка nginx содержит Dockerfile <br>
4. Установка PO делалась через команду: <br>
helm install --name my-release stable/prometheus-operator <br>
5. Все проверки работоспособности компонентов PO через проброс портов: <br>
5.1. prometheus dashboard: kubectl port-forward prometheus-my-release-prometheus-oper-prometheus-0 9090 <br>
5.2. alert: kubectl port-forward alertmanager-my-release-prometheus-oper-alertmanager-0 9093 <br>
5.3. grafana: kubectl port-forward my-release-grafana-<..>  3000 <br>
6. login/psw для Grafana: <br>
6.1. kubectl get secret <br>
6.2. kubectl get secret my-release-grafana -o yaml <br>
7. Заметки: <br>
7.1. Посмотреть список обслуживаемых метрик: <br>
$ kubectl get servicemonitors.monitoring.coreos.com <br>
7.2. Прометеус находит Сервис-Мониторы по меткам. Перед деплоем Сервис-Монитора нужно убедиться, что он содержит ту же метку, что и в конфиге Прометеуса: <br>
$ kubectl get prometheuses.monitoring.coreos.com -oyaml <br>
.. <br>
podMonitorSelector: <br>
      matchLabels: <br>
        release: monitoring <br>
.. <br>

Тогда при создании манифеста нужно добавить: <br>

apiVersion: monitoring.coreos.com/v1 <br>
kind: ServiceMonitor <br>
metadata: <br>
  name: traefik <br>
  labels: <br>
    release: monitoring <br>
    app: traefik-metrics <br>


<H2>Kubernetes Logging</H2>

1. Создание 2х пулов Нод (pool-nodes): default-pool(1а нода) и infra(3и ноды)
2. Установка ограничения на авторазмещения объектов на infra - Taint
3. Установка HipsterShop c frontend на порт, отличный от 80
4. Настройка Helm 2 для helm.elastic
5. Установка EFK <br>
         5.1.  helm upgrade --install elasticsearch elastic/elasticsearch --namespace observability 
         5.2.  helm upgrade --install kibana elastic/kibana --namespace observability 
         5.3.  helm upgrade --install fluent-bit stable/fluent-bit --namespace observability
(ELK разметился на нодах из default-pool) <br>

6. Перебрасываем EFK на infra: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration <br>
7. Установка nginx-ingress: https://github.com/helm/charts/tree/master/stable/nginx-ingress <br>
8. Также перебрасываем nginx-ingress через nginx-ingress.values.yaml <br>
9. Вывод доступа к Kibana: kibana.values.yaml <br>
10. Настройка fluent bit для создания индекса в Kibana через fluent-bit.values.yaml <br>
11. Установка Prometheus Operator: https://github.com/helm/charts/tree/master/stable/prometheus-operator<br>
12. Установка ES экспортера <br>
helm upgrade --install elasticsearch-exporter stable/elasticsearch-exporter --set es.uri=http://elasticsearch-master:9200 --set serviceMonitor.enabled=true -- namespace=observability <br>
13. Вывод доступа к Grafana: grafana.values.yaml <br>
14. Вывод доступа к Alertmanager: alertmanager.values.yaml <br>
15. Вывод доступа к Alertmanager: alertmanager.values.yaml <br>
16. Настройка Kibana дашборда: export.ndjson <br>
17. Установка Loki + Promtail <br>
helm upgrade --install loki loki/loki —namespace=observability <br>
helm upgrade --install promtail loki/promtail --set «loki.serviceName=loki» --namespace=observability <br>
18. Модифицировать Prometheus Operator таким образом, чтобы datasource Loki создавался сразу после установки оператора: prometheus-operator.values.yaml <br> 
19. Настройка Grafana дашборда: ngnix-ingress.json <br>

<H2>Kubernetes Vault</H2>
1. Использовал Helm2: RBAC - tiller-account-rbac.yaml <br>
2. Cклонируем репозиторий consul <br>
           git clone https://github.com/hashicorp/consul-helm.git <br>
           helm install --name=consul consul-helm <br>
3. Также репо Vault: <br>
           git clone https://github.com/hashicorp/vault-helm.git <br>
4. Отредактируем параметры установки в values.yaml<br>
    Подключим HA+UI, выключим Standalone<br>
    tandalone:  <br>
        enabled: false  <br>
        ....  <br>
    ha:   <br>
        enabled: true  <br>
        ...  <br>
    ui:  <br>
        enabled: true  <br>
        serviceType: "ClusterIP" <br>
5. Установим Vault: <br>
    helm install --name=vault . <br>

Команда helm status vault покажет все объекты, установленные через helm: <br>
helm status vault<br>

Посмотрим логи Vault-подов: <br>
Будет выведено нечто подобное: <br>
core: seal configuration missing, not initialized <br>


6.Vault требует инициализации, связанной с установкой печати: <br>

kubectl exec -it vault-0 -- vault operator init --key-shares=1 --key-threshold=1 <br>

Результат:  <br>

Unseal Key 1: Scl5kDhBCyf58CRC7PjmL+7pzgkYPuYiWo67yrdxDdw= <br>

Initial Root Token: s.3virBMHFxbd4z02OKMbW1bPq <br>

           
7. Проверим: <br>

kubectl exec -it vault-0 -- vault status <br>

.. <br>
Sealed             true <br>
.. <br>

8. Теперь, чтобы vault мог получить доступ к decryption key для декодерования зашифрованных данных в consul нужно распечатать каждый Vault под: <br>

kubectl exec -it vault-0 -- vault operator unseal <br>

Будет выведен stdin promt на ввод печати, выданный на шаге 6 <br>

После ввода unsealed-key консоле выводится сообщение: <br>
Sealed   false <br>

Ту же операцию нужно проделать с каждым Vault-подом: <br>
kubectl exec -it vault-1 -- vault operator unseal <br>
kubectl exec -it vault-2 -- vault operator unseal <br>


9.Залогинимся: <br>

kubectl exec -it vault-0 -- vault login <br>


Success! You are now authenticated. The token information displayed below <br>
is already stored in the token helper. You do NOT need to run "vault login" <br>
again. Future Vault requests will automatically use this token. <br>

Key                  Value <br>
---                  ----- <br>
token                s.3virBMHFxbd4z02OKMbW1bPq <br>
token_accessor       enaw11WLLiaagGLj2lY9zLgQ <br>
token_duration       ∞ <br>
token_renewable      false <br>
token_policies       ["root"] <br>
identity_policies    [] <br>
policies             [«root"] <br>



10. Добавим секреты: <br>

kubectl exec -it vault-0 -- vault secrets enable --path=otus kv <br>
kubectl exec -it vault-0 -- vault kv put otus/otus-ro/config username='otus' password='asajkjkahs' <br>
kubectl exec -it vault-0 -- vault kv put otus/otus-rw/config username='otus' password='asajkjkahs'  <br>


11. Посмотрим как записался секрет: <br>
kubectl exec -it vault-0 -- vault read otus/otus-ro/config <br>
kubectl exec -it vault-0 -- vault kv get otus/otus-rw/config <br>


Key                 Value <br>
---                 ----- <br>
refresh_interval    768h <br>
password            asajkjkahs <br>
username            otus <br>


12. Включим авторизацию через k8s: <br>

kubectl exec -it vault-0 -- vault auth enable kubernetes <br>

kubectl exec -it vault-0 -- vault auth list <br>

Path           Type          Accessor                    Description <br>
----           ----          --------                    ----------- <br>
kubernetes/    kubernetes    auth_kubernetes_e03cf9ad    n/a <br>
token/         token         auth_token_06d49d56         token based credentials <br>


13. Создадим RBAC: <br>

kubectl create serviceaccount vault-auth <br>

vault-auth-service-account.yml <br>


apiVersion: rbac.authorization.k8s.io/v1beta1  <br>
kind: ClusterRoleBinding  <br>
metadata:  <br>
    name: role-tokenreview-binding  <br>
    namespace: default  <br>
roleRef:  <br>
    apiGroup: rbac.authorization.k8s.io kind: ClusterRole  <br>
    name: system:auth-delegator  <br>
subjects:  <br>
    - kind: ServiceAccount  <br>
    name: vault-auth  <br>
    namespace: default  <br>
    
14. Подготовим переменные для записи в Конфиг Кубер Авторизации: <br>

export VAULT_SA_NAME=$(kubectl get sa vault-auth -o jsonpath="{.secrets[*]['name']}")  <br>
echo $VAULT_SA_NAME <br>
vault-auth-token-m5v4c <br>

export SA_JWT_TOKEN=$(kubectl get secret $VAULT_SA_NAME -o jsonpath="{.data.token}" | base64 --decode; echo) <br>
echo $SA_JWT_TOKEN<br>

eyJhbGciOiJSUzI1NiIsImtpZCI6Im9IdGdyOFoxSmFSdDdKWnNtQ3d6YnVjX0FPRS1KaG9yNi1COTB5SUc5NEkifQ.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJkZWZhdWx0Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZWNyZXQubmFtZSI6InZhdWx0LWF1dGgtdG9rZW4tbTV2NGMiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC5uYW1lIjoidmF1bHQtYXV0aCIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50LnVpZCI6ImZlYzJjYWFjLTE4MjMtNGU2Zi05ZjkzLTM4N2ZlNGIxMzhjZiIsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDpkZWZhdWx0OnZhdWx0LWF1dGgifQ.sXiJriVOaJE0DQPgU2Si4V2a2LEt98v_9xZi59XO6AvvOWfqrh7mU8y6Z4Zd0y3SXwnPyyQCrmpbKXCFhctp8xhls2rrZLJyhMpHvNXG4Zjt4yGASsTkGohc2gBsRnOypJOGIOYC4kFtaicu-drDtEMmBklL4Po6i4mZFKPFmB6C8o82fc80miLyN46cx1yQr0dQr6DtO0sveKvB42_Vl0btTRCRpkCQVwc8K386WXjuD7NAT4yTNwb2IGQNmY1RJd7Yqy4MDzm0Dpvv-w1jCVorMkezgiKaQmBGuk8-TOoq63xsr73-elE5kS_vRY47dMlszKp5SlwaeNzTOcmVdA<br>


export SA_CA_CRT=$(kubectl get secret $VAULT_SA_NAME -o jsonpath="{.data['ca\.crt']}" | base64 --decode; echo) <br>

echo $SA_CA_CRT <br>
-----BEGIN CERTIFICATE----- MIIDCzCCAfOgAwIBAgIQZDI5+F+Of+BcbPfkdsUYDjANBgkqhkiG9w0BAQsFADAv MS0wKwYDVQQDEyQ5NDBhMWFiNi0xN2E3LTRkYTgtYTk4NC02MjJiODg1MTAzMzAw HhcNMjAwMTI2MTYwMzI0WhcNMjUwMTI0MTcwMzI0WjAvMS0wKwYDVQQDEyQ5NDBh MWFiNi0xN2E3LTRkYTgtYTk4NC02MjJiODg1MTAzMzAwggEiMA0GCSqGSIb3DQEB AQUAA4IBDwAwggEKAoIBAQClyFpd7wgVRYs/bLaQFa24jGCma23cxxjz0HkYN+ed e9+AnC3y3BxbDWkB+25UqbmGRt6BSlfxYiVyZkW1er4LhvXbSb67kOoJpzi7+TVl ccLNx3bohEfPxs7wY5WaqE6CL2eSzO9P8Tus6YGN1iT99ESUnpQZ+JppR9luYrRP WIb+dKYccW9JEmJ/DvbxSQDHiM5YPZTi5lEhC7zjvsze32VZFALCu6uXBpROkYjG jYpHvPFs0/xGVKwXI86yvZBOKg1ZxjvSe2R0S8slSWxGMEDm5CVz/MI6vo59jEh5 ksvA5RFhvq+CHbiYbBzSkS6wyb4Pop3MQeqyP118ley1AgMBAAGjIzAhMA4GA1Ud DwEB/wQEAwICBDAPBgNVHRMBAf8EBTADAQH/MA0GCSqGSIb3DQEBCwUAA4IBAQBf l+CSXXwyVK8krbrAv3IcX1z6iDS93atzRYk6AMrkQ0hsZNxalNWJCjnArIeuoUJc 2ASGfYdhQB6/zXrugLlB86F/Dj8rFpB2SebrE+WOkxOV5zorNN41lJpnf33NJNT9 SCVitbYIcamrSQHIbrW1HqUXxp8xDzd00lBOv8lch0GTt+MDHXfF14Ovjbx0Ti8J y5RvavtgACASCT4Bl1wFAQSQzBxj1vDdWj1nCqkMMPE9CKHjfUy2jqNKjlnJ9Iwo 1BIdhIcbvMsUe5DMrLj7HjwYb4W7 <br>

export K8S_HOST=$(more ~/.kube/config | grep server |awk '/http/ {print $NF}') <br>



15. Запишем конфиг в vault: <br>

kubectl exec -it vault-0 -- vault write auth/kubernetes/config token_reviewer_jwt="$SA_JWT_TOKEN" kubernetes_host="$K8S_HOST" kubernetes_ca_cert="$SA_CA_CRT" <br>


Success! Data written to: auth/kubernetes/config <br>


16. Создадим Permissions для путей: <br>

kubectl exec -it vault-0 sh <br>

vault policy write otus-policy - <<EOH <br>

path "otus/otus-ro/*" {  <br>
capabilities = ["read", "list"]  <br>
}  <br>
path "otus/otus-rw/*" {  <br>
capabilities = ["read", "create", "list", "update"]  <br>
} <br>
EOH <br>

Как воспользоваться командой kubectl cp, если выдается ошибка tar: permission deniend? <br>


17. Создадим Роль и заодно привяжем к Permissions: <br>

kubectl exec -it vault-0 -- vault write auth/kubernetes/role/otus bound_service_account_names=vault-auth bound_service_account_namespaces=default policies=otus-policy ttl=24h  <br>


Success! Data written to: auth/kubernetes/role/otus  <br>



18. Проверка как работает авторизация:

kubectl run --generator=run-pod/v1 tmp --rm -i --tty --serviceaccount=vault-auth --image alpine:3.7  <br>
kubectl exec -it tmp sh <br>

KUBE_TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token) <br>
echo $KUBE_TOKEN <br>

eyJhbGciOiJSUzI1NiIsImtpZCI6Im9IdGdyOFoxSmFSdDdKWnNtQ3d6YnVjX0FPRS1KaG9yNi1COTB5SUc5NEkifQ.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJkZWZhdWx0Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZWNyZXQubmFtZSI6InZhdWx0LWF1dGgtdG9rZW4tbTV2NGMiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC5uYW1lIjoidmF1bHQtYXV0aCIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50LnVpZCI6ImZlYzJjYWFjLTE4MjMtNGU2Zi05ZjkzLTM4N2ZlNGIxMzhjZiIsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDpkZWZhdWx0OnZhdWx0LWF1dGgifQ.sXiJriVOaJE0DQPgU2Si4V2a2LEt98v_9xZi59XO6AvvOWfqrh7mU8y6Z4Zd0y3SXwnPyyQCrmpbKXCFhctp8xhls2rrZLJyhMpHvNXG4Zjt4yGASsTkGohc2gBsRnOypJOGIOYC4kFtaicu-drDtEMmBklL4Po6i4mZFKPFmB6C8o82fc80miLyN46cx1yQr0dQr6DtO0sveKvB42_Vl0btTRCRpkCQVwc8K386WXjuD7NAT4yTNwb2IGQNmY1RJd7Yqy4MDzm0Dpvv-w1jCVorMkezgiKaQmBGuk8-TOoq63xsr73-elE5kS_vRY47dMlszKp5SlwaeNzTOcmVdA <br>

VAULT_ADDR=http://vault:8200 <br>

curl --request POST --data '{"jwt": "'$KUBE_TOKEN'", "role": "otus"}' $VAULT_ADDR/v1/auth/kubernetes/login | jq <br>


При POST-запросе иногда может влезти такое: <br>

"errors": [ <br>
   "permission denied" <br>
 ] <br>
 
 Это значит, что скорее всего в конфиге vault для Kubernetes была допущена ошибка (kubectl exec -it vault-0 -- vault write auth/kubernetes/config ..) <br>
 Каждый раз когда ты пробуешь сделать запрос, даже в случае permission denied - в логах Пода vault все отражается: <br>
 kubectl logs vault-0 <br>
 
 Если все нормально, то результат должен быть такой: <br>

 { <br>
   "request_id": "7f43c927-5dc7-ae0b-3bf2-ae6cd8bb5c8e", <br>
   "lease_id": "", <br>
   "renewable": false, <br>
   "lease_duration": 0, <br>
   "data": null, <br>
   "wrap_info": null, <br>
   "warnings": null, <br>
   "auth": { <br>
     "client_token": "s.C4lp0PCPyEOWarpr8Mi8BZVU", <br>
     "accessor": "VWAprvHII4myh7HmLpdgMxu0", <br>
     "policies": [ <br>
       "default", <br>
       "otus-policy" <br>
     ], <br>
     "token_policies": [ <br>
       "default", <br>
       "otus-policy" <br>
     ], <br>
     "metadata": { <br>
       "role": "otus", <br>
       "service_account_name": "vault-auth", <br>
       "service_account_namespace": "default", <br>
       "service_account_secret_name": "vault-auth-token-m5v4c", <br>
       "service_account_uid": "fec2caac-1823-4e6f-9f93-387fe4b138cf" <br>
     },
     "lease_duration": 86400, <br>
     "renewable": true, <br>
     "entity_id": "f9bfafa1-1ba1-cf42-3023-86697d5c8d87", <br>
     "token_type": "service", <br>
     "orphan": true <br>
   } <br>
 } <br>
 
 
 
 Теперь может это записать в пользовательский токен: <br>

TOKEN=$(curl -k -s --request POST --data '{"jwt": "'$KUBE_TOKEN'", "role": "otus"}' $VAULT_ADDR/v1/auth/kubernetes/login | jq '.auth.client_token' | awk -F\" '{print $2}') <br>
 
echo $TOKEN <br>
s.WzgeqK2u31sPkXaPL1B7D8B2 <br>


19. Проверим чтение с помощью выданного токена:  <br>

curl --header "X-Vault-Token:s.WzgeqK2u31sPkXaPL1B7D8B2" $VAULT_ADDR/v1/otus/otus-ro/config <br>

{«request_id":"0b8c736e-9169-72fc-0cf3-47bf01f3b899","lease_id":"","renewable":false,"lease_duration":2764800,"data" :{"password":"asajkjkahs","username":"otus"},"wrap_info":null,"warnings":null,"auth":null} <br>


curl --header "X-Vault-Token:s.WzgeqK2u31sPkXaPL1B7D8B2" $VAULT_ADDR/v1/otus/otus-rw/config <br>

{«request_id":"30be62dd-6641-2234-8da9-acb46c5bedaa","lease_id":"","renewable":false,"lease_duration":2764800,"data":{"password":"asajkjkahs","username":"otus"},"wrap_info":null,"warnings":null,"auth":null} <br>


Где прочитать логи в случае неудачной попытки записи? <br>


20. Проверим запись: <br>

curl --request POST --data '{"bar": "baz"}' --header "X-Vault-Token:s.yIzuW9ACWaK1V0JlR2dpoeQ9" $VAULT_ADDR/v1/otus/otus-ro/config <br>

{«request_id":"a751195a-46c9-8bde-ecaa-2ce70307b970","lease_id":"","renewable":false,"lease_duration":2764800,"data":{"bar":"baz"},"wrap_info":null,"warnings":null,"auth":null} <br>


21. Use case использования авторизации через кубер: <br>

Суть состоит в том, чтобы nginx получал секреты из волта, не зная ничего про волт. <br>
git clone https://github.com/hashicorp/vault-guides.git <br>

В каталоге identity/vault-agent-k8s-demo нужно: <br>
Заменить в vault-agent-config.hcl auto_auth.config.role на свою <br>
Дальше применить оба hcl-файла как configmap <br>
```
kubectl create configmap example-vault-agent-config —from-file=./configs-k8s/ <br>

kubectl apply -f example-k8s-spec.yml —record <br>
```










 















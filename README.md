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

1. Хеш-таблицы на основе IPVS:\
1.1. настройка: $ kubectl --namespace kube-systemedit configmap/kube-proxy \
1.2. рестарт kube-proxy: $ kubectl --namespace kube-system delete pod --selector='k8s-app=kube-proxy'\
1.3. создание bash-скрипта для cleanup iptables\
1.4. добавление ipvsadm в minikube\

2. Установка и настройка MetalLB:\
2.1. инсталяшка: kubectl apply -fhttps://raw.githubusercontent.com/google/metallb/v0.8.0/manifests/metallb.yaml \
2.2. metallb-config.yaml - настройка MetalLB \
2.3. проверка логов: kubectl --namespace metallb-system logs pod/controller-XXXXXXXX-XXXXXX \
2.4. проверка пинга ip балансировщика в хостовой ОС \
2.5. проверка доступа к приложению через http-запрос \

3. DNS через MetalLB :\
3.1. dns-service-tcp.yaml / dns-service-udp .yaml  - настройка для TCP/UDP \

4. Создание IngressСоздание Ingress :\
4.1. установка kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/mandatory.yaml\
4.2. nginx-lb.yaml - создание объекта LoadBalancer\
4.3. web-svc-headless.yaml - создание Headless сервиса\
4.4. web-ingress.yaml - создание Ingress-прокси\

5. Ingress для Dashboard:\
5.1. dashboard-ingress.yaml - настройка https-доступа к дашборду через Ingress-прокси\

6.  Canary для Ingress:\
6.1. preprod.yaml - конфигурация для развертывания препрод среды\
6.2. product.yaml - конфа для продукта\



<H2>Kubernetes Volumes</H2>

Пример монтирования объекта Secret через переменные среды\
1. minio-secret.yaml - secret-объекты\
2. minio-statefullset.yaml - statefullset приложение minio с сылкой на secret\
3. minio-headless.yaml -headless сервис для доступа к приложению\


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

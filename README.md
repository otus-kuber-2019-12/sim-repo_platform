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
6.2. product.yaml - конфа для продукта 







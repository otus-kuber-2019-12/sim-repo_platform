ci/cd микро-сервисного приложения "app" <br>


Примерный Flow: <br>
1. разработчик коммитит source приложения ./app в gitlab <br>
  ( в папке только: app + .gitlab-ci.yml ) <br>
2. запускается pipeline, который клонирует:  <br>
 - юнит-тесты  <br>
 - ci/cd скрипты отдельного репо <br>
3. собирается docker-контейнер "app" и выполняются юнит-тесты <br>
4. развертывается микро-сервисное окружение вместе с "app" <br>
5. делается ручное тестирование, затем создается merge-request  <br>
6. commit merge-request <br>


cписок микро-сервисов: <br>
   api - сервер <br>
   app - клиент <br>
   postgres - для хранения пользовательских операций  <br>
   redis - кэш <br>
   worker - процессинг (вычисляет числа Фибоначчи) <br>
   nginx - роутинг к app/api <br>
 Юнит тест: <br>
   внутренние скрипты для "app": App.test.js <br>
 Интеграционный тест: <br>
   через helm деплоится custom resource: "CI", который в свою очередь вызывает kubernetes operator <br>
   для развертывания микро-сервисного окружения <br>
   Чекинг: <br>
       check-finish.sh - чек-скрипт проверяет, что все микро-сервисы развернулись: exit 0 - success, exit 1 - failed <br>
           $TEST_DURATION_SEC - время, отведенное на проверку  <br>
           $TMP_NAMESPACE - временный namespace для микро-сервисов <br>
 
Директории: <br>
./app - приложение <br>
./archive - только для примера, в реальном ci/cd не должно быть здесь. <br>
  ./ci-chart - helm-chart для параметризации CI: custom-resource <br>
  ./docker - для сборки "app" <br>
  ./operator - kubernetes-оператор <br>



Преднастройки <br>
1. настройть Gitlab CI/CD Kubernetes <br>
2. настройть Gitlab Runners: Kubernetes (tag: kuber) + Shell (tag: micro-shell) <br>
3. создать repo для "app" <br>
Запуск: <br>
git commit + push <br>

в результате автоматически безопасно будут созданы: <br>
  - crd <br>
  - ci operator <br>
  - микросервисы <br>


Интеграционное тестирование: <br>
 автоматически поднимается ingress с именем "ingress" <br>
 
 из браузера вызов клиентского приложения "app": http://<ingress ip> <br>

 вызов напрямую методов сервера "api":  <br>
  - http://<ingress ip>api/values/current <br>
  - http://<ingress ip>api/values/all <br>




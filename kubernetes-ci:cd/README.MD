<H2>ci/cd микро-сервисного приложения "app" </H2>



Flow: <br>
 ```
1. разработчик коммитит source приложения ./app в gitlab <br>
  ( в папке только: app + .gitlab-ci.yml ) <br>
2. запускается pipeline, который клонирует:  <br>
 - юнит-тесты  <br>
 - ci/cd скрипты отдельного репо <br>
3. собирается docker-контейнер "app" и выполняются юнит-тесты <br>
4. развертывается микро-сервисное окружение вместе с "app" <br>
5. делается ручное тестирование, затем создается merge-request  <br>
6. commit merge-request <br>
 ```

Список микро-сервисов: 
 ```
   api - сервер
   app - клиент 
   postgres - для хранения пользовательских операций  
   redis - кэш
   worker - процессинг (вычисляет числа Фибоначчи) 
   nginx - роутинг к app/api 
 ```

 Юнит тест: <br>
   внутренние скрипты для "app": App.test.js <br>


 Интеграционный тест: <br>

   через helm деплоится custom resource: "CI", который в свою очередь вызывает kubernetes operator для развертывания микро-сервисного окружения <br>
   
   чекинг: <br>
       check-finish.sh - чек-скрипт проверяет, что все микро-сервисы развернулись: exit 0 - success, exit 1 - failed <br>
           $TEST_DURATION_SEC - время, отведенное на проверку  <br>
           $TMP_NAMESPACE - временный namespace для микро-сервисов <br>
 


Директории: 
```
./app - приложение 
./archive - только для примера, в реальном ci/cd не должно быть здесь. 
  ./ci-chart - helm-chart для параметризации CI: custom-resource 
  ./docker - для сборки "app" 
  ./operator - kubernetes-оператор 
```


Преднастройки:
```
1. настройть Gitlab CI/CD Kubernetes
2. настройть Gitlab Runners: Kubernetes (tag: kuber) + Shell (tag: micro-shell) 
3. создать repo для "app" 
```

Запуск: 
```
коммит приложения в репозиторий включает запуска pipeline
```

Результат:<br>

автоматически безопасно будут созданы: <br>
```
  - crd
  - ci operator 
  - namespaces
  - микросервисы 
```

Интеграционное тестирование: <br>

 наряду с остальным также поднимается ingress ( с именем "ingress") <br>
 
 из браузера вызов клиентского приложения "app": 
 ```
 http://<ingress ip> <br>
```
 вызов напрямую методов сервера "api":  
 ```
  - http://<ingress ip>api/values/current <br>
  - http://<ingress ip>api/values/all <br>
```



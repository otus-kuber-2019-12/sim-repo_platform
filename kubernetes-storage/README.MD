<H2>Kubernetes-Storage: CSI</H2>

Проверялась на: GKE - 1.16.8-gke.3
Nodes: 3 - n1-standard-2

<H3>Установка</H3>

Клонируем репо:

 ```
git clone https://github.com/kubernetes-csi/csi-driver-host-path.git
 ```

Устанавливаем CSI:

 ```
deploy/kubernetes-1.16/deploy-hostpath.sh
 ```


Проверяем установку через $ kubectl get pods:
 ```
NAME                         READY   STATUS    RESTARTS   AGE
csi-hostpath-attacher-0      1/1     Running   0          70m
csi-hostpath-provisioner-0   1/1     Running   0          70m
csi-hostpath-resizer-0       1/1     Running   0          70m
csi-hostpath-socat-0         1/1     Running   0          70m
csi-hostpathplugin-0         3/3     Running   0          70m
 ```

Отдельно ставим Snapshotter:
 ```
./hw/snapshotter
 ```

$ kubectl get pods:
 ```
NAME                         READY   STATUS    RESTARTS   AGE
csi-hostpath-snapshotter-0   1/1     Running   0          70m
snapshot-controller-0        1/1     Running   0          5m33s
```

$ kubectl get volumesnapshotclass
 ```
NAME                     AGE
csi-hostpath-snapclass   63m
 ```

<H3>Настройка</H3>

Нарезаем StorageClasses:
```
kubectl apply -f ./hw/storage-class.yaml
```

Создаем PVC:
```
kubectl apply -f ./hw/storage-pvc.yaml
```

Проверим как отработал DynamicProvisioning: $ kubectl get pv
```
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM             STORAGECLASS      REASON   AGE
pvc-db546f8e-b601-46d5-834a-bf1adadccf6c   1Gi        RWO            Delete           Bound    default/csi-pvc   csi-hostpath-sc            26m
```

<H3>Ставим APP</H3>

Создаем App с ссылкой на PVC:
```
kubectl apply -f ./hw/storage-pod.yaml
```

Внутри контейнера App в hostPath ./data создадим любой файл:
```
echo hello-world > /data/hello 
```

Создадим снэпшот директории ./data:
```
kubectl apply -f /hw/volume-snapshot.yaml
```

<H3>Проверяем работу CSI</H3>

удаляем app + pvc:
```
kubectl delete pod my-csi-app
kubectl delete pvc csi-pvc
```


восстанавливаем app:
```
kubectl apply -f ./hw/recovery-pvc.yaml
```
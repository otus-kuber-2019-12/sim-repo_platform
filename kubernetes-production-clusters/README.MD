<H1>Kubernetes Production Grade: GCP </H1>

<H2>KubeAdm: installation</H2>


<H3>Подготовка кластера</H3>

определимся с выбором linux образа, поддерживаемый Compute Engine
```
https://cloud.google.com/compute/docs/images#os-compute-support


Image project: ubuntu-os-cloud
Image family: ubuntu-minimal-1804-lts†
```


Register your application for Compute Engine API in Google Cloud Platform

Если нет проекта, то регистрируем его на GCP и подключаем APIs:
```
enable Compute Engine API
enable Deployment Manager API

gcloud config set project <YOUR PROJECT NAME>
```


через gcloud устанавливаем VMs:
```
https://cloud.google.com/compute/docs/instances/create-start-instance#startinstancegcloud

gcloud compute instances create [INSTANCE_NAME] \
--image [IMAGE_NAME] \
--image-family [IMAGE_FAMILY]
--machine-type [TEMPLATE]
gcloud compute instances create master --image-family ubuntu-minimal-1804-lts --image-project ubuntu-os-cloud --machine-type=n1-standard-2 
gcloud compute instances create node-1 --image-family ubuntu-minimal-1804-lts --image-project ubuntu-os-cloud --machine-type=n1-standard-1 
gcloud compute instances create node-2 --image-family ubuntu-minimal-1804-lts --image-project ubuntu-os-cloud --machine-type=n1-standard-1 
gcloud compute instances create node-3 --image-family ubuntu-minimal-1804-lts --image-project ubuntu-os-cloud --machine-type=n1-standard-1 
gcloud compute instances create node-4 --image-family ubuntu-minimal-1804-lts --image-project ubuntu-os-cloud --machine-type=n1-standard-1
```


<H3>Настройка системных/прикладных библиотек для всех Нод</H3>


отключаем свопинг:
```
http://manpages.ubuntu.com/manpages/bionic/man8/swapon.8.html

swapoff --all
```

включаем forwarding + bridge:
```
http://xgu.ru/wiki/Linux_Bridge

sudo su

cat > /etc/sysctl.d/99-kubernetes-cri.conf <<EOF
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF
sysctl --system
```


устанавливаем docker repo:

```
apt-get update && apt-get install -y \
apt-transport-https ca-certificates curl software-properties-common gnupg2

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository \
"deb [arch=amd64] https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) \
stable"
```

устанавливаем docker ce:
```
apt-get update && apt-get install -y \
containerd.io=1.2.13-1 \
docker-ce=5:19.03.8~3-0~ubuntu-$(lsb_release -cs) \
docker-ce-cli=5:19.03.8~3-0~ubuntu-$(lsb_release -cs)
```

конфигурируем docker daemon:
```
cat > /etc/docker/daemon.json <<EOF
{
"exec-opts": ["native.cgroupdriver=systemd"],
"log-driver": "json-file",
"log-opts": {
"max-size": "100m"
},
"storage-driver": "overlay2"
}
EOF

mkdir -p /etc/systemd/system/docker.service.d


systemctl daemon-reload
systemctl restart docker
```

устанавливаем репо https://apt.kubernetes.io :
```
apt-get update && apt-get install -y apt-transport-https curl

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

cat <<EOF > /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF

apt-get update
```


скачиваем kubelet, kubeadm, kubectl == v.1.17.4-0:
```
apt-get install -y kubelet=1.17.4-00 kubeadm=1.17.4-00 kubectl=1.17.4-00
```




<H3> Создаем Мастер-Ноду </H3>


инициализируем мастер:
```
kubeadm init --pod-network-cidr=192.168.0.0/24
```

настраиваем конфиг для kubectl:
```
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

kubectl get nodes
```

ставим сетевой плагин:
```
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
```
Только на Мастер-Ноде <<<<<<<<< <br>

20lgqu.qnhfu33qn6dcr2tg
e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855



<H3> Подсоединяем Worker-Ноды </H3>

```
kubeadm join --token <token> <master-ip>:<master-port> --discovery-token-ca-cert-hash
sha256:<hash>

kubeadm join --token 20lgqu.qnhfu33qn6dcr2tg 35.223.35.171:6443 --discovery-token-ca-cert-hash sha256:e3b0c44298fc1c149afbf4c8996fb92427ae41e4649
b934ca495991b7852b855

token - получаем из  мастера: $ kubeadm token list
hash:

$ openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der
2>/dev/null | \
openssl dgst -sha256 -hex | sed 's/^.* //'
```



<H3>KubeAdm: update</H3>

Сначала обновляется master-нода:
```
apt-get update && apt-get install -y kubeadm=1.18.0-00 \
kubelet=1.18.0-00 kubectl=1.18.0-00

kubectl get nodes:

NAME        STATUS      ROLES       AGE           VERSION
master      Ready       master      10m32s        v1.18.0
node-1      Ready       <none>      5m16s         v1.17.4
node-2      Ready       <none>      5m18s         v1.17.4
node-3      Ready       <none>      5m12s         v1.17.4
```



Теперь обновим API-server, kube-proxy и controller-manager:
```
kubeadm upgrade plan
kubeadm upgrade apply v1.18.0


kubeadm version
kubelet --version
kubectl version
```




<H3>Kubespray</H3>


устанавливаем pkg manager pip
```
sudo apt install python-pip
```

ставим ansible:
```
pip install ansible
```


через gcloud устанавливаем VMs



создаем ssh-ключ и копируем в VMs:
```
sudo ssh-keygen gcp-key
```



quick start:
```
https://github.com/kubernetes-sigs/kubespray#quick-start

```

Добавьте адреса машин кластера в конфиг kubespray 
```
inventory/mycluster/inventory.ini:
```

Запускаем playbook:
```
ansible -i ./kubespray/inventory/mycluster/inventory.ini -m ping all --user=igorivanov --extra-vars "ansible_sudo_pass=1" --key-file=gcp-ssh-key
```
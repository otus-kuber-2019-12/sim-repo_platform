#!/bin/bash

namespace=$1

function try() {
    [[ $- = *e* ]]; SAVED_OPT_E=$?
    set +e
}

function catch() {
    export ex_code=$?
    (( $SAVED_OPT_E )) && set +e
    return $ex_code
}

try
(  #flux:
    # delete all app deployments:
    [[ $(kubectl delete crd helmreleases.helm.fluxcd.io) ]] 
    # delete old flux components: 
    [[ $(kubectl delete deployment flux -n $namespace) ]]
    [[ $(kubectl delete deployment flux-memcached -n $namespace) ]]
    [[ $(kubectl delete deployment helm-operator -n $namespace) ]]
    [[ $(kubectl delete ClusterRole flux) ]]
    [[ $(kubectl delete ClusterRole helm-operator) ]]
    [[ $(kubectl delete ClusterRoleBinding flux) ]]
    [[ $(kubectl delete ClusterRoleBinding helm-operator) ]]
    [[ $(kubectl delete svc flux -n $namespace) ]]
    [[ $(kubectl delete svc flux-memcached -n $namespace) ]]
    [[ $(kubectl delete svc helm-operator -n $namespace) ]]
    # prepeare for new flux deployment:
    [[ $(kubectl create namespace $namespace) ]]
    [[ $(kubectl -n $namespace create secret generic flux-git-deploy --from-file=identity=./create-production/flux/ssh-key/flux_rsa) ]] 
    [[ $(kubectl apply -f https://raw.githubusercontent.com/fluxcd/helm-operator/master/deploy/crds.yaml) ]]
    echo "safety-create-flux.sh: well done!"
)

catch || {
    case $ex_code in
        *)
            echo "An unexpected exception was thrown"
            throw $ex_code
        ;;
    esac
} 
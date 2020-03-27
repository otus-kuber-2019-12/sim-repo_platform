#!/bin/bash


namespace=$1
istio_operator=$2

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
(  #istio:
    # delete old istio components: 
    [[ $(kubectl delete istiooperators.install.istio.io -n $namespace $istio_operator) ]]
    [[ $(kubectl delete ns istio-operator --grace-period=0 --force) ]]
    [[ $(istioctl manifest generate | kubectl delete -f -) ]]
    [[ $(kubectl create namespace $namespace) ]]
    [[ $(istioctl operator init) ]]
    echo "safety-create-istio.sh: well done!"
)

catch || {
    case $ex_code in
        *)
            echo "An unexpected exception was thrown"
            throw $ex_code
        ;;
    esac
} 



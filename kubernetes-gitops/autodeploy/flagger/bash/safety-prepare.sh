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
(  #flagger:
    [[ $(kubectl delete deployment flagger -n $namespace) ]]
    [[ $(kubectl delete ClusterRole flagger) ]] 
    [[ $(kubectl delete ClusterRoleBinding flagger) ]] 
    echo "FLAGGER BASH : well done!"
)

catch || {
    case $ex_code in
        *)
            echo "An unexpected exception was thrown"
            throw $ex_code
        ;;
    esac
} 
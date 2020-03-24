#!/bin/bash


ok=false
until ${ok}; do
    kubectl describe canary checkout -n production | grep 'Progressing' && ok=true || ok=false
    echo for wait Progressing
    sleep 1
done

echo Progressing has started




ok=false
until ${ok}; do
    kubectl describe canary checkout -n production | grep 'Promoting' && ok=true || ok=false
    echo for wait Promoting
    sleep 1
done

echo Promoting has started


ok=false
until ${ok}; do
    kubectl describe canary checkout -n production | grep 'weight 5' && ok=true || ok=false
    echo for wait weight 5
    sleep 1
done


ok=false
until ${ok}; do
    kubectl describe canary checkout -n production | grep 'weight 10' && ok=true || ok=false
    echo for wait weight 10
    sleep 1
done

ok=false
until ${ok}; do
    kubectl describe canary checkout -n production | grep 'weight 15' && ok=true || ok=false
    echo for wait weight 15
    sleep 1
done


ok=false
until ${ok}; do
    kubectl describe canary checkout -n production | grep 'weight 20' && ok=true || ok=false
    echo for wait weight 20
    sleep 1
done


ok=false
until ${ok}; do
    kubectl describe canary checkout -n production | grep 'weight 25' && ok=true || ok=false
    echo for wait weight 25
    sleep 1
done


ok=false
until ${ok}; do
    kubectl describe canary checkout -n production | grep 'weight 30' && ok=true || ok=false
    echo for wait weight 30
    sleep 1
done

ok=false
until ${ok}; do
    kubectl describe canary checkout -n production | grep 'Promotion completed!' && ok=true || ok=false
    echo for wait Copying productcatalogservice.production
    sleep 1
done
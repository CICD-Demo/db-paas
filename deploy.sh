#!/bin/bash -e

cd $(dirname $0)

. utils

new_env MYSQL_ROOT_PASSWORD $(random)
new_env MYSQL_DATABASE monster
new_env MYSQL_USER monster
new_env MYSQL_PASSWORD $(random)

. ../../environment

osc create -f - <<EOF
kind: List
apiVersion: v1beta3
items:
- kind: ReplicationController
  apiVersion: v1beta3
  metadata:
    name: mysql
    labels:
      service: mysql
      function: backend
  spec:
    replicas: 1
    selector:
      service: mysql
      function: backend
    template:
      metadata:
        labels:
          service: mysql
          function: backend
      spec:
        containers:
        - name: mysql
          image: mysql
          ports:
          - containerPort: 3306
          env:
          - name: MYSQL_ROOT_PASSWORD
            value: "$MYSQL_ROOT_PASSWORD"
          - name: MYSQL_DATABASE
            value: "$MYSQL_DATABASE"
          - name: MYSQL_USER
            value: "$MYSQL_USER"
          - name: MYSQL_PASSWORD
            value: "$MYSQL_PASSWORD"

- kind: Service
  apiVersion: v1beta3
  metadata:
    name: mysql
    labels:
      service: mysql
      function: backend
  spec:
    ports:
    - port: 3306
    selector:
      service: mysql
      function: backend
EOF

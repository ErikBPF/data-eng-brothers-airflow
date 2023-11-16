
WEB=$(shell kubectl get pod -n airflow-data-platform-dev -l component=webserver -o jsonpath="{.items[0].metadata.name}")
SCD=$(shell kubectl get pod -n airflow-data-platform-dev -l component=scheduler -o jsonpath="{.items[0].metadata.name}")
TRG=$(shell kubectl get pod -n airflow-data-platform-dev -l component=triggerer -o jsonpath="{.items[0].metadata.name}")
WKR=$(shell kubectl get pod -n airflow-data-platform-dev -l component=worker -o jsonpath="{.items[0].metadata.name}")

create-ns:
	kubectl create namespace airflow-data-platform-dev

upgrade:
	helm repo add apache-airflow https://airflow.apache.org; \
	helm upgrade --install airflow apache-airflow/airflow -n airflow-data-platform-dev -f manifests/values.yaml --version 1.11.0 --debug

tunnel:
	kubectl port-forward $(WEB) -n airflow-data-platform-dev 8082:8080


local-cp: local-dag local-plugin

local-dag:
	kubectl exec -it $(WEB) -- /bin/bash -c 'rm -rf /opt/airflow/dags/ && mkdir -p /opt/airflow/dags/';\
	kubectl exec -it $(SCD) -- /bin/bash -c 'rm -rf /opt/airflow/dags/ && mkdir -p /opt/airflow/dags/';\
	kubectl exec -it $(TRG) -- /bin/bash -c 'rm -rf /opt/airflow/dags/ && mkdir -p /opt/airflow/dags/';\
	kubectl cp src/dags $(WEB):/opt/airflow/ -n airflow-data-platform-dev; \
	kubectl cp src/dags $(SCD):/opt/airflow/ -n airflow-data-platform-dev; \
	kubectl cp src/dags $(TRG):/opt/airflow/ -n airflow-data-platform-dev

local-plugin:
	#kubectx minikube; \
	kubectl cp src/plugins/ $(WEB):/opt/airflow/ -n airflow-data-platform-dev; \
	kubectl cp src/plugins/ $(SCD):/opt/airflow/ -n airflow-data-platform-dev; \
	kubectl cp src/plugins/ $(TRG):/opt/airflow/ -n airflow-data-platform-dev



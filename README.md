# Automated Password Rotation with HashiCorp Vault on Kubernetes (KIND / EKS)

## Description

This project automates password rotation using HashiCorp Vault within a Kubernetes cluster.   The cluster can either be a local Kubernetes in Docker (KIND) setup or an Amazon Elastic Kubernetes Service (EKS) cluster, and deploys a TeamCity CI setup for HashiCorp Vault integration testing.

### Project Structure
```
.
├── Makefile # Makefile for project automation
├── README.md # This README file
├── docker
│ ├── dev.Dockerfile # Dockerfile for python development environment
│ └── password-rotation.Dockerfile # Dockerfile for password rotation -cronjob-
├── docker-compose.yml # Docker Compose configuration
├── eks
│ ├── codejam-cluster.yaml # EKS cluster configuration
│ ├── eks.sh # Script for managing EKS cluster
│ ├── fix-pvc-pending.sh # Script to fix PVC pending issue
│ └── ingress-controller-values.yaml # Ingress controller configuration
├── kind
│ ├── cluster-config.yaml # KIND cluster configuration
│ ├── ingress-controller-values.yaml # Ingress controller configuration for KIND
│ ├── kind.sh # Script for managing KIND cluster
│ └── metallb-config.yaml # MetalLB load balancer configuration
├── password-rotation-cronjob
│ ├── create-app-role.py # Python script to create an app role in Vault
│ ├── cronjob.sh # Script for managing cronjob
│ ├── cronjob.yaml # CronJob configuration
│ ├── job.yaml # Job configuration
│ ├── password-rotation.py # Python script for password rotation on Vault
│ ├── requirements.txt # Python package requirements
│ └── vault_connector.py # Python script for Vault integration
├── scripts
│ ├── init.sh # Initialization script
│ ├── kube-context.sh # Script for managing Kubernetes contexts
│ ├── pre-commit # Pre-commit hooks
│ └── run-password-rotation-script.sh # Script for running password rotation
├── teamcity
│ ├── agents
│ │ ├── agent-1 # Docker volume
│ │ ├── agent-2 # Docker volume
│ │ └── agent-3 # Docker volume
│ ├── buildserver_pgdata # Docker volume
│ ├── data_dir # Docker volume
│ ├── default.conf # Nginx default configuration
│ ├── docker-compose.yml # Docker Compose for TeamCity
│ ├── pgadmin_data # Docker volume
│ ├── teamcity-server-logs # Docker volume
│ └── teamcity.sh # Script for managing TeamCity
└── vault
├── README.md # README for the Vault component
├── backup
│ ├── Dockerfile # Dockerfile for Vault backup
│ └── backup.sh # Script for Vault backup
├── deployment-diagram.jpg # Diagram depicting Vault deployment
├── hc-vault
│ ├── Chart.lock # Chart lock file
│ ├── Chart.yaml # Chart metadata
│ ├── charts # Helm charts for dependencies
│ ├── pvc.yaml # PersistentVolumeClaim configuration
│ ├── templates # Helm chart templates
├── test-ingress.yaml # K8S configuration, Ingress, Service and Pod for testing
└── values.yaml # Helm chart values
```

### Getting Started

#### Initialize the Project

Run the following command to initialize the project:

```bash
make init
```

#### Docker Compose Operations

- To start the python development container with Docker Compose:
```bash
make up
```

- To stop the python development container:
```bash
make down
```

- To check the status of the development container:
```bash
make ps
```

- To access the development container:
```bash
make exec
```

#### Python Development Environment Configuration
- Copy the provided .env.template file to .env in the project's root directory. This file will store your environment variables.
```bash
VAULT_TOKEN="your_vault_token_here"
VAULT_ROLE_ID="your_vault_role_id_here"
VAULT_ROLE_SECRET_ID="your_vault_role_secret_id_here"
VAULT_URL="http://your_vault_url_here"
VAULT_ENGINE="your_vault_engine_here"
VAULT_SECRET_PATH="your_vault_secret_path_here"
VAULT_SECRET_KEY="your_vault_secret_key_here"
```
- Replace the values and your changes to the .env file.  

Now, your environment configuration is set up with the correct values for HashiCorp Vault integration. You can proceed with the project's commands as described in the previous sections.

#### Cluster Setup
- For KIND cluster setup:
```bash
make kind <start|stop>
```

- For EKS cluster setup:
```bash
make eks <start|stop>
```

#### Vault Deployment
For Vault helm chart deployment to K8S cluster:
```bash
make vault <start|stop>
```

#### Password Rotation CronJob
Manage the password rotation script python development and the cronjob deployment:
```bash
make cronjob <pip|freeze|run|create-role|deploy>
```

#### TeamCity
Manage TeamCity deployment on docker-compose:
```bash
make teamcity <start|stop>
```

#### Kubernetes Context
Sets Kubernetes contexts (KIND or EKS):
```bash
make kube-context <local|cloud>
```

Please note that the project is designed to work in a Kubernetes environment. The specific Kubernetes cluster (KIND or EKS) can be chosen as needed.

## License

This project is licensed under the [MIT License](LICENSE) - see the [LICENSE](LICENSE) file for details.
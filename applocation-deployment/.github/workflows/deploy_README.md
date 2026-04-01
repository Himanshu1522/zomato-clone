# 🚀 Step2: CI/CD Pipeline: Docker + Helm Deployment with GitHub Actions
This repository automates the build, push, and deployment of a Dockerized application to Kubernetes using Helm via GitHub Actions.

## 📂 Workflow File: .github/workflows/deploy.yaml
This workflow is triggered on every push to the main branch and includes:

- Docker image build

- Docker image push to DockerHub

- Helm-based deployment to a Kubernetes cluster

## ✅ Prerequisites
### 1. DockerHub Account
You need a DockerHub account and a repository for your image.

### 2. Kubernetes Cluster
Ensure you have a reachable Kubernetes cluster and kubectl + Helm configured locally or via GitHub runners (e.g., using kubeconfig secrets or a GitHub-hosted cluster).

### 🔐 GitHub Secrets
Go to `Settings > Secrets and variables > Actions` in your repository and add:

- `DOCKER_USERNAME` :	Your DockerHub username
- `DOCKER_PASSWORD` :	Your DockerHub password or PAT
- KUBECONFIG (Optional)	Kubeconfig content (if deploying from GitHub runner to private cluster)
## 🌐 Environment Variables
These are set globally in the workflow file under env::

- `DOCKER_REGISTRY` :	The Docker registry (e.g., docker.io)
- `DOCKER_REPOSITORY` :	Format: <yourusername>/<yourapp> (e.g., lavanya123/myapp)
- `IMAGE_TAG` :	Tag for the Docker image (uses the commit SHA)
### Update the following in deploy.yaml:
``` yaml
env:
  DOCKER_REGISTRY: docker.io
  DOCKER_REPOSITORY: <yourusername/yourapp> # <-- Replace this
  IMAGE_TAG: ${{ github.sha }}
```
## 🔧 Helm Deployment Options
Update the Helm upgrade/install step with your chart location, release name, and any additional Helm values:

```bash
helm upgrade --install myapp-release . \
  --wait \
  --timeout 15m \
  --set service.type=LoadBalancer \
  --set image.repository=$DOCKER_REGISTRY/$DOCKER_REPOSITORY \
  --set image.tag=$IMAGE_TAG \
  --atomic
```
If your Helm chart is in a subdirectory, update . to point to that path (e.g., ./helm/mychart).

## 🛠️ Workflow Breakdown
### ➤ Checkout Code
Clones your repo on the GitHub Actions runner.

### ➤ Set up Docker Buildx
Prepares Docker for advanced build options (multi-arch, caching, etc.).

### ➤ Docker Login
Authenticates with DockerHub using stored secrets.

### ➤ Build Docker Image
Builds your image using the specified Dockerfile and tags it.

### ➤ Push Docker Image
Pushes the tagged image to your DockerHub repository.

### ➤ Set up Helm
Installs Helm CLI on the runner (version v3.13.0).

### ➤ Helm Upgrade/Install
Deploys your application to the Kubernetes cluster using Helm.

### 🧪 How to Trigger
Go to `Actions → Terraform workflow → Run workflow`

Deploy it to Kubernetes using Helm.

🛑 Notes
Helm must have access to a Kubernetes cluster (public or via kubeconfig).

You may need to add a kubectl setup or kubeconfig secret if deploying to private clusters.

Consider customizing values.yaml to support different environments.
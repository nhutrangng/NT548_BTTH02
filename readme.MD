# NT548 - BTTH2: AWS Infrastructure & Microservices CI/CD

## Mục tiêu bài thực hành

1) Triển khai hạ tầng AWS bằng Terraform và tự động hóa bằng GitHub Actions, tích hợp Checkov.
2) Triển khai hạ tầng AWS bằng CloudFormation và tự động hóa build/deploy bằng AWS CodePipeline (CodeBuild + cfn-lint + Taskcat).
3) Xây dựng CI/CD cho microservices với Jenkins, SonarQube, Trivy, Docker, Kubernetes.

## Cấu trúc thư mục

```
.
├── .github/
│   └── workflows/
│       └── terraform-ci.yml
├── CloudFormation/
│   ├── buildspec.yml
│   └── templates/
│       └── infrastructure.yaml
├── Microservices/
│   ├── Dockerfile
│   ├── Jenkinsfile
│   ├── k8s/
│   │   ├── deployment.yaml
│   │   └── service.yaml
│   └── src/
│       ├── package.json
│       └── server.js
└── Terraform/
    ├── main.tf
    ├── outputs.tf
    ├── terraform.tfvars
    ├── variables.tf
    └── modules/
        ├── Instance/
        ├── NAT/
        ├── Route_Table/
        ├── SG/
        └── vpc/
```

## Yêu cầu môi trường

- AWS CLI >= 2.x
- Terraform >= 1.x
- Docker + Docker Hub account
- kubectl + Kubernetes (minikube/k3s/cluster thật)
- Jenkins + SonarQube + Trivy
- Python 3.11 (dùng cho cfn-lint, taskcat)

## 1) Terraform + GitHub Actions + Checkov

### Mô tả

Workflow GitHub Actions ở `.github/workflows/terraform-ci.yml` tự động:
- Chạy Checkov scan cho thư mục Terraform.
- Lấy IP của GitHub Runner và set `TF_VAR_my_ip`.
- Terraform init/plan/apply trên thư mục `Terraform/`.

### Secrets cần cấu hình trong GitHub

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

### Chạy Terraform thủ công (local)

```bash
cd Terraform
terraform init
terraform plan
terraform apply -auto-approve
```

### Cấu hình IP vào `terraform.tfvars`

```hcl
region     = "ap-southeast-1"
cidr_block = "10.0.0.0/16"
my_ip      = ["<YOUR_IP>/32"]
```

## 2) CloudFormation + CodePipeline + CodeBuild

### Mô tả

Template hạ tầng: `CloudFormation/templates/infrastructure.yaml`.
CodeBuild sử dụng `CloudFormation/buildspec.yml` để chạy:
- `cfn-lint` kiểm tra template.
- Taskcat có thể bật thêm để test stack (đang tạm skip trong buildspec để ổn định).

### Gợi ý cấu hình AWS CodePipeline

1) Tạo CodeCommit repo và push toàn bộ mã nguồn.
2) Tạo CodeBuild project:
   - Source: CodeCommit
   - Buildspec: `CloudFormation/buildspec.yml`
3) Tạo CodePipeline:
   - Source: CodeCommit
   - Build: CodeBuild
   - Deploy: CloudFormation (stack mới hoặc cập nhật stack)

### Tham số quan trọng (CloudFormation)

- `MyIpCidr`: IP public dạng `x.x.x.x/32`
- `KeyName`: tên key pair trên AWS (mặc định `NT548`)

## 3) Jenkins + Microservices CI/CD

### Mô tả pipeline

Jenkinsfile tại `Microservices/Jenkinsfile` gồm:
- SonarQube scan mã nguồn
- Build Docker image
- Trivy scan (HIGH/CRITICAL)
- Push Docker Hub
- Deploy Kubernetes

### Credentials cần có trong Jenkins

- `docker-hub-creds`: username/password Docker Hub
- `sonar-token`: token SonarQube
- `kubeconfig-aws`: Secret file chứa kubeconfig

### Lưu ý Jenkins & Node.js

SonarQube JavaScript analyzer cần Node.js. Nếu Jenkins chưa có Node, hãy:
- Cài NodeJS plugin và tạo tool `node18`, hoặc
- Cài Node trực tiếp vào Jenkins container/agent.

### Deploy Kubernetes

Deploy dùng các file:
- `Microservices/k8s/deployment.yaml`
- `Microservices/k8s/service.yaml`

Service chạy NodePort 30001 và healthcheck tại `/health`.

## Kiểm tra nhanh microservice

```bash
curl http://<NODE_IP>:30001/health
curl http://<NODE_IP>:30001/api/v1/menu
```

## Ghi chú nộp bài

- Đã cập nhật mã nguồn lên GitHub.
- Nộp: báo cáo Word + link GitHub + README hướng dẫn cài đặt và chạy.

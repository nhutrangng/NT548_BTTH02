# NT548 - Lab 1: AWS Infrastructure with Terraform

## Giới thiệu

Bài tập này triển khai một hạ tầng AWS hoàn chỉnh theo mô hình **multi-tier VPC** sử dụng Terraform, bao gồm:

- **VPC** (`10.0.0.0/16`) tại region Singapore (`ap-southeast-1`)
- **4 Subnet** trải trên 2 Availability Zones:
  - Public Subnet 1: `10.0.3.0/24` (ap-southeast-1a)
  - Public Subnet 2: `10.0.4.0/24` (ap-southeast-1b)
  - Private Subnet 1: `10.0.1.0/24` (ap-southeast-1a)
  - Private Subnet 2: `10.0.2.0/24` (ap-southeast-1b)
- **Internet Gateway** cho phép public subnet ra ngoài internet
- **2 NAT Gateways** (kèm Elastic IP) cho phép private subnet truy cập internet một chiều
- **Route Tables** định tuyến traffic đúng hướng
- **Security Groups** kiểm soát truy cập SSH
- **4 EC2 Instances** (Ubuntu 22.04 LTS, t2.micro): 2 public + 2 private

## Kiến trúc hệ thống

```
Internet
    │
    ▼
Internet Gateway
    │
    ├─── Public Subnet 1 (10.0.3.0/24) ──── Public Instance 0
    │         │
    │    NAT Gateway 1 (Elastic IP)
    │
    ├─── Public Subnet 2 (10.0.4.0/24) ──── Public Instance 1
    │         │
    │    NAT Gateway 2 (Elastic IP)
    │
    ├─── Private Subnet 1 (10.0.1.0/24) ─── Private Instance 0
    │         └── egress qua NAT GW 1
    │
    └─── Private Subnet 2 (10.0.2.0/24) ─── Private Instance 1
              └── egress qua NAT GW 1
```

**Luồng truy cập SSH:**
- Máy local → (SSH qua IP của bạn) → Public Instance
- Public Instance → (SSH qua private subnet CIDR) → Private Instance

## Cấu trúc thư mục

```
Terraform/
├── main.tf              # Module root, kết nối các module
├── variables.tf         # Khai báo biến đầu vào
├── outputs.tf           # Output sau khi apply
├── terraform.tfvars     # Giá trị biến (cần chỉnh my_ip)
└── modules/
    ├── vpc/             # VPC, IGW, Subnets
    ├── NAT/             # NAT Gateways + Elastic IPs
    ├── Route_Table/     # Route tables & associations
    ├── SG/              # Security Groups
    └── Instance/        # EC2 Instances
```

## Yêu cầu

| Công cụ | Phiên bản |
|---------|-----------|
| [Terraform](https://developer.hashicorp.com/terraform/install) | >= 1.0 |
| [AWS CLI](https://aws.amazon.com/cli/) | >= 2.0 |
| AWS Account | Có quyền tạo VPC, EC2, NAT GW |

### AWS Key Pair

Bài tập sử dụng key pair tên **`NT548`**. Tạo key pair trên AWS Console hoặc dùng lệnh sau:

```bash
aws ec2 create-key-pair \
  --key-name NT548 \
  --query 'KeyMaterial' \
  --output text \
  --region ap-southeast-1 > NT548.pem

chmod 400 NT548.pem
```

### Cấu hình AWS Credentials

```bash
aws configure
# AWS Access Key ID: <your-access-key>
# AWS Secret Access Key: <your-secret-key>
# Default region name: ap-southeast-1
# Default output format: json
```

## Cách lấy IP hiện tại của máy (`my_ip`)

Security Group public chỉ cho phép SSH từ đúng IP của bạn. Chạy lệnh sau để lấy IP public hiện tại:

**Linux / macOS:**
```bash
curl -s ifconfig.me
# hoặc
curl -s icanhazip.com
# hoặc
curl -s checkip.amazonaws.com
```

**Windows (PowerShell):**
```powershell
(Invoke-WebRequest -Uri "ifconfig.me" -UseBasicParsing).Content.Trim()
# hoặc
(Invoke-WebRequest -Uri "checkip.amazonaws.com" -UseBasicParsing).Content.Trim()
```

**Windows (Command Prompt):**
```cmd
curl ifconfig.me
```

Kết quả ví dụ: `203.162.xx.xx` → thêm `/32` thành `203.162.xx.xx/32`

## Cấu hình biến (`terraform.tfvars`)

Mở file `terraform.tfvars` và cập nhật IP của bạn:

```hcl
region     = "ap-southeast-1"
cidr_block = "10.0.0.0/16"
my_ip      = ["<YOUR_IP>/32"]   # Thay bằng IP lấy được ở bước trên
```

**Cách tự động điền IP vào file (Linux/macOS):**
```bash
MY_IP=$(curl -s ifconfig.me)
sed -i "s|my_ip.*|my_ip = [\"${MY_IP}/32\"]|" terraform.tfvars
```

**Cách tự động điền IP vào file (Windows PowerShell):**
```powershell
$MY_IP = (Invoke-WebRequest -Uri "ifconfig.me" -UseBasicParsing).Content.Trim()
(Get-Content terraform.tfvars) -replace 'my_ip.*', "my_ip = [`"$MY_IP/32`"]" | Set-Content terraform.tfvars
```

## Các bước triển khai

### 1. Khởi tạo Terraform

```bash
cd Terraform
terraform init
```

Output mong đợi:
```
Terraform has been successfully initialized!
```

### 2. Kiểm tra kế hoạch triển khai

```bash
terraform plan
```

Lệnh này hiển thị toàn bộ tài nguyên sẽ được tạo mà **chưa thực sự tạo gì**. Kiểm tra kỹ output để đảm bảo đúng với mong đợi (khoảng 20+ resources).

### 3. Triển khai hạ tầng

```bash
terraform apply
```

Nhập `yes` khi được hỏi xác nhận. Quá trình tạo hạ tầng mất khoảng **3–5 phút** (NAT Gateway cần thời gian khởi động).

Hoặc tự động xác nhận:
```bash
terraform apply -auto-approve
```

### 4. Xem kết quả (Outputs)

Sau khi apply thành công, Terraform in ra:
```
Outputs:

internet_gateway_id  = "igw-xxxxxxxxxxxxxxxxx"
nat_gateway_ids      = ["nat-xxxxxxxxxxxxxxxxx", "nat-xxxxxxxxxxxxxxxxx"]
private_subnet_ids   = ["subnet-xxxxxxxxxxxxxxxxx", "subnet-xxxxxxxxxxxxxxxxx"]
public_subnet_ids    = ["subnet-xxxxxxxxxxxxxxxxx", "subnet-xxxxxxxxxxxxxxxxx"]
vpc_id               = "vpc-xxxxxxxxxxxxxxxxx"
```

Để xem lại outputs bất cứ lúc nào:
```bash
terraform output
```

## Kết nối SSH vào EC2

### Kết nối vào Public Instance

```bash
ssh -i NT548.pem ubuntu@<PUBLIC_INSTANCE_IP>
```

Lấy public IP của instance trên AWS Console hoặc:
```bash
aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=public-instance-*" \
             "Name=instance-state-name,Values=running" \
  --query "Reservations[*].Instances[*].PublicIpAddress" \
  --output text \
  --region ap-southeast-1
```

### Kết nối vào Private Instance (qua Public Instance làm jump host)

```bash
# Bước 1: Copy key lên public instance (hoặc dùng SSH Agent Forwarding)
scp -i NT548.pem NT548.pem ubuntu@<PUBLIC_IP>:~/.ssh/

# Bước 2: SSH vào public instance
ssh -i NT548.pem ubuntu@<PUBLIC_IP>

# Bước 3: Từ public instance, SSH tiếp vào private instance
ssh -i ~/.ssh/NT548.pem ubuntu@<PRIVATE_INSTANCE_IP>
```

**Dùng SSH Agent Forwarding (tiện hơn):**
```bash
ssh -A -i NT548.pem ubuntu@<PUBLIC_IP>
# Sau đó từ public instance:
ssh ubuntu@<PRIVATE_INSTANCE_IP>
```

## Xóa hạ tầng

Để tránh tốn chi phí AWS, xóa toàn bộ tài nguyên khi không dùng:

```bash
terraform destroy
```

Nhập `yes` để xác nhận. Hoặc:
```bash
terraform destroy -auto-approve
```

> **Lưu ý:** NAT Gateway và Elastic IP có thể gây tốn phí ngay cả khi instance không chạy. Luôn chạy `destroy` sau khi hoàn thành bài tập.

## Lưu ý quan trọng

- **`my_ip`** phải là IP public hiện tại của máy bạn (định dạng `x.x.x.x/32`). Nếu IP thay đổi (ví dụ: đổi mạng), cần cập nhật lại `terraform.tfvars` và chạy `terraform apply` để cập nhật Security Group.
- **Key pair `NT548`** phải tồn tại trong AWS account và region `ap-southeast-1` trước khi chạy `terraform apply`.
- **NAT Gateway** có chi phí theo giờ. Mỗi NAT GW ~$0.045/giờ + $0.045/GB data.
- File `terraform.tfstate` chứa trạng thái hạ tầng, **không được xóa** trong quá trình làm bài.

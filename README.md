# Terraform-AWS

**Main Application Repository:** [https://github.com/pietro-foini/agentic-chatbot](https://github.com/pietro-foini/agentic-chatbot)

Infrastructure as Code (IaC) repository using Terraform to deploy cloud resources on Amazon Web Service (AWS).

The infrastructure is split into components (`common`, `chatbot`) and uses environment-based configuration files (`environments/<env>/`).


## Repository Structure

- **terraform/common**: Shared baseline resources ().
- **terraform/chatbot**: Chatbot specific resources ().
- **environments/**: Variable definitions per environment.

> **Note:** Separating `common` was technically redundant for this scope, but it was designed this way to simulate a 
> scalable architecture where additional components can easily be added in the future.

## Prerequisites & Local Setup

An active Amazon Web Service account with billing enabled and sufficient IAM permissions (e.g., Owner or Editor).

1. Tools required
   - **Terraform** (https://developer.hashicorp.com/terraform/install):
   
      > terraform -version 

   - **AWS CLI** (https://docs.aws.amazon.com/it_it/cli/latest/userguide/getting-started-install.html). 
   - **Python & pip** for pre-commit hooks (optional).

2. Configure pre-commit for code formatting (optional):

    > pip install pre-commit  
    > pre-commit install
  
3. Local AWS Authentication:

    > aws login

## Deployment

### Step 1: Pre-Deployment Setup (Manual)

Before running Terraform with remote state, complete these initial manual steps:

1. Create the Terraform State S3 Bucket:

    Terraform needs a remote bucket to store state files:

        aws s3 mb s3://<YOUR-TFSTATE-BUCKET-NAME> --region <YOUR-REGION>
    
    (It is strongly recommended to enable object versioning on this bucket).
    
    In my case, I have `<YOUR-REGION>=eu-north-1`; and I set 
    `<YOUR-TFSTATE-BUCKET-NAME>=foini-tf-state`.
    
    Or create the bucket through AWS Console.

### Step 2: Deployment Workflow

Deploy `common` first, followed by `chatbot`.

#### Deploy `common`

Navigate to directory:

    cd terraform/common

Initialize with remote backend:

    terraform init `
      -backend-config="bucket=foini-tf-state" `
      -backend-config="key=chatbot/common/terraform.tfstate" `
      -backend-config="region=eu-north-1" `
      -migrate-state

Validate configuration:

    terraform validate

Run plan:

    terraform plan -var-file="../../environments/chatbot/common.tfvars"

Apply changes:

    terraform apply -var-file="../../environments/chatbot/common.tfvars"

#### Post-Deployment Steps (Manual)

Once the infrastructure resources are provisioned by Terraform:

- Enable `pgvector` on RDS:
  - Connect to the created database (locally for example with DBeaver).
  - Run the following SQL statement:

    > CREATE EXTENSION IF NOT EXISTS vector;

#### Deploy `chatbot`

Navigate to directory:

    cd terraform/chatbot

Initialize remote backend:

    terraform init `
      -backend-config="bucket=foini-tf-state" `
      -backend-config="key=chatbot/chatbot/terraform.tfstate" `
      -backend-config="region=eu-north-1" `
      -migrate-state

Validate configuration:

    terraform validate

Run plan:

    terraform plan -var-file="../../environments/chatbot/chatbot.tfvars"

Apply changes:

    terraform apply -var-file="../../environments/chatbot/chatbot.tfvars"

Once Terraform finishes running `terraform apply`, the EC2 instance is created, but it typically takes around 1 to 
2 minutes for the initial bootstrapping (user_data) script to complete in the background.

To verify its status:

- Open the AWS Management Console and navigate to EC2 > Instances.
- Select your instance and connect using EC2 Instance Connect.
  - Check the bootstrap initialization logs by running: `sudo cat /var/log/cloud-init-output.log`
  - If you see active downloads, package installations, or tasks in progress at the bottom: the machine is still provisioning. Wait another 30–60 seconds.
  - If you see a red error message or a non-zero exit code: the script encountered a failure and halted at that step.
- Once the log shows that cloud-init has finished successfully, your FastAPI service is live and reachable in your browser at:

      http://<EC2_PUBLIC_IP>:8000

---

### Optional: Testing Locally without AWS Backend

If you want to test syntax and plan purely locally without touching the remote AWS state:

Open `backend.tf` and temporarily comment out the backend block and follow previous initialization, validation, planning and
applying steps.

Terraform will automatically fall back to the default `local` backend. If you run terraform apply, it will store the state
locally in a file named `terraform.tfstate` inside the current folder (make sure `.tfstate` files are included in your 
`.gitignore` so they are not committed to Git).

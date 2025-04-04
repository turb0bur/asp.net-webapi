# ASP.NET Core WebApi Sample with HATEOAS, Versioning & Swagger

In this repository I want to give a plain starting point at how to build a WebAPI with ASP.NET Core.

This repository contains a controller which is dealing with FoodItems. You can GET/POST/PUT/PATCH and DELETE them.

Hope this helps.

See the examples here: 

## Versions

``` http://localhost:29435/swagger ```

![ASPNETCOREWebAPIVersions](./.github/versions.jpg)

## GET all Foods

``` http://localhost:29435/api/v1/foods ```

![ASPNETCOREWebAPIGET](./.github/get.jpg)

## GET single food

``` http://localhost:29435/api/v1/foods/2 ```

![ASPNETCOREWebAPIGET](./.github/getSingle.jpg)

## POST a foodItem

``` http://localhost:29435/api/v1/foods ```

```javascript
  {
      "name": "Lasagne",
      "type": "Main",
      "calories": 3000,
      "created": "2017-09-16T17:50:08.1510899+02:00"
  }
```

![ASPNETCOREWebAPIGET](./.github/post.jpg)

## PUT a foodItem

``` http://localhost:29435/api/v1/foods/5 ```

``` javascript
{
    "name": "Lasagne2",
    "type": "Main",
    "calories": 3000,
    "created": "2017-09-16T17:50:08.1510899+02:00"
}
```

![ASPNETCOREWebAPIGET](./.github/put.jpg)


## PATCH a foodItem

``` http://localhost:29435/api/v1/foods/5 ```

``` javascript
[
  { "op": "replace", "path": "/name", "value": "mynewname" }
]
```

![ASPNETCOREWebAPIGET](./.github/patch.jpg)

## DELETE a foodItem

``` http://localhost:29435/api/v1/foods/5 ```


![ASPNETCOREWebAPIGET](./.github/delete.jpg)

## Terraform Infrastructure

This project includes Terraform configurations that deploy a robust AWS infrastructure for hosting the ASP.NET Core WebAPI in a secure and scalable environment.

### Infrastructure Overview

The Terraform code provisions a complete AWS environment with the following components:

- **VPC and Network Configuration**: Creates a VPC with public and private subnets across multiple availability zones for high availability.
- **NAT Instance**: Deploys a custom NAT instance in the public subnet to allow private subnet instances to access the internet.
- **ECS Cluster**: Sets up an Amazon ECS cluster for container orchestration.
- **Application Load Balancer**: Configures an ALB in the public subnet to distribute traffic to the ECS services.
- **Auto Scaling Groups**: Implements ASGs for both NAT and application instances to ensure availability and scalability.
- **IAM Roles and Security Groups**: Establishes appropriate permissions and network access controls.

### Key Architecture Decisions

#### NAT Instance vs. NAT Gateway

The infrastructure uses a custom NAT instance instead of a managed NAT Gateway for the following reasons:

- **Cost Efficiency**: NAT instances can be more cost-effective for smaller workloads.
- **Critical for ECS Registration**: The NAT instance provides outbound internet connectivity for EC2 instances in private subnets, which is **essential for the ECS agent** to communicate with the ECS service and register the instance to the cluster.
- **Bastion Host Functionality**: The NAT instance also serves as a Bastion host, allowing secure access to private instances via AWS Systems Manager (SSM) Session Manager without exposing SSH ports to the internet.
- **Custom Configuration**: The NAT instance uses a specialized Amazon Linux AMI (`amzn-ami-vpc-nat`) and custom user data script to:
  - Enable IP forwarding
  - Disable source/destination checking
  - Automatically configure routes from private subnets to the internet
- **Self-Healing Architecture**: The NAT instance runs in an Auto Scaling Group configured primarily for self-healing purposes, ensuring that if the NAT instance fails, a new one will automatically be launched and configured.

#### ECS-Optimized AMI

The application instances use the Amazon ECS-optimized AMI (`amzn2-ami-ecs-hvm`) because:

- **Pre-installed ECS Agent**: Comes with the ECS container agent already installed, which requires outbound internet access (provided by the NAT instance) to register with the ECS service
- **Performance Optimizations**: Contains kernel settings and configurations optimized for running containers
- **Automatic Registration**: The instances automatically register themselves with the ECS cluster via the user data script and the pre-installed ECS agent

#### Network Architecture

- **Public Subnets**: Host NAT instances and the Application Load Balancer
- **Private Subnets**: Contain the ECS container instances, protected from direct internet access
- **Security Groups**: Carefully control traffic flow between components

#### Container Deployment

- The ASP.NET Core WebAPI is deployed as an ECS service
- A task definition specifies the container configuration, including environment variables
- The ALB provides HTTP access with a health check path pointing to `/swagger/index.html`

### Benefits of This Architecture

- **Security**: Application instances are isolated in private subnets
- **Scalability**: Auto Scaling Groups dynamically adjust capacity
- **High Availability**: Resources are distributed across multiple AZs
- **Managed Infrastructure**: Uses Infrastructure as Code for consistent deployments

### Terraform Workspaces

The project utilizes Terraform workspaces to provide flexibility and separation of environments:

- **Environment and Region Combination**: Each workspace represents a unique combination of AWS region and environment (e.g., `euc1-dev` for EU Central 1 Development environment)
- **Separated State Files**: Each workspace maintains its own state file, ensuring complete isolation between environments
- **Easy Scaling**: The workspace approach allows for easily scaling the infrastructure to multiple regions and environments while maintaining consistency
- **Configuration Flexibility**: Environment-specific variables are defined in separate `.tfvars` files (e.g., `euc1-dev.tfvars`), allowing for different configurations per environment:
  - Instance types and sizes
  - Scaling parameters
  - Network CIDR blocks
  - Service deployment configurations

This workspace-based approach provides a clean separation of concerns and allows for managing multiple deployments of the same infrastructure with different parameters without code duplication.

### Deployment Instructions

To deploy this infrastructure, follow these steps:

#### Prerequisites
- Terraform CLI installed (version 1.0.0+)
- AWS CLI installed and configured with appropriate credentials
- Git (to clone this repository)

#### Creating and Managing Workspaces

1. **Initialize Terraform**
   ```bash
   cd terraform
   terraform init
   ```

2. **Create a New Workspace**
   ```bash
   # Format: terraform workspace new [region]-[environment]
   terraform workspace new euc1-dev  # EU Central 1 - Development
   ```

3. **List Available Workspaces**
   ```bash
   terraform workspace list
   ```

4. **Switch Between Workspaces**
   ```bash
   terraform workspace select euc1-dev
   ```

#### Deploying Infrastructure

1. **Plan Deployment**
   ```bash
   # Use the appropriate .tfvars file for the selected workspace
   terraform plan -var-file="workspaces/euc1-dev.tfvars" -out=tfplan
   ```

2. **Apply Deployment**
   ```bash
   terraform apply tfplan
   ```

3. **View Outputs**
   ```bash
   terraform output
   ```

#### Destroying Infrastructure

When you need to tear down the infrastructure:

```bash
# Make sure you're in the correct workspace
terraform workspace select euc1-dev

# Destroy resources in the current workspace
terraform destroy -var-file="workspaces/euc1-dev.tfvars"
```

#### Working with Multiple Environments

You can easily deploy to multiple environments:

```bash
# Create a production workspace
terraform workspace new euc1-prod

# Deploy to production
terraform plan -var-file="workspaces/euc1-prod.tfvars" -out=tfplan
terraform apply tfplan
```

This approach allows for maintaining consistent infrastructure across different environments while keeping state files and configurations separated.

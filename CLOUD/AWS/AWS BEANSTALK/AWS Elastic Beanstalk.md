**Overview:**  
AWS Elastic Beanstalk simplifies application deployment and management in the AWS Cloud by handling infrastructure tasks like capacity provisioning, load balancing, scaling, and monitoring. This allows developers to focus on coding without managing underlying AWS services.

**Supported Platforms:**  
Elastic Beanstalk supports applications built with **Go, Java, .NET, Node.js, PHP, Python, Ruby, and Docker**. Docker allows custom programming languages and dependencies beyond the supported platforms.

**Deployment & Management:**
- Applications can be deployed via the Elastic Beanstalk console, AWS CLI, or the `eb` CLI.
- Users create an application and upload its version, and Elastic Beanstalk automatically provisions AWS resources like EC2 instances.

 ![Elastic Beanstalk Overview](Pasted%20image%2020250210220156.png)
- Once deployed, application metrics, events, and status updates are available through the console, APIs, and CLI tools.

**Pricing:**  
Elastic Beanstalk itself is free, but users pay for the underlying AWS resources used by their applications.

**Next Steps:**  
For a hands-on experience, refer to the **Getting Started with Elastic Beanstalk** guide, which explains creating, managing, and deploying applications. Additional resources cover concepts, platform support, and AWS integration.

---
# Concepts

## **Create**
   Creating an Application and Environment in AWS Elastic Beanstalk
   #### **Overview**

   AWS Elastic Beanstalk simplifies application deployment by automatically provisioning and managing AWS resources. This guide walks you through creating an example application and launching an environment.

####   **Steps to Create an Example Application**

1. **Open the Elastic Beanstalk Console** and choose **Create application**. 
2. **Enter an Application Name** (e.g., getting-started-app) and optionally add tags.
3. **Select a Platform** for your application and click **Next**.
4. **Configure Service Access**:
    - Choose **Use an existing service role** for the Service Role.
    - Select an **EC2 Instance Profile** from the dropdown list:
        - If aws-elasticbeanstalk-ec2-role is available, select it.
        - If not, choose the default profile for your environment.
        - If no options appear, create an IAM role for EC2 and refresh the list.
5. **Skip to Review**, check all configurations, and click **Submit**

#### **AWS Resources Created by Elastic Beanstalk**
- **EC2 Instance** – A virtual machine running your web app.
- **Instance Security Group** – Allows HTTP traffic (port 80) from the load balancer.
- **Amazon S3 Bucket** – Stores source code, logs, and other artifacts.
- **Amazon CloudWatch Alarms** – Monitors load and triggers Auto Scaling.
- **AWS CloudFormation Stack** – Manages infrastructure as code.
- **Domain Name** – Routes traffic to your app (subdomain.region.elasticbeanstalk.com).

#### **Deployment Process**
- Elastic Beanstalk creates an application (getting-started-app) and an environment (GettingStartedApp-env).
- It deploys the default **Sample Application** code.
- The console tracks progress in the **Events tab**.
- When the environment is ready and health checks pass, the application is live.

This process takes about **five minutes**, after which you can access your web application via the assigned domain.

## Explore
   Viewing the Environment Overview in AWS Elastic Beanstalk
    
 ### **Steps to Access the Environment Overview**
1. **Open the Elastic Beanstalk Console**.
2. **Select Your AWS Region** from the **Regions list**.
3. In the **navigation pane**, choose **Environments**.
4. **Select Your Environment** from the list.
    - Use the **search bar** if you have multiple environments.    
#### **Key Information on the Environment Overview Page**
- **Top-Level Details**:
    - Environment **name**    
    - **Domain URL** (application’s web address)   
    - **Health status**   
    - Currently deployed **application version** 
    - **Platform version** running the application
    - 
- **Recent Activity & Status**:
    - The **Events tab** logs status updates and errors.
    - When launching resources, the environment status shows as **Pending**, with continuous updates.
#### **Navigating the Environment Overview Tabs**
1. **Events** – Displays logs from Elastic Beanstalk and related AWS services.
2. **Health** – Shows the health status of **EC2 instances** running the application.
3. **Logs** – Retrieve full or recent logs from the EC2 instances (available for 15 minutes).
4. **Monitoring** – View performance metrics like **CPU usage and latency**.
5. **Alarms** – Manage alerts based on environment metrics.
6. **Managed Updates** – Track upcoming and completed platform updates.
7. **Tags** – Manage key-value tags for organizing environments.

The **Domain URL** is displayed under the **Health** section—clicking it opens the application. A **Go to Environment** link is also available in the left pane for quick access.
## Deploy New Version
Deploying a New Application Version in AWS Elastic Beanstalk
You can deploy a new version of your application at any time, provided no other updates are in progress.
#### **Steps to Update Your Application Version**
1. **Download the Appropriate Sample Application**
    - Choose the sample application that matches your platform:
        - **Docker** – docker.zip
        - **Multicontainer Docker** – docker-multi-container-v2.zip
        - **Preconfigured Docker (Glassfish)** – docker-glassfish-v1.zip
        - **Go** – go.zip
        - **Corretto** – corretto.zip
        - **Tomcat** – tomcat.zip
        - **.NET Core on Linux** – dotnet-core-linux.zip
        - **.NET Core** – dotnet-asp-windows.zip
        - **Node.js** – nodejs.zip
        - **PHP** – php.zip
        - **Python** – python.zip
        - **Ruby** – ruby.zip
            
2. **Access the Elastic Beanstalk Console**
    - Open the **Elastic Beanstalk console**.
    - Select your **AWS Region**.
    - Navigate to **Environments** and select your environment.
    - Use the **search bar** if you have multiple environments.
        
3. **Upload and Deploy the New Version**
    - On the **Environment Overview** page, select **Upload and Deploy**.
    - Click **Choose file** and upload the downloaded application source bundle.
    - Elastic Beanstalk automatically generates a unique **Version label**.
        - If manually entering a label, ensure it is unique.
    - Click **Deploy**.

4. **Monitor the Deployment Process**
    - The deployment status appears on the **Environment Overview** page.
    - During deployment, the environmental **Health status** turns **gray**.
    - Once complete, Elastic Beanstalk performs a **health check**:
        - If successful, the status changes to **green**.
        - The new **Running Version** appears with the assigned **Version label**.
        
5. **View Deployed Versions**
    - Elastic Beanstalk saves all application versions.
    - To see the version history, go to **Application versions** under **getting-started-app** in the **navigation pane**.


## Configure
Modifying Environment Capacity in AWS Elastic Beanstalk
You can configure your Elastic Beanstalk environment to use a **load-balanced, scalable setup** with a minimum of 2 and a maximum of 4 Amazon EC2 instances in its Auto Scaling group. This ensures better responsiveness and availability.

---
### **Steps to Change Environment Capacity**
1. **Open the Elastic Beanstalk Console**
    - Navigate to the **AWS Elastic Beanstalk console**.
    - Select your **AWS Region** from the **Regions list**.
        
2. **Access Your Environment**
    - In the **navigation pane**, choose **Environments**.
    - Click on your **environment name**.
    - Use the **search bar** if you have multiple environments.
        
3. **Modify Capacity Settings**
    - In the **navigation pane**, click **Configuration**.
    - Locate the **Instance traffic and scaling configuration** category and click **Edit**.
    - In the **Capacity section**, change:
        - **Environment type** → **Load balanced**
        - **Min instances** → **2**
        - **Max instances** → **4**
    - Click **Apply**.
    - A warning appears indicating that all instances will be replaced. Click **Confirm**.
    
4. **Monitor the Environment Update**
    - The **Environment Overview** page appears.
    - Under the **Events tab**, wait for the message:
        - _"Successfully deployed new configuration to the environment."_
    - This confirms that Elastic Beanstalk has set the minimum Auto Scaling instance count to **2** and has launched a second instance.
---

### **Verifying the Configuration Change**
1. **Check Environment Health**
    - In the **navigation pane**, click **Health**.
    - Locate the **Enhanced instance health** section.
    - You should see **two Amazon EC2 instances** listed, confirming that your capacity has increased.
## Clean Up
To completely remove your Elastic Beanstalk application and all related resources, follow these steps:

---
### **1. Delete All Application Versions**
1. **Open the Elastic Beanstalk Console**
    - Navigate to the **AWS Elastic Beanstalk console**.
    - Select your **AWS Region** from the **Regions list**.
    
2. **Navigate to Application Versions**
    - In the **navigation pane**, choose **Applications**.
    - Select **getting-started-app**.
    - Click on **Application versions**.
        
3. **Delete the Application Versions**
    - Select all the versions you want to delete.
    - Click **Actions** → **Delete**.
    - Enable **Delete versions from Amazon S3**.
    - Click **Delete**, then **Done**.

---
### **2. Terminate the Environment**
1. **Navigate to Environments**
    - In the **navigation pane**, choose **getting-started-app**.
    - Find **GettingStartedApp-env** in the environment list.
        
2. **Terminate the Environment**
    - Click **Actions** → **Terminate Environment**.
    - Type the environment name (GettingStartedApp-env) to confirm.
    - Click **Terminate**.

---
### **3. Delete the Application**
1. **Navigate to Applications**
    - In the **navigation pane**, select **getting-started-app**.
        
2. **Delete the Application**
    - Click **Actions** → **Delete application**.
    - Type getting-started-app to confirm.
    - Click **Delete**.

---




# **There are two types of environments in Elastic Beanstalk:**
- **Web Server Environment** – Handles HTTP requests and serves web application.
- **Worker Environment** – Processes background tasks and jobs asynchronously.
---
## Elastic Beanstalk web server environments
![Web Server Tier](Pasted%20image%2020250210220447.png)
### **Elastic Beanstalk Web Server Tier Architecture Overview**

#### **1. Environment & Core Components**
- **Environment**: The foundation of an Elastic Beanstalk application, responsible for managing AWS resources.
- **AWS Resources Created**:
    - **Elastic Load Balancer (ELB)**: Distributes traffic among EC2 instances.
    - **Auto Scaling Group**: Manages EC2 instances dynamically based on traffic.
    - **Amazon EC2 Instances**: Compute instances running the application.
#### **2. DNS & Routing with Amazon Route 53**
- Every Elastic Beanstalk environment has a **CNAME (URL)** like `myapp.us-west-2.elasticbeanstalk.com`.
- **Amazon Route 53** aliases this to an ELB URL (`abcdef-123456.us-west-2.elb.amazonaws.com`).
- If a custom domain is registered, Route 53 can forward requests to the CNAME.
#### **3. Load Balancing & Auto Scaling**
- **ELB** directs incoming traffic to EC2 instances in the **Auto Scaling group**.
- **Amazon EC2 Auto Scaling** dynamically adjusts the number of instances based on traffic load.
#### **4. Software Stack & Host Manager**
- Each EC2 instance runs a **container type** (e.g., Apache Tomcat on Amazon Linux).
- The **Host Manager (HM)** on EC2 instances is responsible for:
    - Deploying applications.
    - Aggregating events, logs, and metrics.
    - Monitoring logs for critical errors.
    - Patching instance components.
    - Rotating log files and storing them in **Amazon S3**.
#### **5. Security & Access Control**
- EC2 instances are part of a **security group**, which defines firewall rules.
- By default, Elastic Beanstalk allows HTTP access on **port 80**
- Additional security groups can be defined (e.g., for a database srver).

This architecture enables **scalability, high availability, and efficient application deployment** in AWS Elastic Beanstalk. 🚀

---
## Elastic Beanstalk worker environments

### **Use Case: Background Task Processing with Elastic Beanstalk Worker Tier**
Many applications need to handle **background tasks** that don’t require an immediate response. The **worker environment tier** in Elastic Beanstalk is ideal for processing such tasks asynchronously.

![Worker Tier](Pasted%20image%2020250210224250.png)
#### **Example Scenarios**
- **Image Processing**: A web app uploads images to S3 and queues the processing task in **Amazon SQS**. A worker instance retrieves the task and resizes the image in the background.
- **Email Notifications**: Instead of delaying the user experience, emails are queued and sent later by worker instances.
- **Data Processing**: Logs, analytics, or batch jobs are offloaded to a worker environment for efficient processing.
---
### **Elastic Beanstalk Worker Tier Architecture Overview**
#### **1. AWS Resources Created**
When deploying a **worker environment tier**, Elastic Beanstalk provisions the following AWS resources:
- **Auto Scaling Group**: Ensures scalability by adding or removing EC2 instances based on demand.
- **Amazon EC2 Instances**: Compute resources that process background tasks.
- **IAM Role**: Provides permissions for instances to access AWS services.
- **Amazon SQS Queue**: If not already created, Elastic Beanstalk provisions an SQS queue for message handling.
#### **2. Message Processing with Amazon SQS**
- A **daemon** is installed on each EC2 instance in the worker environment.
- The daemon **reads messages** from the Amazon SQS queue.
- It forwards message data to the **worker application** running in the environment for processing.
- If multiple EC2 instances exist, each one runs its **own daemon**, but they all pull messages from the same SQS queue.
#### **3. Monitoring & Health Reporting**
- **Amazon CloudWatch** is used for:
    - **Alarms** to track critical metrics.
    - **Health monitoring** to ensure system stability.

By using an **Elastic Beanstalk worker environment**, applications can efficiently **offload non-interactive tasks**, reducing the load on the main web application and improving performance. 🚀

---
# **Elastic Beanstalk IAM Roles & Permissions Overview**
Elastic Beanstalk requires various IAM roles and permissions to manage AWS resources efficiently. This includes **service roles**, **instance profiles**, and **IAM user policies** to ensure secure and automated operations.

---
## **1. Service Role (IAM Role for AWS Services)**
A **service role** is an IAM role that an AWS service assumes to perform actions on your behalf. AWS services like **Elastic Beanstalk, EC2, Lambda, and RDS** use these roles when interacting with other AWS services.
#### **Elastic Beanstalk Service Role Summary**
Elastic Beanstalk uses an **IAM service role** to call AWS services like EC2, Load Balancing, and Auto Scaling on your behalf. Two **managed policies** are attached:

3. **AWSElasticBeanstalkEnhancedHealth** – Provides permissions for monitoring environment health and SQS queue activity in worker environments.
    
4. **AWSElasticBeanstalkManagedUpdatesCustomerRolePolicy** – Grants permissions for managed platform updates, including Elastic Beanstalk actions, role passing, environment monitoring, instance management, ECS, and Auto Scaling operations.
These policies ensure Elastic Beanstalk can create, update, and manage environments efficiently.
#### **Example Service Role Policy**

```
{ 
"Version": "2012-10-17",
"Statement": [
              {
                "Effect": "Allow",
                "Action": [
                           "elasticbeanstalk:*",
                           "ec2:DescribeInstances",
                           "autoscaling:*",
                           "sqs:GetQueueAttributes",
                           "ecs:*"
                          ],
                "Resource": "*"
              }
            ]
}

```
- This ensures Elastic Beanstalk can fully manage AWS resources required for deployment and scaling.
    

---
## **Elastic Beanstalk Instance Profile**
An **instance profile** is an IAM role assigned to EC2 instances in an Elastic Beanstalk environment. It grants permissions for instances to interact with AWS services securely.
#### **Key Capabilities**
With the instance profile, EC2 instances can:
- **Retrieve & store data** in **Amazon S3**
- **Upload debugging data** to **AWS X-Ray**
- **Manage containers** with **Amazon ECS** (for Docker environments)
- **Read messages from Amazon SQS** and perform **leader election with DynamoDB** (for worker environments)
- **Publish health metrics** to **Amazon CloudWatch**

#### **Elastic Beanstalk Managed Policies**
Elastic Beanstalk provides predefined **managed policies** for common use cases:
- **AWSElasticBeanstalkWebTier** – For web applications
- **AWSElasticBeanstalkWorkerTier** – For worker environments
- **AWSElasticBeanstalkMulticontainerDocker** – For Docker-based environments
For additional AWS service access, attach extra policies to the instance profile as needed.
---
### **Elastic Beanstalk IAM User Best Practices**
- **Use individual IAM users** for Elastic Beanstalk access instead of the root account.
- Follow the **principle of least privilege**—grant only the necessary permissions.

#### **Required Permissions for Elastic Beanstalk Users**
Elastic Beanstalk requires IAM permissions to manage various AWS resources, including:
- **Launching infrastructure** – EC2, Load Balancer, Auto Scaling
- **Managing storage & logs** – Amazon S3
- **Sending notifications** – Amazon SNS
- **Assigning instance profiles** – IAM
- **Publishing monitoring data** – Amazon CloudWatch
- **Orchestrating deployments** – AWS CloudFormation
- **Managing databases** – Amazon RDS
- **Creating and managing queues** – Amazon SQS (for worker environments)

For detailed permission policies, refer to **Managing Elastic Beanstalk User Policies** in the AWS documentation.

---
# **Elastic Beanstalk Platform Overview**
Elastic Beanstalk supports multiple platforms to run applications efficiently. A **platform** consists of an operating system, runtime, web server, application server, and other dependencies required to run applications.
#### **Supported Platform Categories:**
5. **Preconfigured Platforms** – Managed by AWS, including:
    - **Node.js, Python, Ruby, Go, .NET, Java**
    - **PHP, Docker, and Multicontainer Docker**
6. **Custom Platforms** – Allows users to define custom AMIs and environments when AWS-managed platforms don’t meet requirements.
---
### **Working with Docker on Elastic Beanstalk**
Elastic Beanstalk fully supports **Docker**, allowing you to deploy containerized applications without managing infrastructure. You can use **single-container** or **multi-container** environments, depending on complexity.

---
## **1. Single-Container Docker**
Best for simple applications running a single service inside a container.
### **How It Works:**
7. Elastic Beanstalk launches an **EC2 instance** with **Docker** installed.
8. It reads the **Dockerfile** or **Dockerrun.aws.json (v1)** from the application source.
9. The container is built and started on the instance.
10. Elastic Beanstalk handles logging, monitoring, and scaling.

### **Steps to Deploy:**
- **Initialize Elastic Beanstalk:**
  `eb init -p docker my-docker-app`

 * ***Create a Dockerfile** (Example for a simple Node.js app):
   `FROM node:18` `WORKDIR /app` `COPY . .` `RUN npm install` `CMD ["node", "server.js"]`

* ***Deploy the application:**
  `eb create my-docker-env`
---
## **2. Multicontainer Docker**
Used for applications requiring multiple services running in separate containers. It uses **Amazon ECS (Elastic Container Service)** under the hood.

### **How It Works:**
11. Elastic Beanstalk provisions an **EC2 instance** with the **ECS agent** installed.
12. It reads the **Dockerrun.aws.json (v2)** file, which defines multiple containers, ports, and links.
13. ECS manages the containers inside the instance.
14. Elastic Beanstalk ensures logging, scaling, and health monitoring.
### **Steps to Deploy:**
- **Initialize the environment:**
  `eb init -p multi-container-docker my-app`

* ***Create a** `Dockerrun.aws.json` **file (Example for Nginx + Node.js app):**

```
{
"AWSEBDockerrunVersion": "2",
"containerDefinitions": [
                          {
                            "name": "nginx",
                            "image": "nginx",
                            "memory": 128,
                            "essential": true,
                            "portMappings": [
                                              { "containerPort": 80, 
                                              "hostPort": 80 
                                              }
                                            ]
                           },
                           {
                           "name": "node-app",
                           "image": "my-node-app",
                           "memory": 512,
                           "essential": true,
                           "portMappings": [
					                           { 
					                           "containerPort": 3000, 
					                           "hostPort": 3000 
					                           }
                                           ]
                           }
                       ] 
}
```

* ***Deploy the environment:**
  `eb create my-multicontainer-env`
---
## **3. Using Images from a Private Repository**
Elastic Beanstalk can pull container images from **private registries** like **Amazon ECR** or **Docker Hub private repositories**.
### **Steps to Use a Private Image:**
- **Authenticate the Instance**
    - Store your **ECR authentication token** in AWS Systems Manager Parameter Store.
    - For Docker Hub, create an `auth.json` file and configure credentials.
- **Modify** `Dockerrun.aws.json` to specify the private repository:
    
```
{
"AWSEBDockerrunVersion": "2",
"containerDefinitions": [
							{
							"name": "my-private-app",
			"image":"123456789012.dkr.ecr.useast1.amazonaws.com/myrepo:latest", 
							"memory": 512,
							"essential": true
							}
                        ]
}
```

15. **Ensure the instance role has ECR permissions:**
    - Attach `AmazonEC2ContainerRegistryReadOnly` to the **instance profile**.
---
## **4. Difference Between** `docker-compose.yml` **and** `Dockerrun.aws.json`

| Feature       | `docker-compose.yml`            | `Dockerrun.aws.json`       |
| ------------- | ------------------------------- | -------------------------- |
| Format        | YAML                            | JSON                       |
| Usage         | Local Docker & Swarm            | AWS Elastic Beanstalk      |
| Orchestration | Manages multiple containers     | Uses ECS under the hood    |
| Networking    | Defines networks for services   | Uses ECS service linking   |
| Compatibility | Works with `docker-compose` CLI | Requires Elastic Beanstalk |

**Key Takeaway:**
- Use `docker-compose.yml` for local testing and development.
- Use `Dockerrun.aws.json` when deploying to **Elastic Beanstalk**.
---
## **5. Using the ECS-Managed Docker Platform in Elastic Beanstalk**
Elastic Beanstalk provides an **ECS-managed Docker platform** that simplifies **container orchestration**.

### **Advantages:**
✔ Uses **Amazon ECS** for container scheduling.  
✔ Supports **AWS Fargate** for serverless container management.  
✔ Integrated **IAM & VPC networking** for better security.

### **How to Use:**
- Select **"Preconfigured - ECS-managed Docker"** when creating an Elastic Beanstalk environment.
- Define container settings in **Dockerrun.aws.json (v2)**.
- Elastic Beanstalk automatically provisions **ECS services & tasks**.
---
## **6. Configuring Elastic Beanstalk Docker Environments**
Elastic Beanstalk allows fine-tuned configurations for Docker-based environments using **.ebextensions**.

### **Example: Increase Logging Limits**
Create `.ebextensions/logging.config`:

```
files: "/etc/docker/daemon.json":
mode: "000644"
owner: root
group: root
content: |
			{
			"log-driver": "json-file",
			"log-opts": {
			"max-size": "50m",
			"max-file": "3"
			            }
}

```

### **Example: Set Custom Environment Variables**
Create `.ebextensions/env.config`:
```
option_settings: aws:elasticbeanstalk:application:environment:
APP_ENV: "production"
DATABASE_URL: "postgres://user:password@host/db"
```
---
## **Key Takeaways**
✔ Elastic Beanstalk supports **single-container** and **multi-container** Docker setups.  
✔ Use **private repositories** for security and **ECS-managed** platforms for scalability.  
✔ `Dockerrun.aws.json` is **Elastic Beanstalk-specific**, while `docker-compose.yml` is for **local development**.  
✔ Use `.ebextensions` to **customize** your Docker environment.

---
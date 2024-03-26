# terraform

In the provided Terraform **UseCase**, we are setting up a basic **blue-green** deployment infrastructure on AWS. 
Here's a step-by-step explanation of what each section does:

**AWS Provider Configuration:**
We define the AWS provider with the region where our resources will be deployed. This example uses the us-east-1 region.

**Elastic Load Balancer (ELB) Setup:**
An ELB named main-load-balancer is created.
It's configured to manage traffic across availability zones us-east-1a and us-east-1b.
We define a listener for the ELB to receive HTTP traffic on port 80 and forward it to the instances it manages, also on port 80.
The health check is set up to monitor the health of the instances via HTTP requests to the root path (/) on port 80.

**Auto Scaling Launch Configurations:**
Two launch configurations are created, one for the blue environment (blue) and one for the green environment (green).
Each configuration specifies the type of EC2 instance to use (t2.micro) and the AMI ID, which will determine the software that's pre-installed on each instance.
The create_before_destroy lifecycle policy is set to true to ensure that new instances are created before the old ones are destroyed during updates.
Auto Scaling Groups (ASGs):

Two ASGs are defined: blue-group and green-group.
Each ASG is linked to its respective launch configuration.
blue-group is initially set to a desired_capacity of 2, meaning it will start with two instances.
green-group starts with a desired_capacity of 0, meaning it will have no instances and receive no traffic.
Each group is configured to use the ELB for load balancing and to perform health checks.
We define which subnets the ASG instances will be a part of with vpc_zone_identifier.
The force_delete option allows the group to be deleted without waiting for all instances to terminate, and wait_for_capacity_timeout is set to 0 to bypass the capacity wait time.
Outputs:

The DNS name of the ELB is outputted so that it can be accessed externally. This is the URL that would be used to access the application.
The intention behind this setup is to allow a blue-green deployment, where the blue environment is currently serving traffic and the green environment is idle or being prepared with a new version of the application. Once the green environment is ready and tested, traffic can be switched over from the blue to the green environment by updating the desired_capacity of each ASG, thereby achieving a zero-downtime deployment.

This switch is not shown in the Terraform configuration and would typically be performed as a separate step after confirming that the new environment is ready to handle the production load. The switch could be made manually by changing the Terraform variables or could be automated as part of a CI/CD pipeline.



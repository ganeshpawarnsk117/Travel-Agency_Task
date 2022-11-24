# Travel-Agency_Task
#Refer work-flow.odt word file

Work Flow for Travel-Agency task

1. Create AWS infra using terraform script for following services.

    • Setting up VPC with public, private, Data base private subnets, igw, NAT gateway, SG, route tables.





    • EC-2 public server for Jenkins
    • ECS Demo-Cluster in private subnet
      


    • S3 Bucket for backend-terraform-task & travel-agency-loadbalancers-logs



    • Setting up ECR (travel-agency), ECS service and Autoscalling 






    • Setting up Load balancer

    • Setting up RDS





For execution of above terraform script use following commands
    1. terraform init
    2. terraform plan
    3. terraform apply


2. After setting up infra install following packages in server and take the access.
    • Java
    • Jenkins
    • Docker
    • Git


3. Clone git repository https://github.com/Atiksujon360/travel-agency.git




4. Create Dockerfile for php image and push it to git repository

	https://github.com/prafulnc14/Travel-Agency_Task.git



5. Import sql file in the tagency database using following commands
       
    1. mysql -u admin -p -h tagency.c7vb75mjfxjx.ap-south-1.rds.amazonaws.com (ask for password : admin123)

    2. show databases;

    3. mysql -u admin -p -h tagency.c7vb75mjfxjx.ap-south-1.rds.amazonaws.com tagency < tagency.sql 
       
    4. use tagency;
       
    5. select * from customers;  (for checking new entries)














6.  For deployment on ECS throgh Jenkins CI-CD using freestyle job & write a script name as      	ecs.sh

    1. Clone the repository https://github.com/prafulnc14/Travel-Agency_Task used master banch
    2. Loging to ECR and build docker
    3. Push the image to ECR repository
    4. Deploy on the ECS 
       



7. For setting up website used free domain which already available for DNS used Route 53 	service

    • https://traveldemo.tk/




8. For Admin login

    • User name: admin@gmail.com
    • Password: admin
    
9. Supporting Screenshots for Home-page, Login-page, Admin-page refer work-flow.odt file


























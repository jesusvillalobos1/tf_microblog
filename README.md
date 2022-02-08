# big-project

  

Bug project to test and learn infrastructure as code (Terraform), configuration management (Ansible) and golden image standards (packer). Everything built to deploy a Python3 flask app: microblog. For education and testing purposes.

  

Release: 2



* Infrastructure works, still no modularity or full interdependency between terraform modules. manual deployment of application works.

* Golden image standard: A golden image for app server and bastions are being created with packer.

* App listens on port 80, avoiding costs of creating a valid ssl certificate for https.

  

## How to deploy:

Assuming you have your AWS credentials and default region as env variables.

**region must be set to 'us-west-2'

   &nbsp;

1 Clone repo:

```

	git clone git@github.com:RafaelRojas/big-project.git

```

  

**total number of resources to be created in AWS from each Terraform module:

Network = 21

Database = 3

Application = 7

Bastion = 4


  &nbsp;
  

2 Deploy Network TF module:

```

	cd Network

	terraform init #initialize terraform

	terraform plan #plan changes

	terraform apply #approve and apply

```
 &nbsp; 
  

3 Once applied, go to Database TF module and apply:

```

	cd ../Database

	terraform init #initialize terraform

	terraform plan #plan changes

	terraform apply #approve and apply

```

After finishing RDS deployment terraform will output the name of the endpoint on the terminal, annotate the RDS endpoint

  
  

Then go into directory

/big-project/Images/Ansible/files

and edit the "env" file and add the RDS enpoint to the database string, example:

  

`DATABASE_URL=mysql+pymysql://microblog:microdbpwd@[DATABASE_URL]:3306/microblog`

to:

  

`DATABASE_URL=mysql+pymysql://microblog:microdbpwd@app-database.cywwrsnrrb24.us-west-2.rds.amazonaws.com:3306/microblog`

   &nbsp;

4 We will now build the app server golden image using packer  

go to the directory:  

/big-project/Images/AppServer  

**This process will take about 20 min  

run the command:  

```

	packer build appserver-packer.json

```
 &nbsp;
  

5 Once it builds golden image for app server go to the directory:

/big-project/application

Open the "data.tf" (line 24) and update "owner"

To reflect the actual owner of the AMI in AWS

(you can view that info in the AWS console in EC2-AMIs)

Now when we deploy infrastructure, the code will catch up automatically latest available AMI build:

```

	cd ../Application

	terraform init #initialize terraform

	terraform plan #plan changes

	terraform apply #approve and apply

```

   &nbsp;
 

6 Now we will build the golden image for the bastion server  

go to directory:  

/big-project/Images/Bastion  

to build the bastion image, run the command:  

```

	packer build bastion-packer.json

```
 &nbsp;
  

7 Once it builds golden image for bastion server, go to the directory:  

/big-project/bastion  

Now when we deploy infrastructure, the code will catch up automatically latest available AMI build:  

```

	cd ../Bastion

	terraform init #initialize terraform

	terraform plan #plan changes

	terraform apply #approve and apply

```

  

And done!

  

If you go to EC2/load balancers and check the dns name for your LB you will be able to se the login page of the microblog:

  
  

![Eureka!](https://i.imgur.com/atRy0k2.png)

  

## How to destroy:

  

Nobodywants those AWS pesky charges, we intend to use the AS free tier as long as possible.

  

Simply terraform destroy in this order:

  

1 We start with removing the Bastion deployment:

  

```

	cd bastion

	terraform destroy -auto-approve

```

  

2 Next the application:

  

```

	cd ..

	cd Application

	terraform destroy -auto-approve

```

  

3  Go to your AWS web console and go to EC2 - Images - AMI and select owned by me in the dropdown menu. De-register both bastion and app server images

  

4 Also go to EC2 -Elastic Block Storage - Snapshots and delete the snapshots related to app-server and bastion.

  

5 After that terminate database:

  

```

	cd ..

	cd Database

	terraform destroy -auto-approve

```

  

This will take a long time...

   &nbsp;


6 Finally, destroy network:

```

cd ..

cd Network

terraform destroy -auto-approve

```

  

## TODO (for next release).

  

* Better secret management. Get rid of plain text passowrds.

* Better ssh keys management. No plain text keys!

* GitHub Actions trigger for deployment after code commits

* terraform cloud or S3 backend. A remote backend for cleaner management.

* Multi terraform admin capabilities (added with remote backend).


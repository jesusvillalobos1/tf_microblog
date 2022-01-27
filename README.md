# big-project

Bug project to test and learn infrastructure as code (Terraform), configuration management (Ansible) and golden image standards (packer).  Everything built to deploy a Python3 flask app: microblog. For education and testing purposes.

Release: 2

* Infrastructure works, still no modularity or full interdependency between terraform modules. manual deployment of application works.
* Golden image standard: A golden image for app server and bastions are being created with packer. 
* App listens on port 80, avoiding costs of creating a valid ssl certificate for https.

How to deploy:

Clone repo.

Deploy Network: 
```
cd Network
Assuming you have your AWS credentials and default region as env variables.
terraform init #initialize terraform
terraform plan #plan changes
terraform apply #approve and apply
```
Once applied, go to Database and apply:
```
cd ../Database
Assuming you have your AWS credentials and default region as env variables.
terraform init #initialize terraform
terraform plan #plan changes
terraform apply #approve and apply
```

Annotate the RDS endpoint that this terraform module prints.

Go to `Images/Ansible` and edit the env file and add the RDS enpoint to the database string, example:

`DATABASE_URL=mysql+pymysql://microblog:microdbpwd@[DATABASE_URL]:3306/microblog`

to:

`DATABASE_URL=mysql+pymysql://microblog:microdbpwd@app-database.cywwrsnrrb24.us-west-2.rds.amazonaws.com:3306/microblog`

Then go to Images/Appserver and build golden image for app server:

 `packer build appserver-packer.json`


Once it builds golden image for app server go to Application folder and apply infrastructure. Code will catch up automatically latest available AMI build.

```
cd ../Application
terraform init #initialize terraform
terraform plan #plan changes
terraform apply #approve and apply
```

Now, build the abstion image.



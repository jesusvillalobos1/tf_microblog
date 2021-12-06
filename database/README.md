## Database module for Big App

An Database terraform configuration module for creating the net stack for Big App.
It launches its MYQSL 8.0.23 instance on a t2.micro instance.

Files:

* `main.tf`. Main resources configuration file, the resources are created here.
* `provider.tf`. Provider (AWS) configuration file.
* `variables.tf`. Variables for most of the RDS instance.

## Application module for Big App

An Application terraform configuration module for creating the net stack for Big App.
It launches ASG, LC, and LB for app

Files:

* `main.tf`. Main resources configuration file, the resources are created here.
* `provider.tf`. Provider (AWS) configuration file.
* `variables.tf`. Variables for the stack, here the CIDRs range are declared.
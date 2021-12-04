## Network module for Big App

A network terraform configuration module for creating the net stack for Big App.

Files:

* `main.tf`. Main resources configuration file, the resources are created here.
* `provider.tf`. Provider (AWS) configuration file.
* `variables.tf`. Variables for the stack, here the CIDRs range are declared.
* `output.tf`. Output file from the module, to be used for modularity.
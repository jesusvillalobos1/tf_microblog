# Image Base for Application Server


Image base directory for creating a Golden Image (Personalized AMI) for application server for big project. 

We use Ansible and Vagrant with Vurtualbox and ubuntu 20.04.2LST to test the playbooks before running packer build and get charged by the instances and EBS volumes used for testing.

Tools used:
* Packer 1.7.8
* Ansible  2.12.1
* Vagrant 2.2.19


**Structure:**  
```
├── README.md
├── appserver.yml
├── files
│   ├── certs
│   │   ├── cert.pem
│   │   └── key.pem
│   ├── env
│   ├── microblog.conf
│   └── nginx
│       └── microblog
├── packer.json
├── provision-app.sh
└── vagrant
    ├── README.md
    └── vagrantfile
``` 
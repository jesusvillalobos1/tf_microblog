# big-project

Big project to integrate all DevOps toolset 


# CHANGELOG
* 10/24. Initial release. Setup terraform credentials. Basic VPC and subnet setup
* 10/25. develop-1 branch  
* 01/11.  develop-3 branch. Working terraform change. Fixes:
   * providers.tf uses internal aws profile (located at ~/.aws/credentials) 
   * Fixed database instance naming, mysql version and other typos.
   * ASG built to minimal 2 instances.
   * Launch configuration fixed.

# CHANGELOG
* 10/24. Initial release. Setup terraform credentials. Basic VPC and subnet setup
* 10/25. develop-1 branch  
* 01/11.  develop-3 branch. Working terraform change. Fixes:
   * providers.tf uses internal aws profile (located at ~/.aws/credentials) 
   * Fixed database instance naming, mysql version and other typos.
   * ASG built to minimal 2 instances.
   * Launch configuration fixed.
* 30/11. Finished app infrastructure. Currently on one big file with hardcoded values.
   * Load balancer works.
   * Load distributed between two instances.
   * bastion works
   * connection from app servers to database endpoint works.   
* 05/12. Adding modules 

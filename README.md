## Work In Progress
# Hashicorp Vault AWS KMS Auto Unseal - Terraform Deploy and Ansible Install and Configure
The goal of this repository is to demonstrate a workflow that uses terraform to deploy the infrastrcture and resources in AWS needed for Hashicorp's Vault. Ansible is then used to dynamically connect to the infrastructure and configure it for Vault auto unseal using AWS KMS. 

## Workflow 
 Using Ansible and the Terraform module the `deploy_infra.yml` playbook will plan and apply the terraform configuration. During this process, it will create the a file: `roles/install-vault/vars/main.yml` with the contents from `terraform/ansible-vars.tf` to auto-populate the KMS key id. The `install-vault.yml` playbook will use the `aws-ec2.yml` dynamic inventory to connect to the newly created EC2 instance based on tags. It will then install vault, drop the `vault.j2` template in as the `vault.hcl` config file, initialize, and auto-unseal it using AWS KMS. The recovery keys and root token will be placed onto the control node from which Ansible was run. 

## Instructions
1. Populate the '/terraform/ansible-vars.tf' with the variables needed to run the 'install-vault.yml'
2. Configure your control node with your AWS credentials for the AWS CLI
3. Run the 'deploy_infra.yml' playbook to deploy the infrastructure and populate the 'roles/instal-vault/var/' directory with the 'main.yml' created from Terraform. 'ansible-playbook -i aws_ec2.yml deploy_infra.yml'
4. Run the 'intsall-vault.yml' playbook to install and configure vault to auto unseal 'ansible-playbook -i aws_ec2.yml install-vault.yml'
5. In the browser, connect to the IP address of the instance on port 8200. The root token for logging in will be placed in the directory you specified in the ansible-vars.tf file as 'root_toke_dir_output'

## Variables 

| Variable | Description |
| --- | --- |
| ` vault_config_location_src` | The path of the vault.hcl template file to be installed with vault. Default =  *templates/vault.j2* |
| ` vault_config_location_dest` | The path to place the vault.hcl file on the remote host will be placed. Default = */etc/vault.d/vault.hcl* |
| ` root_token_dir_output` | The directory on the control node where the root token will be placed. |
| ` recovery_keys_dir_output` | The directory on the control node where the recovery keys will be placed. |
| ` tf_vault_kms_key` | Taken from the terraform state file once the *deploY_infra.yml* playbook is run |
| ` aws_secret_key` | Your AWS secret key. Will be placed into *vault.j2* template. |
| ` aws_access_key` | Your AWS access key. Will be placed into *vault.j2* template. |

## Additional Notes

- For home lab and development purposes onbly. This configuration is not 100% secure. DO NOT use this in production. TLS is disabled and it is not safe to keep the AWS secret key and access key in the `vault.hcl` configuration file. 

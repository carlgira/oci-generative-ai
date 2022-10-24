# OCI Stable difussion
Terraform script to start a stable-diffusion-model (v1.4) in compute instance using a nvidia GPU in OCI.

## Configuration

1. Follow the instructions to add the authentication to your tenant https://medium.com/@carlgira/install-oci-cli-and-configure-a-default-profile-802cc61abd4f.

2. Set two variables in your path. First the tenancy ocid and second the comparment ocid where the instance will be created.

```
export TF_VAR_tenancy_ocid='<tenancy-ocid>'
export TF_VAR_compartment_ocid='<comparment-ocid>'
```

3. Execute the script generate-keys.sh to generate private key to access the instance
```
sh generate-keys.sh
```

## Build
To build simply execute the next commands. 
```
terraform init
terraform plan
terraform apply
```

**After applying, the service will be ready in about 20 minutes** (it will install OS dependencies, nvidia drivers, clone stable-difussion-webui and download stable-diffusion-model)

## Test
To test the app it's necessary to create a ssh tunel to the port 7860 (the terraform output will give you the full command with the public IP)

```
ssh -i server.key -L 7860:localhost:7860 ubuntu@<instance-public-ip>
```

And after that open in a browser the url http://localhost:7860

## Clean
To delete the instance execute.
```
terraform destroy
```

## Stable diffusion model
Right now the terraform is using the stable-diffusion-1.4, because I got a direct link to download the model, if you want to use 1.5 or any more recent version, you got to go to https://huggingface.co/ singup, login, download the model manually and replace the file in the location /home/ubuntu/stable-diffusion-webui/model.ckpt.
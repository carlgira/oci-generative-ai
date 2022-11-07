# OCI Generative AI
Terraform script to start a **stable-diffusion, bloom and dreambooth** in compute instance using a nvidia GPU in OCI.

**Stable Diffusion** is a state of the art text-to-image model that generates images from text.

<img src="images/stable-diffusion-webui.jpg" />

**Bloom** is a open-science, open-access multilingual large language model (LLM), with 176 billion parameters, and was trained using the NVIDIA AI platform, with text generation in 46 languages

<img src="images/bloom-webui.jpg" />

**Dreambooth** allow to fine-tune a stable diffusion model with your own data.

<img src="images/dreambooth-webui.png" />

## Requirements

- Terraform
- ssh-keygen
- Huggingface account

## Configuration

1. Follow the instructions to add the authentication to your tenant https://medium.com/@carlgira/install-oci-cli-and-configure-a-default-profile-802cc61abd4f.

2. Clone this repository

3. Set three variables in your path. 
- The tenancy OCID, 
- The comparment OCID where the instance will be created.
- The "Region Identifier" of region of your tenancy. https://docs.oracle.com/en-us/iaas/Content/General/Concepts/regions.htm

```
export TF_VAR_tenancy_ocid='<tenancy-ocid>'
export TF_VAR_compartment_ocid='<comparment-ocid>'
export TF_VAR_region='<home-region>'
```

4. Execute the script generate-keys.sh to generate private key to access the instance
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

**After applying, the service will be ready in about 25 minutes** (it will install OS dependencies, nvidia drivers, and install stable-diffusion-web-ui, bloom-web-ui and dreambooth-webui.

## Post configuration
To test the app it's necessary to create a ssh tunel to the port 7860 (stable-diffusion-webui), 5000 (bloom) and 3000 (dreambooth).  (the output of the terraform script will give the ssh full command so you only need to copy and paste)

```
ssh -i server.key -L 7860:localhost:7860 -L 5000:localhost:5000 -L 3000:localhost:3000 ubuntu@<instance-public-ip>
```

The last step of the setup is to download the stable-diffusion model, for that, is necessary to have a huggingface account, create a token and accept to the conditions to use stable-diffusion.

1. Go to https://huggingface.co and create an account.
2. Go to https://huggingface.co/runwayml/stable-diffusion-v1-5 and accept the terms and conditions.
3. Create an "Access token".
    - Open your **Profile**
    - Go to **Settings**
    - Open **Access Token** and create a token with the role **"write"**

<img src="images/huggingface-token.png" />

Once the account is created, go to http://localhost:3000 (with the ssh tunnel opened) and put the credentials to download the stable diffusion model.

<img src="images/setup-sd-model.png" />

This is going to take 5 minutes, after that time, you are ready to go to test everything.

## Test
Make sure to have the ssh tunnel open to test the three apps.

### Bloom
Open the URL http://localhost:5000, in the text box, write wharever question come to mind, ask for a story or create a dialog.

### Stable diffusion
Open the URL http://localhost:7860, in the top text area write and idea, and stable diffusion will try to draw it on screen. 

Use https://lexica.art/ for examples of promts that you can use.

### Dreambooth
Open http://localhost:3000, it has several inputs, but most of them you can leave the default value and the page helps you on how to fill everything. 

Most of the time you only need two inputs; a unique label for the thing or person you want to fine tune the model, and a zip file with the set of images you are going to use for training.

Remember that those images must be of 512 x 512 (follow the instructions on the page to upload a correct format for the images)

## Clean
To delete the instance execute.
```
terraform destroy
```

## References
- The stable-diffusion-webui project https://github.com/AUTOMATIC1111/stable-diffusion-webui
- The bloom-webui https://github.com/carlgira/bloom-webui 
- The dreambooth-webui https://github.com/carlgira/dreambooth-webui
- DotCSV explanation https://www.youtube.com/watch?v=rgKBjRLvjLs

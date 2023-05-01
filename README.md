  <h3 align="center">VRAutomate</h3>

<!-- TABLE OF CONTENTS -->
<details open="open">
  <summary><h2 style="display: inline-block">Table of Contents</h2></summary>
  <ol>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#introduction">Introduction</a></li>
        <li><a href="#prerequisites">Prerequisites</a></li>
    </ul>
          <a href="#velociraptor">Velociraptor</a>
          <ul>
            <li><a href="#installation">Installation</a></li>
            <li><a href="#usage">Usage</a></li>
            <li><a href="#agent-upload">Agent Upload</a></li>
            <li><a href="#teardown">Teardown</a></li>
      </ul>
      <a href="#roadmap">Roadmap</a><p>
      <a href="#contributing">Contributing</a>
  </ol>
</details>

<!-- GETTING STARTED -->
## Getting Started

<!-- INTRODUCTION -->
### Introduction

This is a step-by-step guide to automate the deployment of Velociraptor in AWS. By the end of this process, you will have a fully-functional Velociraptor instance hosted in AWS and accessible by its public IP address over port 8889 with a self-signed certificate. As this setup uses basic auth instead of SSO/OAUTH (hard DNS requirement), it is protected by inbound rules on 8889 (GUI) and 22 (server) to just allow your public IP address, while port 8000 remains open to facilitate sensor check-in.

<!-- PREREQUISITES -->
### Prerequisites

Follow the guides to install requirements for Terraform, Ansible, and AWS:
1. Install Terraform for your environment: https://learn.hashicorp.com/tutorials/terraform/install-cli?in=terraform/aws-get-started#install-terraform
2. Once Terraform is setup, install AWSCLI for your environment: https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html
3. Install Ansible for your environment: https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#installing-ansible-on-specific-operating-systems 

    > <b>For Mac:</b>
      1. Open Terminal and install Brew: 
      ```sh 
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      ```
      3. Install Ansible using Brew: 
      ```sh
      brew install ansible
      ```

4. Sign into AWS and create an access key. You will need the key and secret handy: https://console.aws.amazon.com/iam/home?#/security_credentials
   1. Permissions needed in AWS for the user:
   ```
   ec2:DescribeInstances
   ec2:DescribeSecurityGroups
   ec2:DescribeImages
   ec2:DescribeKeyPairs
   ec2:CreateSecurityGroup
   ec2:CreateTags
   ec2:CreateKeyPair
   ec2:CreateSecurityGroupRule
   ec2:RunInstances
   ec2:TerminateInstances
   ec2:DeleteSecurityGroup
   ec2:DeleteKeyPair
   ```

5. Configure AWSCLI with your key and secret (ignore the other prompts):
   ```sh
   aws configure
   ```
   The configuration process stores your credentials in a file at ```~/.aws/credentials``` on MacOS and Linux, or ```%UserProfile%\.aws\credentials``` on Windows.

<!-- VELOCIRAPTOR -->
## Velociraptor

<!-- INSTALLATION -->
### Installation

1. Clone the repo
   ```sh
   git clone https://github.com/Seeps/VRAutomate.git
   ```
2. Give execute permissions to the Velociraptor script:
   ```sh
   chmod +x ./VRAutomate/velociraptor.sh
   ```
3. Execute the script:
   ```sh
   ./VRAutomate/velociraptor.sh
   ```

<!-- USAGE -->
## Usage

Once the 'velociraptor.sh' script executes, Terraform will ask for a case name. Enter the case name and type 'yes' when it goes through its run. The case name can be anything, but to make it simple, use a <a href=https://thestoryshack.com/tools/code-name-generator> code name </a> format as it will be used to tag infrastructure deployed by Terraform.

Terraform will hand off to Ansible which will deploy within the created instance. Take note of the ```aws_public_ip``` which will be needed to access the GUI. Upon completion, the script will SSH into the instance and the Velociraptor deployment menu will be displayed:

```sh
     ===VELOCIRAPTOR DEPLOYMENT=== 
    (1) Install Velociraptor Server
    (2) Upload Sensors
    (3) Add User
    (4) Reinstall Velociraptor
    (0) Exit
    'Choose an option:'
```

Select option 1 to start the install process: 

- What OS will the server be deployed on? > **Linux**  
- Path to the datastore directory. (/opt/velociraptor) > **(Hit Enter for default)**  
- Authentication > **Self Signed SSL** 
- What is the public DNS name of the Master Frontend > **localhost** 
- Enter the frontend port to listen on. > **(Hit Enter for default)** 
- Enter the port for the GUI to listen on. > **(Hit Enter for default)** 
- Are you using Google Domains DynDNS? > **(Hit Enter for default)** 
- GUI Username or email address to authorize (empty to end): > **Enter a username** (Ex. Seeps) 
- Enter a password: > **Enter a password** 
- Path to the logs directory. (/opt/velociraptor/logs) > **(Hit Enter for default)**  
- Where should i write the server config file? server.config.yaml > **(Hit Enter for default)** 
- Where should i write the client config file? (client.config.yaml) > **(Hit Enter for default)**  

Navigate to **https://your_aws_public_ip:8889** and login via basic auth. Upon successful authentication, the Velociraptor GUI will be presented. If you forget your AWS public IP, you can find it in the Terraform output, or in the last line of the ```velociraptor.sh``` script.

<!-- AGENT-UPLOAD -->
## Agent Upload
After step 1 is complete, select step 2 to upload the created sensors (Windows and Linux by default). In order to facilitate the upload, a Dropbox API token will be required:

   - Navigate to https://www.dropbox.com/developers > App Console > Create App
   - API = Scoped Access
   - Access = App Folder
   - Application Name = case-name
   - Click 'Create app'
   - Under the 'Permissions' tab select ```files.content.write```
   - Under the 'Settings' tab select ```Generate``` and copy the token
   - Enter this token for the step 2 prompt

Once the POST requests are complete, navigate to https://www.dropbox.com/home where the agents will appear under **[User Name] > Apps > [App-Name]**

These can be downloaded and installed, or shared. For easier install, use the ```nix_install.sh``` or ```win_install.bat``` script in the respective OS folder.

<!-- TEARDOWN -->
## Teardown
1. Give execute permissions to the Destroy script:
   ```sh
   chmod +x ./VRAutomate/destroy.sh
   ```
2. Execute the script:
   ```sh
   ./VRAutomate/destroy.sh
   ```
Enter the case name and type in 'yes' to destroy.

<!-- ROADMAP -->
## Roadmap

See the [open issues](https://github.com/Seeps/VRAutomate/issues) for a list of proposed features (and known issues).

<!-- CONTRIBUTING -->
## Contributing

Deepak (Seeps)

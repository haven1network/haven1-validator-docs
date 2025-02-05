![Cover](.github/cover.png)

# Haven1 Validator

Welcome to the Haven1 Validator repository! This repository serves as a guide for validators to run validators on Haven1.

This repository uses [Docker](https://docs.docker.com/) and [Docker Compose](https://docs.docker.com/compose/) as its base.
Here is the Installation Guide for [Docker](https://docs.docker.com/get-docker/) and [Docker Compose](https://docs.docker.com/compose/install/standalone/).

## Table of Contents

- [Summary](#summary)
- [Infra Setup](#infra-setup)
- [Setup Validator and Archive Instance](#setup-validator-and-archive-instance)
  - [Validator Hardware Requirements](#validator-hardware-requirements)
  - [Prerequisites](#prerequisites)
  - [Initial Setup and Key Generation for Validator Instance](#initial-setup-and-key-generation-for-validator-instance)
  - [Sharing Instance Information](#sharing-instance-information)
  - [Archive Hardware Requirements](#archive-hardware-requirements)
  - [Archive Prerequisites](#archive-prerequisites)
  - [Initial Setup and Key Generation for Archive Instance](#initial-setup-and-key-generation-for-archive-instance)
  - [Archive Sharing Instance Information](#archive-sharing-instance-information)
  - [Spin up the Node Validator Node](#spin-up-the-node-validator-node)
  - [Test that the node is validating as expected](#test-that-the-node-is-validating-as-expected)
  - [Spin up the Archive Node](#spin-up-the-archive-node)
  - [Test that the archive node is running as expected](#test-that-the-archive-node-is-running-as-expected)
- [Debugging Validator FAQ](#debugging-validator-faq)

## Summary

- This guide will walk you through the process of spinning up a Haven1 Validator and Archive Node on AWS.
- We will create all the infrastructure required to run the validator and archive node.
- We will install the required packages and setup the validator and archive node.
- Share the infroamtion with the haven1 team so we can add the nodes to the haven1 network.

## Infra Setup

1. Open the AWS CloudShell

2. Install Terraform

    ```bash
    sudo yum install -y yum-utils
    ```

    ```bash
    sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
    ```

    ```bash
    sudo yum -y install terraform
    ```

    ```bash
    terraform -help
    ```

3. Download the Terraform setup and unzip

    ```bash
    wget https://github.com/haven1network/haven1-validator-docs/releases/download/v1.0.0/validator.tgz
    ```

    ```bash
    tar -xvzf validator.tar.gz
    ```

    ```bash
    cd validator-terraform
    ```

4. Add your configs to the validator.tf

    ```bash
    module "validator" {
        source          = "./modules/validator"
        name            = "<YOUR ORGANISATION NAME HERE>"
        subnet_id       = "<YOUR SUBNET HERE>"
    }
    ```

5. Add your region to the provider.tf

    ```bash
    provider "aws" {
        region = "<YOUR REGION HERE>"
    }
    ```

6. Test your infra setup

    ```bash
    terraform init
    ```

    ```bash
    terraform plan
    ```

    **In case of any issues during step 6, please reach out to the [Haven1 Team](mailto:contact@haven1.org)**

7. Install the infra setup

    ```bash
    terraform apply
    ```

    **In case of any issues during step 7, please reach out to the [Haven1 Team](mailto:contact@haven1.org)**

## Setup Validator and Archive Instance

### Validator Hardware Requirements

AWS (t3.large)

- CPU: 2 vCPU cores
- Memory: 8 GB
- OS Storage: 100 GB
- Data Storage 150 GB

### Prerequisites

Get the following file from the [Haven1 Team](mailto:contact@haven1.org)

- genesis.base64 (base 64 encoded)
- link for cosigner image
- link for keygen image

Provide the address where you would like your rewards to be sent ([Haven1 Team](mailto:contact@haven1.org))

### Initial Setup and Key Generation for Validator Instance

Connect to the validator instance with EC2 Instance Connect and run the following commands

1. Install the following packages on your "validator" machine:

    ```bash
    sudo -s 
    ```

    ```bash
    sudo yum install -y git
    sudo yum install -y docker
    sudo mkdir -p /usr/local/lib /usr/local/lib/docker/cli-plugins
    sudo curl -SL https://github.com/docker/compose/releases/download/v2.28.1/docker-compose-linux-x86_64 -o /usr/local/lib/docker/cli-plugins/docker-compose
    sudo chmod +x /usr/local/lib/docker/cli-plugins/docker-compose
    sudo systemctl start docker
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
    source ~/.bashrc
    nvm install 20
    nvm use 20
    sudo groupadd docker
    sudo usermod -aG docker $USER

    mkdir -p data
    sudo mkfs -t xfs /dev/nvme1n1
    sudo mount /dev/nvme1n1 data
    UUID=$(sudo blkid -s UUID -o value /dev/nvme1n1)
    echo "UUID=$UUID  $(pwd)/data  xfs  defaults,nofail  0  2" >> /etc/fstab

    sudo fallocate -l 32G /swapfile
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile
    swapon --show
    echo "/swapfile   swap    swap    defaults        0   0" >> /etc/fstab
    ```

    Run the following code to verify if step 1 worked correctly

    ```bash
    sudo docker version
    docker compose version
    nvm --version
    node --version
    ````

    The output should look similar to this

    ```text
    Client:
    Version:           25.0.5
    API version:       1.44
    Go version:        go1.22.5
    Git commit:        5dc9bcc
    Built:             Wed Aug 21 00:00:00 2024
    OS/Arch:           linux/amd64
    Context:           default

    Server:
    Engine:
    Version:          25.0.6
    API version:      1.44 (minimum version 1.24)
    Go version:       go1.22.5
    Git commit:       b08a51f
    Built:            Wed Aug 21 00:00:00 2024
    OS/Arch:          linux/amd64
    Experimental:     false
    containerd:
    Version:          1.7.22
    GitCommit:        7f7fdf5fed64eb6a7caf99b3e12efcf9d60e311c
    runc:
    Version:          1.1.14
    GitCommit:        2c9f5602f0ba3d9da1c2596322dfc4e156844890
    docker-init:
    Version:          0.19.0
    GitCommit:        de40ad0
    Docker Compose version v2.28.1
    0.39.7
    v20.18.0
    ```

2. Clone the repository in a folder which is mounted to a storage which can be expanded as the Haven1 Network keeps adding blocks over time.

    ```bash
    git clone https://github.com/haven1network/validator.git
    ```

3. Create some directories for the new node in the validator directory:

    ```bash
    cd validator
    mkdir -p keystore
    ```

4. You need to change the `.env` file.

    | Variable    | Value                                 |
    | ----------- | ------------------------------------- |
    | HOSTNAME    | Your Organisation Name                |
    | IP          | Public IP (Elastic IP in case of AWS) |

5. Add KMS key to the validator env *If you have changed the name of the key, you need to change it in the query*

   You can run the following command if you are on AWS

   ```bash
    echo "KEY_0=kms:$(aws kms list-aliases  --query "Aliases[?AliasName=='alias/Haven1-Validator'].TargetKeyId" --output text )" >> .env
    ```

   If you are on GCP platform then replace the variables and run the following command

   ```bash
    echo "GCP_PROJECT_ID=$gcp_project_id" >> .env
    echo "GCP_LOCATION_ID=$gcp_location" >> .env
    echo "KEY_0=gcp:$key_ring_id:$key_id:$key_version" >> .env
    ```

   If you are on Azure platform then encode your key url with base64 then replace the variables below and run the following command (your key url should look like https://test-key-v-1.vault.azure.net/keys/test-key-1/82b723fcb1a24c3ba08e98a4a972847a)

   ```bash
   echo "KEY_0=azure:$base64_encoded_url" >> .env
   ```

6. Add your RPC urls in the command below, we support ETH, BASE and Haven1 Network at the moment.

    ```bash
    echo 'RPC={"8811": "https://rpc.haven1.org", "1":"<your ETH RPC endpoint>" ,"8453":"<your BASE RPC endpoint>"}' >> .env
    ```

7. Copy the string inside `genesis.base64` and run the following command

    ```bash
    sudo bash -c "echo \"<YOUR genesis.base64 STRING>\" | base64 --decode > ../data/genesis.json"
    ```

8. Download and load, keygen and cosigner image

    ```bash
    curl -L -o cosigner.tar.gz '<link to cosigner image>'
    curl -L -o keygen.tar.gz '<link to keygen image>'
    docker load -i cosigner.tar.gz
    docker load -i keygen.tar.gz
    ```

9. Check if image has been loaded properly. If output is empty contact the Haven1 team.

    ```bash
    docker images cosigner:private
    ```

10. Install and run the [Quorum Genesis Tool](https://www.npmjs.com/package/quorum-genesis-tool) to generate a new set of keys and node `(press y to continue)`:

    ```bash
    npx quorum-genesis-tool \
    --validators 1 \
    --members 0 \
    --bootnodes 0 \
    --outputPath artifacts
    ```

11. Copy the generated artifacts:

    ```bash
    cp artifacts/*/validator0/nodekey* keystore
    cp artifacts/*/validator0/account* keystore
    cp artifacts/*/validator0/address keystore
    rm -rf artifacts
    ```

### Sharing Instance Information

1. Share the following information from the validator instance with the Haven1 team.
    - address                  -> Used to validate blocks in the chain
    - nodekey.pub              -> Used to add the node to the network
    - `HOSTNAME` value used
    - public IP
    - cosigner public key      -> Used by the cosigner to sign critical network transactions
    - admin key                -> Used for safe admin trasactions regarding the network

    We will use this information to add the node to the network.

    You can use this command, copy the result and send it to us:
    *If you have changed the name of the key, you need to change it in the key-id*

    ```bash
    printf "\n\n\n\n Copy the following Data \n\n\n"
    for file in keystore/address keystore/nodekey.pub .env; do printf "%s: %s\n" "$file" "$(cat "$file")"; done
    printf "\n\n\n\n"
    ```

    Key generation

    The output of the following commands will give a line with the following format:

    ```bash
    2000-00-00 00:00:00 INFO MainKt - Cosigner Address: 0x<address> 
    ```

    ```bash
    docker run --env-file=.env keygen:latest
    ```

    ```bash
    2000-00-00 00:00:00 INFO MainKt - Cosigner Address: 0x<address> 
    ```

    Depending on the cloud provider you run the following commadn for the admin key:

    AWS:

    ```bash
    docker run \
        -e=KEY_0=kms:$(aws kms list-aliases  --query "Aliases[?AliasName=='alias/Haven1-Signing'].TargetKeyId" --output text ) \
        -e=AWS_CURRENT_REGION="YOUR REGION HERE¸" \
        keygen:latest
    ```

    GCP:

    ```bash
    docker run \
        -e=GCP_PROJECT_ID=$gcp_project_id \
        -e=GCP_LOCATION_ID=$gcp_location \
        -e=KEY_0=gcp:$key_ring_id:$key_id:$key_version \
        keygen:latest
    ```

    Azure:

    Encode your key url with base64 then replace the variables below and run the following command (your key url should look like <https://test-key-v-1.vault.azure.net/keys/test-key-1/82b723fcb1a24c3ba08e98a4a972847a>)

    ```bash
    docker run \
        -e=KEY_0=azure:$base64_encoded_url \
        keygen:latest
    ```

### Archive Hardware Requirements

AWS (t3.large)

- CPU: 2 vCPU cores
- Memory: 8 GB
- OS Storage: 100 GB
- Data Storage 150 GB

### Archive Prerequisites

- genesis.base64 (base 64 encoded)

### Initial Setup and Key Generation for Archive Instance

Connect to the archive instance with EC2 Instance Connect and run the following commands

1. Install the following packages on your "Archive" machine:

    ```bash
    sudo -s 
    ```

    ```bash
    sudo yum install -y git
    sudo yum install -y docker
    sudo mkdir -p /usr/local/lib /usr/local/lib/docker/cli-plugins
    sudo curl -SL https://github.com/docker/compose/releases/download/v2.28.1/docker-compose-linux-x86_64 -o /usr/local/lib/docker/cli-plugins/docker-compose
    sudo chmod +x /usr/local/lib/docker/cli-plugins/docker-compose
    sudo systemctl start docker
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
    source ~/.bashrc
    nvm install 20
    nvm use 20
    sudo groupadd docker
    sudo usermod -aG docker $USER

    mkdir -p data
    sudo mkfs -t xfs /dev/nvme1n1
    sudo mount /dev/nvme1n1 data
    UUID=$(sudo blkid -s UUID -o value /dev/nvme1n1)
    echo "UUID=$UUID  $(pwd)/data  xfs  defaults,nofail  0  2" >> /etc/fstab

    sudo fallocate -l 32G /swapfile
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile
    swapon --show
    echo "/swapfile   swap    swap    defaults        0   0" >> /etc/fstab
    ```

    Run the following code to verify if step 1 worked correctly

    ```bash
    sudo docker version
    docker compose version
    nvm --version
    node --version
    ````

    The output should look similar to this

    ```text
    Client:
    Version:           25.0.5
    API version:       1.44
    Go version:        go1.22.5
    Git commit:        5dc9bcc
    Built:             Wed Aug 21 00:00:00 2024
    OS/Arch:           linux/amd64
    Context:           default

    Server:
    Engine:
    Version:          25.0.6
    API version:      1.44 (minimum version 1.24)
    Go version:       go1.22.5
    Git commit:       b08a51f
    Built:            Wed Aug 21 00:00:00 2024
    OS/Arch:          linux/amd64
    Experimental:     false
    containerd:
    Version:          1.7.22
    GitCommit:        7f7fdf5fed64eb6a7caf99b3e12efcf9d60e311c
    runc:
    Version:          1.1.14
    GitCommit:        2c9f5602f0ba3d9da1c2596322dfc4e156844890
    docker-init:
    Version:          0.19.0
    GitCommit:        de40ad0
    Docker Compose version v2.28.1
    0.39.7
    v20.18.0
    ```

2. Clone the repository in a folder which is mounted to a storage which can be expanded as the Haven1 Network keeps adding blocks over time.

    ```bash
    git clone https://github.com/haven1network/validator.git
    ```

3. Create some directories for the new node in the validator directory:

    ```bash
    cd validator/archive-node
    mkdir -p keystore
    ```

4. You need to change the `.env` file.

    | Variable    | Value                                 |
    | ----------- | ------------------------------------- |
    | HOSTNAME    | Your Organisation Name-RPC            |
    | IP          | Public IP (Elastic IP in case of AWS) |

5. Copy the string inside `genesis.base64` and run the following command

    ```bash
    bash -c "echo \"<YOUR genesis.base64 STRING>\" | base64 --decode > ../../data/genesis.json"
    ```

6. Download and load, keygen and cosigner image

    ```bash
    curl -L -o keygen.tar.gz '<link to keygen image>'
    docker load -i keygen.tar.gz
    ```

7. Install and run the [Quorum Genesis Tool](https://www.npmjs.com/package/quorum-genesis-tool) to generate a new set of keys and node `(press y to continue)`:

    ```bash
    npx quorum-genesis-tool \
    --validators 1 \
    --members 0 \
    --bootnodes 0 \
    --outputPath artifacts
    ```

7. Copy the generated artifacts:

    ```bash
    cp artifacts/*/validator0/nodekey* keystore
    cp artifacts/*/validator0/account* keystore
    cp artifacts/*/validator0/address keystore
    rm -rf artifacts
    ```


### Archive Sharing Instance Information

1. Share the following information with the Haven1 team.
    - nodekey.pub              -> Used to add the node to the network
    - `HOSTNAME` value used
    - public IP
    - Signer Public Key        -> Used to sign network admin transactions

    You can use this command, copy the result and send it to us:

    ```bash
    printf "\n\n\n\n Copy the following Data \n\n\n"
    echo -n "AWS KMS Signer Public Key: $(aws kms get-public-key --key-id=alias/Haven1-Signing --query 'PublicKey' --output text)"
    for file in keystore/nodekey.pub .env; do printf "%s: %s\n" "$file" "$(cat "$file")"; done
    printf "\n\n\n\n"
    ```

2. Wait for the Haven1 team to reach out for the integration process to be completed.

### Spin up the Node Validator Node

- Once the integration is complete, you will receive the following files:
  - static-nodes.base64 (base 64 encoded)
  - permission-config.base64 (base 64 encoded)
- Place the files in the `data` folder and run the following command.

    ```bash
    cd /home/ec2-user/data

    sudo bash -c "echo \"<YOUR permission-config.base64 STRING>\" | base64 --decode > permission-config.json"
    sudo bash -c "echo \"<YOUR static-nodes.base64 STRING>\" | base64 --decode > static-nodes.json"

    sudo ln -s static-nodes.json permissioned-nodes.json
    ```

- You can spin up the node by running docker-compose in the validator folder

    ```bash
    cd /home/ec2-user/validator
    docker compose up -d
    ```

### Test that the node is validating as expected

- Attach a `geth` console to the node:

    ```bash
    docker compose exec -it node geth attach /data/geth.ipc
    ```

- Verify Syncing Status. It should return `false` once the syncing is completed

    ```javascript
    eth.syncing
    ```

- Once syncing is completed. Verify Mining Status. It should return true if mining is enabled on your validator.

    ```javascript
    eth.mining
    ```

- The peer count should be equal to the total number of nodes minus one (representing the node itself).

    ```javascript
    admin.peers.length
    ```

- Verify Block Number. To ensure that new blocks are being added to the blockchain, check the current block number with the following command:

    ```javascript
    eth.blockNumber
    ```

This number should increase over time as new blocks are added.

- If all tests generate positive results, we have successfully added a new RPC node.

- Exit the Geth console

    ```javascript
    exit
    ```

### Spin up the Archive Node

- Once the integration is complete, you will receive the following files:
  - static-nodes.json
  - permission-config.json
- Place the files in the `data` folder and run the following command.

    ```bash
    cd /home/ec2-user/data
    sudo ln -s static-nodes.json permissioned-nodes.json
    ```

- You can spin up the node by running docker-compose in the validator folder

    ```bash
    cd /home/ec2-user/validator/archive-node

    docker compose up -d
    ```

### Test that the archive node is running as expected

- Attach a `geth` console to the node:

    ```bash
    docker compose exec -it node geth attach /data/geth.ipc
    ```

- Verify Syncing Status. It should return `false` once the syncing is completed

    ```javascript
    eth.syncing
    ```

- Once syncing is completed. Verify Mining Status. It should return false

    ```javascript
    eth.mining
    ```

The peer count should be equal to the total number of nodes minus one (representing the node itself).

- Verify Block Number. To ensure that new blocks are being added to the blockchain, check the current block number with the following command:

    ```javascript
    eth.blockNumber
    ```

This number should increase over time as new blocks are added.

- If all tests generate positive results, we have successfully added a new RPC node.

- Exit the Geth console

    ```javascript
    exit
    ```

## Debugging Validator FAQ

*Problem:* Geth Connection Refused running `attach` command

*Possible Solution:*

- The container might be in the process of starting up.
- If the container is running then check the logs if there is any specific issue.
- If no issue then wait 10 mins for the container to spin up.
- Else turn off your container
- Remove geth.ipc if you still have a stray `geth.ipc` remaining, then remove it.
- Start the container again and wait for it to spin up.

    ```bash
    docker-compose down
    rm -f data/geth.ipc
    docker-compose up -d
    ```

*Problem:* No file geth.ipc

*Possible Solution:*

- Check if container is running.
- If the container is running then check the logs if there is any specific issue.
- If no issue then wait 10 mins for the container to spin up.

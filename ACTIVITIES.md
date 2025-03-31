# Validator Activities

## Approve a new validator

- Carry out this activity when the Haven1 Team instructs you.
- We will provide an updated `static-nodes.json` and the following information about the new validator.
  - address
  - accountAddress
  - encodeID

1. Update your `data/static-nodes.json` file with the new one provided by the Haven1 Team.
2. Attach a `geth` console to the node:

    ```bash
    docker exec -it validator-node-1 geth attach /data/geth.ipc
    ```

3. Propose the new validator using the command `istanbul.propose("0x<address>", true)`. Replace `<address>` with the address of the new validator candidate node:

    ```javascript
    istanbul.propose("0x<address>", true);
    
    ```

4. To complete the node addition, you will need to use your SAFE admin account to approve the enhanced permissioning change as explained  [here](#approving-a-change-in-enhanced-permissioning)

5. Add this validator to all bridge safes as well in a similar manner to the above steps.

## Approving a change in enhanced permissioning

1. The proposer or the Haven1 team will contact you when a change is proposed.
2. Login into your validator safe account.
3. Go to transaction ![View Transaction](https://github.com/user-attachments/assets/d3d80357-71a9-4069-aa7a-e51552612444)
4. You should see the pending transaction ![Pending Transaction](https://github.com/user-attachments/assets/a50bc501-3bc6-4a44-ae2c-d49d1c9e261a)
5. Click on the transaction to see the pending details
6. Verify if the transaction is legitimate, if not then `Reject` the transaction.
7. Click on `Confirm` if the transaction appears to be legitimate.
8. Click on `Execute` to do the transaction right away. This only appears if the required signer's threshold has already been reached. If the required signers have not been reached, you can click on `Sign` to approve the transaction. ![Execute and Sign](https://github.com/user-attachments/assets/474f4f4f-44f2-46ee-8d63-8170f84b0408)

## Proposing a change in enhanced permissioning

1. Login into your validator safe account.
2. Click on `New transaction`  ![New Transaction](https://github.com/user-attachments/assets/5eed8835-2932-4ce4-9757-f372b7c9fd57)
3. Click on `Transaction Builder` ![Transaction Builder](https://github.com/user-attachments/assets/83043f04-3d01-43d7-b2e4-89f062004ae8)
4. Paste in the required ABI ![ABI](https://github.com/user-attachments/assets/07bbcb87-c55b-4936-8820-63502e482354)
5. Input the values of the method call.
6. Click on `Add transaction`.
7. Click on `Create Batch`.
8. Click on `Send Batch`.
9. Click on `Sign`.
10. Sign the transaction using Metamask or your wallet of choice.
11. Wait for other parties to approve and send the final transaction.

## Config changes proposal

Reach out to the Haven1 team for guidance on how to create a configuration change proposal.

## How to revert the network

- Carry out this activity when the Haven1 Team instructs you.
- We will provide you with the following information.
  - Reason to fork
  - `blockNumber` from which to fork in hexadecimal format

1. Disconnect your validator from the other nodes in the network.
2. Connect to the validator node:

    ```bash
    docker compose exec -it node geth attach /data/geth.ipc
    ```

3. Reset the head of the validator. Replace `<blockNumber>` with the block number from which to fork in hexadecimal format.

    ```javascript
    debug.setHead("0x<blockNumber>")
    ```

4. Exit the console:

    ```javascript
    exit
    ```

5. Please update the Haven1 team.

6. Wait for the haven1 team to contact you before connecting to other nodes.

## Remove a validator

- We will provide an updated `static-nodes.json` and the following information about the new validator.
  - address
  - accountAddress
  - encodeID

1. Update your `data/static-nodes.json` file with the new one provided by the Haven1 Team.

2. istanbul.propose is the voting process for validators

    ```js
    istanbul.propose("<node address>", false);
    ```

3. Attach a `geth` console to the node:

    ```bash
    docker exec -it validator-node-1 geth attach /data/geth.ipc
    ```

4. Propose the new removing the validator using the command `istanbul.propose("0x<address>", false)`. Replace `<address>` with the address of the new validator candidate node:

5. Once enough proposals happen (> 50%) istanbul.getValidators() will remove the validator (this will not create a classic transaction in the blockchain)

6. Run the following command equivalent in the safe wallet or approve the enhanced permissioning change as explained [here](#approving-a-change-in-enhanced-permissioning) if not the first validator

    ```js
    quorumPermission.updateNodeStatus(
      "HAVEN1",
      "enode://<Node key pub key>@<IP>:30303?discport=0&raftport=53000",
      3,
      { from: eth.accounts[0] },
    );
    ```

7. Remove the validator from the safe account

## Generate Public Keys

Carry out this activity when you need to know the public key of the cosigner and the admin key.

You will need the following from the haven1 team:

- link for keygen image

You can perform the following steps in the validator instance:

  Load the keygen image:

  ```bash
  curl -L -o keygen.tar.gz '<link to keygen image>'
  docker load -i keygen.tar.gz
  ```

  The output of the commands below will give an output with the following format:

  ```bash
  2000-00-00 00:00:00 INFO MainKt - Cosigner Address: 0x<address> 
  ```

  Cosigner Key:

  ```bash
  docker run --env-file=.env keygen:latest
  ```

  Admin Key:

  Depending on the cloud provider you run the following command for the admin key:

  AWS:

  ```bash
  docker run \
      -e=KEY_0=kms:$(aws kms list-aliases  --query "Aliases[?AliasName=='alias/Haven1-Signing'].TargetKeyId" --output text ) \
      -e=AWS_CURRENT_REGION=<YOUR REGION HERE> \
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

## Generate Cosigner .env

- Carry out this activity when the Haven1 Team instructs you or when you need to update the .env file.
- We will provide you with the following information.
  - any additional information required for the .env file.

Create a new file .env.new with the values of <> replaced with the appropriate values given by the instructions below.

  ```env
  HOSTNAME=<Your Organisation Name-RPC>
  VERBOSITY=3
  NETWORKID=8811
  IP=<Public IP (Elastic IP in case of AWS)>
  HAVEN1_CHAINID=8811
  BRIDGE_CONTROLLER_ADDRESS=0x74dfadc72C94E144ed56E7E252021FC0F1217Ce9
  BRIDGE_RELAYER_ADDRESS=0xA04Fea11cf58d420687dD12aA5AcDFD70b872545
  SAFE_URL={"8811":"https://safe-transaction.haven1.org/","1":"https://safe-transaction-mainnet.safe.global/","8453":"https://safe-transaction-base.safe.global/"}
  SAFE_ADDRESS={"1:8811":"0x25AF0c735a659a34DeCA103e00B92Ef8450383a5","8811:1":"0x2C0C9a76d8061Cf35DB7f7c2a53085025aFa3057","8811:8453":"0x2C0C9a76d8061Cf35DB7f7c2a53085025aFa3057","8453:8811":"0x41FFd702c689B9d2057d58B99F59568cCe14aa88","8811:8811":"0x207CA9C87c4C1659DCb49B0143Bfeffd9711300a"}
  BLOCK_CONFIRMATION={"8811":"2","1":"-1","8453":"-1"}
  RPC={"8811": "https://rpc.haven1.org", "1":"<your ETH RPC endpoint>" ,"8453":"<your BASE RPC endpoint>"}
  ```

Once the `.env.new` file is generated add the key details depending on the cloud provider you run to the file.

AWS:

  ```env
  KEY_0=kms:OUTPUT of the command `aws kms list-aliases  --query "Aliases[?AliasName=='alias/Haven1-Signing'].TargetKeyId" --output text`
  AWS_CURRENT_REGION=<YOUR REGION HERE>
  ```

GCP:

  ```env
  GCP_PROJECT_ID=<YOUR PROJECT ID HERE>
  GCP_LOCATION_ID=<YOUR LOCATION ID HERE>
  KEY_0=<gcp:KEY_RING_ID:KEY_ID:KEY_VERSION>
  ```

Azure:

Encode your key url with base64 then replace the variables below and run the following command (your key url should look like <https://test-key-v-1.vault.azure.net/keys/test-key-1/82b723fcb1a24c3ba08e98a4a972847a>)

  ```env
  KEY_0=azure:$base64_encoded_url
  ```

then you can move the existing .env file to .env.bak and rename the .env.new to .env

```bash
mv .env .env.bak
mv .env.new .env
```

Run the container with the new .env file

```bash
docker-compose down cosigner
docker-compose up -d cosigner
```

## Monitoring Node

If you want to monitor your node using your existing monitoring tools you can use the following link for monitoring information.
https://docs.goquorum.consensys.io/configure-and-manage/monitor/metrics

## Reset Node Data

- Carry out this activity when the Haven1 Team instructs you or when you need to reset a corrupted node.

Assume the sudo user

1. Log into the instance.
2. Assume the sudo user:

  ```bash
  sudo su
  ```

3. Turn the node off:

  for validator node:

  ```bash
  cd /home/ec2-user/validator
  docker compose down
  ```

  for archive node:

  ```bash
  cd /home/ec2-user/validator/archive-node
  docker compose down
  ```

4. Clean the geth in data directory:

  ```bash
  cd /home/ec2-user/data
  rm -rf geth*
  ```

5. Restart the node:

  for validator node:

  ```bash
  cd /home/ec2-user/validator
  docker compose up -d
  ```

  for archive node:

  ```bash
  cd /home/ec2-user/validator/archive-node
  docker compose up -d
  ```

## Update Node and Cosigner Images

- Carry out this activity when the Haven1 Team instructs you.

1. Log into the instance.
2. Assume the sudo user:

  ```bash
  sudo su
  ```

3. Git pull the latest changes:

  ```bash
  cd /home/ec2-user/validator
  git pull 
  ```

4. Start the node:

  for validator node and cosigner:

  ```bash
  cd /home/ec2-user/validator
  docker compose up -d
  ```

  for archive node:

  ```bash
  cd /home/ec2-user/validator/archive-node
  docker compose up -d
  ```

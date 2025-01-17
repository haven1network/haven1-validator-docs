# Validator Activities

## Approve a new validator

- Carry out this activity when the Haven1 Team instructs you.
- We will provide you with an updated `static-nodes.json` and the following information of the new validator.
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

4. In order to complete the node addition, you will need to use your SAFE admin account to approve the enhanced permissioning change as explained [here](#approving-a-change-in-enhanced-permissioning)

5. Add this validators to all bridge safes as well in a similar manner to the above steps.

## Approving a change in enhanced permissioning

1. The proposer or the Haven1 team will reach out to you when there's a change that is being proposed.
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
2. Conenct to the validator node:

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

6. Wait for the haven1 team to contact you before conneting to other nodes.

## Remove a validator

- We will provide you with an updated `static-nodes.json` and the following information of the new validator.
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

6. Run the following command equivalant in the safe wallet or approve the enhanced permissioning change as explained [here](#approving-a-change-in-enhanced-permissioning) if not the first validator

    ```js
    quorumPermission.updateNodeStatus(
      "HAVEN1",
      "enode://<Node key pub key>@<IP>:30303?discport=0&raftport=53000",
      3,
      { from: eth.accounts[0] },
    );
    ```

7. Remove the validator from the safe account

geth \
--networkid ${NETWORKID} \
--unlock $(cat /keystore/accountAddress) \
--allow-insecure-unlock \
--password /keystore/accountPassword \
--keystore /keystore \
--permissioned \
--mine \
--emitcheckpoints \
--miner.threads 1 \
--verbosity "${VERBOSITY}" \
--datadir /data \
--syncmode full \
--port 30303 \
--nousb \
--identity ${HOSTNAME} \
--nodekey /keystore/nodekey \
--nodiscover \
--metrics \
--pprof \
--pprof.addr 0.0.0.0 \
--pprof.port 9545 \
--istanbul.blockperiod 5 \
--istanbul.requesttimeout 10000 \
--http \
--http.addr 0.0.0.0 \
--http.port 8545 \
--http.corsdomain '*' \
--http.vhosts '*' \
--http.api admin,db,eth,debug,miner,net,shh,txpool,personal,web3,quorum,qbft \
--ws \
--ws.addr 0.0.0.0 \
--ws.port 8546 \
--ws.origins '*' \
--ws.rpcprefix '/' \
--ws.api admin,db,eth,debug,miner,net,shh,txpool,personal,web3,quorum,qbft init /data/genesis.json

exec geth \
--nat extip:${IP} \
--networkid ${NETWORKID} \
--password /keystore/accountPassword \
--keystore /keystore \
--permissioned \
--emitcheckpoints \
--verbosity ${VERBOSITY} \
--datadir /data \
--syncmode full \
--gcmode archive \
--port 30303 \
--nousb \
--identity ${HOSTNAME} \
--nodekey /keystore/nodekey \
--nodiscover \
--metrics \
--pprof \
--pprof.addr 0.0.0.0 \
--pprof.port 9545 \
--istanbul.blockperiod 5 \
--istanbul.requesttimeout 10000 \
--http \
--http.addr 0.0.0.0 \
--http.port 8545 \
--http.corsdomain '*' \
--http.vhosts '*' \
--http.api admin,db,eth,debug,miner,net,shh,txpool,personal,web3,quorum,qbft \
--ws \
--ws.addr 0.0.0.0 \
--ws.port 8546 \
--ws.origins '*' \
--ws.rpcprefix '/' \
--ws.api admin,db,eth,debug,miner,net,shh,txpool,personal,web3,quorum,qbft
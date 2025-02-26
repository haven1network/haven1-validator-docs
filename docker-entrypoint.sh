geth \
--datadir /data \
init /data/genesis.json

exec geth \
--nat extip:${IP} \
--networkid ${NETWORKID} \
--keystore /keystore \
--permissioned \
--mine \
--emitcheckpoints \
--miner.threads 1 \
--verbosity ${VERBOSITY} \
--datadir /data \
--syncmode snap \
--port 30303 \
--nousb \
--identity ${HOSTNAME}-validator \
--nodekey /keystore/nodekey \
--nodiscover \
--metrics \
--pprof \
--pprof.addr 127.0.0.1 \
--pprof.port 9545 \
--istanbul.blockperiod 5 \
--istanbul.requesttimeout 10000

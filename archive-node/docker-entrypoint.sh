geth \
--datadir /data \
init /data/genesis.json

exec geth \
--nat extip:${IP} \
--networkid ${NETWORKID} \
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
--pprof.addr 127.0.0.1 \
--pprof.port 9545 \
--istanbul.blockperiod 5 \
--istanbul.requesttimeout 10000
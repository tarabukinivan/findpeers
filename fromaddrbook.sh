#!/bin/bash

# =-=-=-=-=-=-=-=-=-=-=-=-=-Variable zone-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
CONFIG=$HOME/$CONFIG/config # Example /home/haqq-2/.haqqd/config
CHAIN=$CHAIN # Example haqq_54211-3
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

function check {
p2p=($(cat $CONFIG/addrbook.json 2>&1 | jq .addrs | jq .[$i].addr | jq -r '.ip, .port'))
nc -4zw1 "${p2p[0]}" "$((${p2p[1]}+1))" && state="opened" || state="closed"
if [[ $state == opened ]]; then
  duplicate=$(grep ${p2p[0]} ~/rpc.txt)
if [ -z "${duplicate}" ]; then
  data=($(curl -s ${p2p[0]}:$((${p2p[1]}+1))/status | jq .result | jq .node_info,.sync_info | jq -r '.moniker, .id, .network, .other.tx_index, .latest_block_height' |  grep -v null))
   if [ ! -z "${data[0]}" ] && [ ! -z "${data[1]}" ] && [[ "$CHAIN" == "${data[2]}" ]]; then
    echo -e ""MONIKER: "${data[0]} "INDEXER: "${data[3]} "HEIGHT: "${data[4]}\nRPC=${p2p[0]}:$((${p2p[1]}+1))" >> ~/rpc.txt
    echo ${data[1]}@${p2p[0]}:${p2p[1]} >>  ~/peers.txt
   fi
fi
fi
}
rm -rf ~/peers.txt
rm -rf ~/rpc.txt
touch ~/rpc.txt
touch ~/peers.txt
echo -e ""Last update: "$(date -u)\n "  >>  ~/rpc.txt
n=$(cat $CONFIG/addrbook.json 2>&1 | jq -r .addrs | grep -o -i addr | wc -l)
echo "Найдено $n адресов, проверяем открытые RPC"
for ((i = 0; i < n; i++))
do
printf ' Проверено: %s\r' "$i"
check&
done

sleep 5
echo "Найдено $(cat ~/peers.txt | wc -l) открытых RPC, результат сохранен ~/rpc.txt"
echo 'peers="'$(echo $(cat ~/peers.txt) | tr ' ' ',')'"' >> ~/rpc.txt
rm -rf ~/peers.txt
cat ~/rpc.txt

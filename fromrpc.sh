SNAP_RPC=<RPC_NODE>
n_peers=`curl -s $SNAP_RPC/net_info? | jq -r .result.n_peers`
let n_peers="$n_peers"-1
RPC="$SNAP_RPC"
echo -n "$RPC," >> /root/RPC.txt
PEER=`curl -s  $SNAP_RPC/status? | jq -r .result.node_info.listen_addr`
id=`curl -s  $SNAP_RPC/status? | jq -r .result.node_info.id`
echo -n "$id@$PEER," >> /root/PEER.txt
echo $id@$PEER
p=0
count=0
echo "Search peers..."
 while [[ "$p" -le  "$n_peers" ]] && [[ "$count" -le 20 ]]
 do
      PEER=`curl -s  $SNAP_RPC/net_info? | jq -r .result.peers["$p"].node_info.listen_addr`
    if [[ ! "$PEER" =~ "tcp" ]] 
 then
        id=`curl -s  $SNAP_RPC/net_info? | jq -r .result.peers["$p"].node_info.id`
           echo -n "$id@$PEER," >> /root/PEER.txt
            echo $id@$PEER
            rm /root/addr.tmp
            echo $PEER | sed 's/:/ /g' > /root/addr.tmp
            ADDRESS=(`cat /root/addr.tmp`)
            ADDRESS=`echo ${ADDRESS[0]}`
            PORT=(`cat /root/addr.tmp`)
            PORT=`echo ${PORT[1]}`
            let PORT=$PORT+1
            RPC=`echo $ADDRESS:$PORT`
            let count="$count"+1
            if [[ `curl -s http://$RPC/abci_info? --connect-timeout 5 | jq -r .result.response.last_block_height` -gt 0 ]]
            then
                echo "$RPC"
                echo -n "$RPC," >> /root/RPC.txt
                RPC=0
            fi
            RPC=0
       fi
    p="$p"+1
done
echo "Search peers is complete!"
PEER=`cat /root/PEER.txt | sed 's/,$//'`
RPC=`cat /root/RPC.txt | sed 's/,$//'`

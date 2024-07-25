# Ext IP local access

## Description
This app can be used for external access local PC http ports

## How to use
1. Create a ZeroTier network. Probably you wanna restrict an inter-network cross-client access ([docs](https://docs.zerotier.com/faq-rules/#client-isolation))
2. Setup this app to be a zerotier network gateway:
    1. Generate identity via:
    ```bash
   zerotier-idtool generate gateway.secret gateway.public 
    ```
    2. Manualy add member with id from public or secret file (id is the same in both files), example
    ```bash
    $ zerotier-idtool generate gateway.secret gateway.public
    gateway.secret written
    gateway.public written
    $ cat gateway.public 
    4a7f049cf1:0:a4ee328392ccaf0c22900606aeb20a9cdc76716da70[OMMITED]
    ```
    `4a7f049cf1` will be host ID in this case
    3. Assign an IP address to this host via admin console
3. Create a config file, example:
```json
{
    "zerotier_network": "ZeroTier network ID",
    "zerotier_public_key": "gateway.public output from exaple above",
    "zerotier_private_key": "gateway.secret output from exaple above",
    "hostname_base": "set a base hostname, eq: 'ext.example.com'",
    "users": [  # put all users here
        {
            "hostname": "prefix to base hostname, eq: 'user1'. It will produce 'user1.ext.example.com' address",
            "ip": "user ZeroTier IP address for proxy external traffic to. Eq: 10.10.10.2 for 10.10.10.0/24 net"
        }
    ]
}
```

4. Start a container with the app
```bash
docker run \
    --name ext-ip \  # optional
    -v $(pwd)/config.json:/etc/app/config.json \
    --cap-add NET_ADMIN \
    --device /dev/net/tun \
    flipperdevices/ext-ip-local-port:0.0.1  # this should be a latest release from github
```

For Kubernetes use you also need to add capabilities [docs](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/)

5. Join a network from clients, also set a coresponding IP's

In example above URL `user1.ext.example.com` will point to the `10.10.10.2` address.

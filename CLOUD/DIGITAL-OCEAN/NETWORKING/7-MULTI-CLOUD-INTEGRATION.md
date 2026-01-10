# DigitalOcean Multi-Cloud Integration

## Overview

Multi-cloud integration enables you to connect DigitalOcean resources with other cloud providers (AWS, Azure, GCP) and on-premises infrastructure. This creates hybrid and multi-cloud architectures for improved redundancy, disaster recovery, and workload distribution.

## Key Features

- **VPN Connectivity**: Site-to-site VPN tunnels
- **Hybrid Cloud**: Connect cloud and on-premises
- **Multi-Cloud**: Integrate multiple cloud providers
- **Private Connectivity**: Secure encrypted tunnels
- **Flexible Routing**: Custom routing between networks
- **Cost-Effective**: Use existing infrastructure
- **High Availability**: Redundant connections
- **Scalable**: Grow across multiple clouds

## Multi-Cloud Architecture Patterns

### 1. Hybrid Cloud Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    On-Premises Datacenter                    │
│                                                              │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  Corporate Network (192.168.0.0/16)                    │ │
│  │                                                         │ │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐            │ │
│  │  │ Active   │  │ Legacy   │  │ Internal │            │ │
│  │  │Directory │  │ Systems  │  │ Services │            │ │
│  │  └──────────┘  └──────────┘  └──────────┘            │ │
│  │                                                         │ │
│  │  ┌──────────────────────────────────────┐             │ │
│  │  │      VPN Gateway (pfSense)           │             │ │
│  │  │      Public IP: 198.51.100.10        │             │ │
│  │  └──────────────┬───────────────────────┘             │ │
│  └─────────────────┼─────────────────────────────────────┘ │
└────────────────────┼─────────────────────────────────────────┘
                     │
                     │ IPsec VPN Tunnel
                     │ (Encrypted)
                     │
┌────────────────────▼─────────────────────────────────────────┐
│              DigitalOcean Cloud (NYC3)                        │
│                                                              │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  VPC: 10.10.0.0/16                                     │ │
│  │                                                         │ │
│  │  ┌──────────────────────────────────────┐             │ │
│  │  │  VPN Gateway Droplet                 │             │ │
│  │  │  Private IP: 10.10.1.5               │             │ │
│  │  │  Public IP: 203.0.113.10             │             │ │
│  │  └──────────────┬───────────────────────┘             │ │
│  │                 │                                       │ │
│  │  ┌──────────────┼───────────────────────────────────┐ │ │
│  │  │              │  Cloud Resources                   │ │ │
│  │  │  ┌───────────▼──────┐  ┌──────────────────────┐  │ │ │
│  │  │  │ Web Applications │  │ Cloud-Native Services│  │ │ │
│  │  │  └──────────────────┘  └──────────────────────┘  │ │ │
│  │  └──────────────────────────────────────────────────┘ │ │
│  └─────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘

Traffic Flow:
On-Premises ←→ VPN Tunnel ←→ DigitalOcean
(192.168.0.0/16)           (10.10.0.0/16)
```

### 2. Multi-Cloud Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      AWS (us-east-1)                         │
│  VPC: 10.20.0.0/16                                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │   EC2        │  │   RDS        │  │   S3         │     │
│  │   Instances  │  │   Database   │  │   Storage    │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
│         │                                                    │
│  ┌──────▼──────────────────────────┐                       │
│  │  VPN Gateway (AWS VGW)          │                       │
│  │  Public IP: 52.1.2.3            │                       │
│  └──────────────┬──────────────────┘                       │
└─────────────────┼──────────────────────────────────────────┘
                  │
                  │ VPN Tunnel 1
                  │
┌─────────────────▼──────────────────────────────────────────┐
│              DigitalOcean (NYC3)                            │
│  VPC: 10.10.0.0/16                                         │
│  ┌──────────────────────────────────────┐                 │
│  │  VPN Gateway Droplet (Hub)           │                 │
│  │  Public IP: 203.0.113.10             │                 │
│  └──────────────┬───────────────────────┘                 │
│                 │                                           │
│  ┌──────────────┼───────────────────────────────────────┐ │
│  │  ┌───────────▼──────┐  ┌──────────────────────┐     │ │
│  │  │ Load Balancers   │  │ Kubernetes Cluster   │     │ │
│  │  └──────────────────┘  └──────────────────────┘     │ │
│  └──────────────────────────────────────────────────────┘ │
└─────────────────┬──────────────────────────────────────────┘
                  │
                  │ VPN Tunnel 2
                  │
┌─────────────────▼──────────────────────────────────────────┐
│                   Google Cloud (us-central1)                │
│  VPC: 10.30.0.0/16                                         │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐    │
│  │   GCE        │  │   Cloud SQL  │  │   GCS        │    │
│  │   Instances  │  │   Database   │  │   Storage    │    │
│  └──────────────┘  └──────────────┘  └──────────────┘    │
│         │                                                   │
│  ┌──────▼──────────────────────────┐                      │
│  │  VPN Gateway (GCP)               │                      │
│  │  Public IP: 35.1.2.3             │                      │
│  └──────────────────────────────────┘                      │
└─────────────────────────────────────────────────────────────┘

DigitalOcean acts as hub connecting AWS and GCP
```

### 3. Disaster Recovery Architecture

```
┌─────────────────────────────────────────────────────────────┐
│              Primary Region: DigitalOcean NYC3               │
│                                                              │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  Production Environment                                 │ │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐            │ │
│  │  │   Web    │  │   App    │  │ Database │            │ │
│  │  │  Tier    │  │  Tier    │  │  Master  │            │ │
│  │  └──────────┘  └──────────┘  └────┬─────┘            │ │
│  │                                    │                    │ │
│  │                              Replication                │ │
│  └────────────────────────────────────┼──────────────────┘ │
└────────────────────────────────────────┼────────────────────┘
                                         │
                                    VPN Tunnel
                                         │
┌────────────────────────────────────────▼────────────────────┐
│              DR Region: AWS us-west-2                        │
│                                                              │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  Disaster Recovery Environment                          │ │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐            │ │
│  │  │   Web    │  │   App    │  │ Database │            │ │
│  │  │  Tier    │  │  Tier    │  │ Replica  │            │ │
│  │  │(Standby) │  │(Standby) │  │(Standby) │            │ │
│  │  └──────────┘  └──────────┘  └──────────┘            │ │
│  └────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘

Failover: DNS update points to AWS in case of DigitalOcean outage
```

## VPN Technologies

### 1. IPsec VPN

**Most common for site-to-site connections**

```
Features:
├─> Industry standard
├─> Strong encryption (AES-256)
├─> Authentication (PSK or certificates)
├─> Supported by all major vendors
└─> Good performance

Protocols:
├─> IKEv1 / IKEv2 (Key exchange)
├─> ESP (Encryption)
└─> AH (Authentication)
```

### 2. WireGuard VPN

**Modern, lightweight VPN**

```
Features:
├─> Simple configuration
├─> High performance
├─> Modern cryptography
├─> Small codebase
└─> Cross-platform

Benefits:
├─> Faster than IPsec
├─> Easier to configure
├─> Better for cloud-to-cloud
└─> Active development
```

### 3. OpenVPN

**Flexible SSL/TLS VPN**

```
Features:
├─> SSL/TLS based
├─> Highly configurable
├─> Works through NAT
├─> Cross-platform
└─> Open source

Use Cases:
├─> Remote access
├─> Site-to-site
├─> Complex routing
└─> Firewall traversal
```

## Setting Up VPN Connections

### IPsec VPN with StrongSwan

#### On DigitalOcean Droplet

```bash
# 1. Create VPN Gateway Droplet
doctl compute droplet create vpn-gateway \
  --region nyc3 \
  --size s-2vcpu-2gb \
  --image ubuntu-22-04-x64 \
  --vpc-uuid vpc-uuid

# 2. Install StrongSwan
sudo apt-get update
sudo apt-get install -y strongswan strongswan-pki

# 3. Configure IPsec (/etc/ipsec.conf)
cat << 'EOF' | sudo tee /etc/ipsec.conf
config setup
    charondebug="ike 2, knl 2, cfg 2"
    uniqueids=no

conn aws-to-digitalocean
    type=tunnel
    auto=start
    keyexchange=ikev2
    authby=secret
    left=%any
    leftid=203.0.113.10
    leftsubnet=10.10.0.0/16
    right=52.1.2.3
    rightid=52.1.2.3
    rightsubnet=10.20.0.0/16
    ike=aes256-sha2_256-modp2048!
    esp=aes256-sha2_256!
    keyingtries=%forever
    dpdaction=restart
    dpddelay=30s
    dpdtimeout=120s
EOF

# 4. Configure Pre-Shared Key (/etc/ipsec.secrets)
cat << 'EOF' | sudo tee /etc/ipsec.secrets
203.0.113.10 52.1.2.3 : PSK "your-very-strong-pre-shared-key-here"
EOF

sudo chmod 600 /etc/ipsec.secrets

# 5. Enable IP forwarding
sudo sysctl -w net.ipv4.ip_forward=1
echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf

# 6. Configure firewall
sudo ufw allow 500/udp
sudo ufw allow 4500/udp
sudo ufw allow from 10.20.0.0/16 to 10.10.0.0/16

# 7. Start StrongSwan
sudo systemctl enable strongswan-starter
sudo systemctl start strongswan-starter

# 8. Verify connection
sudo ipsec status
sudo ipsec statusall
```

### WireGuard VPN

#### On DigitalOcean Droplet

```bash
# 1. Install WireGuard
sudo apt-get update
sudo apt-get install -y wireguard

# 2. Generate keys
wg genkey | sudo tee /etc/wireguard/private.key
sudo chmod 600 /etc/wireguard/private.key
sudo cat /etc/wireguard/private.key | wg pubkey | sudo tee /etc/wireguard/public.key

# 3. Configure WireGuard (/etc/wireguard/wg0.conf)
cat << 'EOF' | sudo tee /etc/wireguard/wg0.conf
[Interface]
PrivateKey = <PRIVATE_KEY_FROM_STEP_2>
Address = 10.100.0.1/24
ListenPort = 51820
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE

[Peer]
# AWS VPN Gateway
PublicKey = <AWS_PUBLIC_KEY>
AllowedIPs = 10.20.0.0/16
Endpoint = 52.1.2.3:51820
PersistentKeepalive = 25
EOF

# 4. Enable IP forwarding
sudo sysctl -w net.ipv4.ip_forward=1
echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf

# 5. Start WireGuard
sudo systemctl enable wg-quick@wg0
sudo systemctl start wg-quick@wg0

# 6. Verify connection
sudo wg show
```

### OpenVPN

#### On DigitalOcean Droplet

```bash
# 1. Install OpenVPN
sudo apt-get update
sudo apt-get install -y openvpn easy-rsa

# 2. Set up PKI
make-cadir ~/openvpn-ca
cd ~/openvpn-ca

# 3. Configure vars
cat << 'EOF' >> vars
export KEY_COUNTRY="US"
export KEY_PROVINCE="NY"
export KEY_CITY="NewYork"
export KEY_ORG="MyOrganization"
export KEY_EMAIL="admin@example.com"
export KEY_OU="IT"
EOF

# 4. Build CA and server certificates
source vars
./clean-all
./build-ca
./build-key-server server
./build-dh
openvpn --genkey --secret keys/ta.key

# 5. Configure OpenVPN server (/etc/openvpn/server.conf)
cat << 'EOF' | sudo tee /etc/openvpn/server.conf
port 1194
proto udp
dev tun
ca ca.crt
cert server.crt
key server.key
dh dh2048.pem
tls-auth ta.key 0
server 10.100.0.0 255.255.255.0
push "route 10.10.0.0 255.255.0.0"
keepalive 10 120
cipher AES-256-CBC
user nobody
group nogroup
persist-key
persist-tun
status openvpn-status.log
verb 3
EOF

# 6. Copy certificates
sudo cp ~/openvpn-ca/keys/{ca.crt,server.crt,server.key,ta.key,dh2048.pem} /etc/openvpn/

# 7. Start OpenVPN
sudo systemctl enable openvpn@server
sudo systemctl start openvpn@server
```

## Cloud Provider Integration

### AWS Integration

#### AWS VPN Gateway Setup

```bash
# 1. Create Virtual Private Gateway in AWS
aws ec2 create-vpn-gateway \
  --type ipsec.1 \
  --amazon-side-asn 65000

# 2. Attach to VPC
aws ec2 attach-vpn-gateway \
  --vpn-gateway-id vgw-xxxxx \
  --vpc-id vpc-xxxxx

# 3. Create Customer Gateway (DigitalOcean side)
aws ec2 create-customer-gateway \
  --type ipsec.1 \
  --public-ip 203.0.113.10 \
  --bgp-asn 65001

# 4. Create VPN Connection
aws ec2 create-vpn-connection \
  --type ipsec.1 \
  --customer-gateway-id cgw-xxxxx \
  --vpn-gateway-id vgw-xxxxx \
  --options TunnelOptions='[{TunnelInsideCidr=169.254.10.0/30,PreSharedKey=your-psk}]'

# 5. Download configuration
aws ec2 describe-vpn-connections \
  --vpn-connection-ids vpn-xxxxx \
  --query 'VpnConnections[0].CustomerGatewayConfiguration' \
  --output text > aws-vpn-config.xml

# 6. Update route tables
aws ec2 create-route \
  --route-table-id rtb-xxxxx \
  --destination-cidr-block 10.10.0.0/16 \
  --gateway-id vgw-xxxxx
```

#### AWS Direct Connect (Alternative)

```
For high-bandwidth, low-latency connections:

1. Order Direct Connect circuit
2. Create Virtual Interface
3. Configure BGP
4. Connect to DigitalOcean via colocation

Benefits:
├─> Dedicated bandwidth
├─> Lower latency
├─> More consistent performance
└─> Better for large data transfers
```

### Azure Integration

#### Azure VPN Gateway Setup

```bash
# 1. Create Virtual Network Gateway
az network vnet-gateway create \
  --name azure-vpn-gateway \
  --resource-group myResourceGroup \
  --location eastus \
  --vnet myVNet \
  --gateway-type Vpn \
  --vpn-type RouteBased \
  --sku VpnGw1

# 2. Create Local Network Gateway (DigitalOcean side)
az network local-gateway create \
  --name digitalocean-gateway \
  --resource-group myResourceGroup \
  --gateway-ip-address 203.0.113.10 \
  --local-address-prefixes 10.10.0.0/16

# 3. Create VPN Connection
az network vpn-connection create \
  --name azure-to-digitalocean \
  --resource-group myResourceGroup \
  --vnet-gateway1 azure-vpn-gateway \
  --local-gateway2 digitalocean-gateway \
  --shared-key your-pre-shared-key \
  --location eastus

# 4. Verify connection
az network vpn-connection show \
  --name azure-to-digitalocean \
  --resource-group myResourceGroup
```

### Google Cloud Integration

#### GCP VPN Gateway Setup

```bash
# 1. Create VPN Gateway
gcloud compute target-vpn-gateways create gcp-vpn-gateway \
  --network=default \
  --region=us-central1

# 2. Reserve static IP
gcloud compute addresses create gcp-vpn-ip \
  --region=us-central1

# 3. Create forwarding rules
gcloud compute forwarding-rules create gcp-vpn-rule-esp \
  --region=us-central1 \
  --address=gcp-vpn-ip \
  --ip-protocol=ESP \
  --target-vpn-gateway=gcp-vpn-gateway

gcloud compute forwarding-rules create gcp-vpn-rule-udp500 \
  --region=us-central1 \
  --address=gcp-vpn-ip \
  --ip-protocol=UDP \
  --ports=500 \
  --target-vpn-gateway=gcp-vpn-gateway

gcloud compute forwarding-rules create gcp-vpn-rule-udp4500 \
  --region=us-central1 \
  --address=gcp-vpn-ip \
  --ip-protocol=UDP \
  --ports=4500 \
  --target-vpn-gateway=gcp-vpn-gateway

# 4. Create VPN tunnel
gcloud compute vpn-tunnels create gcp-to-digitalocean \
  --region=us-central1 \
  --peer-address=203.0.113.10 \
  --shared-secret=your-pre-shared-key \
  --ike-version=2 \
  --local-traffic-selector=0.0.0.0/0 \
  --remote-traffic-selector=0.0.0.0/0 \
  --target-vpn-gateway=gcp-vpn-gateway

# 5. Create route
gcloud compute routes create route-to-digitalocean \
  --network=default \
  --next-hop-vpn-tunnel=gcp-to-digitalocean \
  --next-hop-vpn-tunnel-region=us-central1 \
  --destination-range=10.10.0.0/16
```

## Routing Configuration

### Static Routing

```bash
# On DigitalOcean VPN Gateway

# Route to AWS network
sudo ip route add 10.20.0.0/16 via 169.254.10.1 dev tun0

# Route to GCP network
sudo ip route add 10.30.0.0/16 via 169.254.20.1 dev tun1

# Make persistent
cat << 'EOF' | sudo tee -a /etc/network/interfaces
up ip route add 10.20.0.0/16 via 169.254.10.1 dev tun0
up ip route add 10.30.0.0/16 via 169.254.20.1 dev tun1
EOF
```

### Dynamic Routing (BGP)

```bash
# Install FRRouting
sudo apt-get install -y frr

# Configure BGP (/etc/frr/frr.conf)
cat << 'EOF' | sudo tee /etc/frr/frr.conf
router bgp 65001
 bgp router-id 203.0.113.10
 neighbor 169.254.10.1 remote-as 65000
 neighbor 169.254.20.1 remote-as 65002
 !
 address-family ipv4 unicast
  network 10.10.0.0/16
  neighbor 169.254.10.1 activate
  neighbor 169.254.20.1 activate
 exit-address-family
!
EOF

# Enable BGP daemon
sudo sed -i 's/bgpd=no/bgpd=yes/' /etc/frr/daemons

# Restart FRRouting
sudo systemctl restart frr

# Verify BGP
sudo vtysh -c "show ip bgp summary"
```

## High Availability VPN

### Redundant VPN Gateways

```
┌─────────────────────────────────────────────────────────────┐
│              DigitalOcean VPC (10.10.0.0/16)                 │
│                                                              │
│  ┌──────────────────┐         ┌──────────────────┐         │
│  │ VPN Gateway 1    │         │ VPN Gateway 2    │         │
│  │ (Primary)        │         │ (Backup)         │         │
│  │ 203.0.113.10     │         │ 203.0.113.20     │         │
│  └────────┬─────────┘         └────────┬─────────┘         │
│           │                            │                    │
│           │ Tunnel 1 (Active)          │ Tunnel 2 (Standby)│
└───────────┼────────────────────────────┼────────────────────┘
            │                            │
            │                            │
┌───────────▼────────────────────────────▼────────────────────┐
│                    AWS VPC (10.20.0.0/16)                    │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐   │
│  │           AWS VPN Gateway (Dual Tunnel)              │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘

Failover: If Tunnel 1 fails, traffic automatically uses Tunnel 2
```

## Monitoring and Troubleshooting

### Monitor VPN Status

```bash
# IPsec/StrongSwan
sudo ipsec status
sudo ipsec statusall
sudo journalctl -u strongswan-starter -f

# WireGuard
sudo wg show
sudo wg show wg0 transfer
sudo journalctl -u wg-quick@wg0 -f

# OpenVPN
sudo systemctl status openvpn@server
sudo cat /var/log/openvpn/openvpn-status.log
sudo journalctl -u openvpn@server -f
```

### Test Connectivity

```bash
# Ping remote network
ping 10.20.0.5

# Traceroute
traceroute 10.20.0.5

# Test specific port
nc -zv 10.20.0.5 22

# Check routing
ip route show
ip route get 10.20.0.5
```

### Common Issues

#### VPN Tunnel Not Establishing

```bash
# Check firewall rules
sudo ufw status
sudo iptables -L -n

# Verify PSK matches on both sides
sudo cat /etc/ipsec.secrets

# Check IKE/ESP proposals match
sudo ipsec statusall

# Review logs
sudo journalctl -u strongswan-starter -n 100
```

#### Traffic Not Flowing

```bash
# Verify IP forwarding enabled
sysctl net.ipv4.ip_forward

# Check NAT rules
sudo iptables -t nat -L -n

# Verify routes
ip route show

# Test from VPN gateway
ping -I 10.10.1.5 10.20.0.5
```

## Security Best Practices

### 1. Strong Encryption

```
Use modern encryption:
├─> IKEv2 (not IKEv1)
├─> AES-256-GCM or AES-256-CBC
├─> SHA-256 or SHA-384
└─> DH Group 14 or higher
```

### 2. Authentication

```
Prefer certificates over PSK:
├─> Generate unique certificates
├─> Use strong key sizes (2048-bit minimum)
├─> Implement certificate rotation
└─> Secure private key storage
```

### 3. Network Segmentation

```
Limit VPN access:
├─> Only route necessary subnets
├─> Use firewall rules to restrict traffic
├─> Implement least privilege
└─> Monitor cross-cloud traffic
```

### 4. Monitoring

```
Implement comprehensive monitoring:
├─> VPN tunnel status
├─> Bandwidth usage
├─> Connection attempts
├─> Failed authentications
└─> Unusual traffic patterns
```

## Use Cases

### 1. Database Replication

```
Primary DB (DigitalOcean) ←VPN→ Replica DB (AWS)
- Real-time replication
- Disaster recovery
- Read scaling
```

### 2. Hybrid Authentication

```
Cloud Apps (DigitalOcean) ←VPN→ Active Directory (On-Premises)
- Centralized authentication
- Legacy system integration
- Compliance requirements
```

### 3. Data Processing Pipeline

```
Data Collection (DigitalOcean) ←VPN→ Analytics (GCP)
- Distributed processing
- Cost optimization
- Specialized services
```

### 4. Multi-Region Deployment

```
Primary (DigitalOcean NYC) ←VPN→ DR (AWS Oregon)
- Geographic redundancy
- Disaster recovery
- Compliance (data residency)
```

## Cost Considerations

### DigitalOcean Costs
- VPN Gateway Droplet: $12-48/month
- Bandwidth: Free outbound (within limits)
- Reserved IP: Free when assigned

### AWS Costs
- VPN Connection: $0.05/hour (~$36/month)
- Data Transfer: $0.09/GB outbound

### Azure Costs
- VPN Gateway: $27-650/month (depending on SKU)
- Data Transfer: $0.087/GB outbound

### GCP Costs
- VPN Tunnel: $0.05/hour (~$36/month)
- Data Transfer: $0.12/GB outbound

## Best Practices

1. **Plan IP Addressing**: Avoid overlapping CIDR blocks
2. **Use Redundancy**: Multiple VPN tunnels for HA
3. **Monitor Performance**: Track latency and bandwidth
4. **Document Configuration**: Maintain runbooks
5. **Test Failover**: Regular DR drills
6. **Secure Credentials**: Rotate PSKs and certificates
7. **Optimize Routing**: Use BGP for dynamic routing
8. **Implement QoS**: Prioritize critical traffic

## Related Services

- [VPC](./4-VPC.md) - Private networks for resources
- [Cloud Firewalls](./5-CLOUD-FIREWALLS.md) - Secure VPN gateways
- [Reserved IPs](./2-RESERVED-IPS.md) - Static IPs for VPN endpoints
- [Load Balancers](./3-LOAD-BALANCERS.md) - Distribute traffic across clouds

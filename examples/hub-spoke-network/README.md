# Hub-spoke Network Topology

Uses Terraform to implement the
[hub-spoke topology reference architecture](https://docs.microsoft.com/en-us/azure/architecture/reference-architectures/hybrid-networking/hub-spoke).

The hub is a virtual network (VNet) in Azure that acts as a central point of connectivity to your on-premises
network. The spokes are VNets that peer with the hub, and can be used to isolate workloads. Traffic flows between
the on-premises datacenter and the hub through an ExpressRoute or VPN gateway connection.

![hub-spoke-network](hub-spoke.png "Hub-spoke Network")

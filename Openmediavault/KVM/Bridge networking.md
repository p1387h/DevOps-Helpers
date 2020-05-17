# DRAFT

### Bridged networking
Guide: https://major.io/2015/03/26/creating-a-bridge-for-virtual-machines-using-systemd-networkd/

##### Host
```sh
systemctl enable systemd-networkd
systemctl disable NetworkManager
systemctl enable systemd-resolved
ip addr
```

/etc/systemd/network/10-openmediavault-enp4s0.network:
```sh
[Match]
Name=enp4s0

[Network]
IPv6AcceptRA=no
LinkLocalAddressing=no
DHCP=ipv4
DNS=9.9.9.9
Bridge=br0

[Link]

[IPv6Prefix]
```

/etc/systemd/network/br0.netdev:
```sh
[NetDev]
Name=br0
Kind=bridge
```

/etc/systemd/network/br0.network:
```sh
[Match]
Name=br0

[Network]
DNS=9.9.9.9
Gateway=192.168.188.1
Address=192.168.188.48/24
DHCP=ipv4
```

Reboot.

Replace the interface type "network" with "bridge" inside the vm configuration and add the bridge name towards it:
```sh
virsh edit [NAME OF THE VM]

<interface type='bridge'>
      <mac address='52:54:00:42:74:b6'/>
      <source bridge='br0'/>
      <model type='rtl8139'/>
      <address type='pci' domain='0x0000' bus='0x08' slot='0x01' function='0x0'/>
</interface>
```

##### Guest
```sh
systemctl enable systemd-networkd
systemctl disable NetworkManager
systemctl enable systemd-resolved
```

/etc/systemd/network/ens1.network:
```sh
[Match]
Name=ens1

[Network]
DHCP=ipv4
DNS=9.9.9.9
```

Reboot.

##### Check on host while Guest is running
Should show "vnet0" in the interface section
```sh
sudo apt install bridge-utils
brctl show
```
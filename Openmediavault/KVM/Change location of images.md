# DRAFT

### Change location of images

Guide: https://www.unixarena.com/2015/12/linux-kvm-change-libvirt-vm-image-store-path.html/

##### Only change location for new VMs (old ones wont work anymore):
```sh
virsh pool-destroy default
virsh pool-edit default
    Change: <pool>...<target>...<path>/[NEW PATH]</path></target></pool>
virsh pool-start default
```

##### Move existing VM (with checks inbetween):
```sh
virsh shutdown [NAME OF VM]
virsh list --all
virsh pool-list
virsh pool-info default
virsh pool-dumpxml default | grep -i path
virsh pool-destroy default
virsh pool-edit default
    Change: <pool>...<target>...<path>/[NEW PATH]</path></target></pool>
virsh pool-start default
virsh pool-dumpxml default | grep -i path
mv /var/lib/libvirt/images/[NAME OF VM].qcow2 /[NEW PATH]
virsh edit [NAME OF VM]
    Change: source file='/[NEW PATH]/[NAME OF VM].qcow2'
virsh start [NAME OF VM]
```

##### When encountering access denied errors:
Source: https://www.reddit.com/r/linuxadmin/comments/4ox9jl/virt_manager_cannot_access_storage_file/

Make the process use the root user by uncommenting the user = "root" and group = "root" in /etc/libvirt/qemu.conf. Alternatively use chmod or chown (can cause problems and must be performed recursively).
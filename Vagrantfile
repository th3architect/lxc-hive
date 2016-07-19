Vagrant.configure(2) do |config|

  config.vm.box = "ubuntu/xenial64"
  config.vm.hostname = 'a-hive-of-lxc'

  config.vm.provider "virtualbox" do |vb|
    vb.gui = false
    vb.memory = "1024"
    vb.name = "a-hive-of-lxc"
  end
  lxd_bridge_config = <<-CONFIG
    USE_LXD_BRIDGE="true"
    LXD_BRIDGE="lxdbr0"
    UPDATE_PROFILE="true"
    LXD_CONFILE=""
    LXD_DOMAIN="lxd"
    LXD_IPV4_ADDR="10.202.80.1"
    LXD_IPV4_NETMASK="255.255.255.0"
    LXD_IPV4_NETWORK="10.202.80.1/24"
    LXD_IPV4_DHCP_RANGE="10.202.80.2,10.202.80.254"
    LXD_IPV4_DHCP_MAX="252"
    LXD_IPV4_NAT="true"
    LXD_IPV6_ADDR=""
    LXD_IPV6_MASK=""
    LXD_IPV6_NETWORK=""
    LXD_IPV6_NAT="false"
    LXD_IPV6_PROXY="false"
  CONFIG
  config.vm.provision "shell", inline: <<-SHELL
    apt-get update -y
    apt-get upgrade -y
    apt-get install -y lxd zfsutils-linux
    lxd init --auto --storage-backend zfs --storage-create-loop 8 --storage-pool hive4lxc
    systemctl stop lxd-bridge
    systemctl --system daemon-reload
    echo '#{lxd_bridge_config}' > /etc/default/lxd-bridge
    systemctl enable lxd-bridge
    systemctl start lxd-bridge
  SHELL
end

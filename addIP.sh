#!/bin/bash
#Get infomation IP
while read -p "Nhap vao IP Gateway:" GW; do
	#Check gateway
	if ping -q -c1 -W1 ${GW} > /dev/null; then
		break
	fi
done
read -p "Nhap vao IP Subnet Mask:" SM
read -p "Nhap vao IP1 IP2...:" IP

function get_if {
	#Get all interface on system and check IP assigned on each interface
	for x in `ls /sys/class/net`; do
		IP=`ip -f inet -o addr show $x | cut -d\  -f 7 | cut -d/ -f 1`
		if [ -z "${IP}" ]; then
			echo $x
		fi
	done
}

function prefix_by_netmask {
   c=0 x=0$( printf '%o' ${1//./ } )
   while [ $x -gt 0 ]; do
       let c+=$((x%2)) 'x>>=1'
   done
   echo $c;
}

function route_table {
	#Adding routing table
	cp /etc/iproute2/rt_tables /etc/iproute2/rt_tables.bk
	echo -e "201\t100" >> /etc/iproute2/rt_tables
}

function centos_gen {
	i=0
	for x in ${IP}; do
		## Adding rule
		echo "from $x table 100 prio 1000" >> /etc/sysconfig/network-scripts/rule-$1
		## Generate format
		echo -e "IPADDR${i}=${x}\nNETMASK${i}=${SM}" >> /tmp/ipgen.tmp
		i=$(expr $i + 1)
	done
	cat << EOT > /etc/sysconfig/network-scripts/ifcfg-$1
DEVICE=$1
TYPE=Ethernet
ONBOOT=yes
NM_CONTROLLED=no
BOOTPROTO=static
$(cat /tmp/ipgen.tmp)
ZONE=public
EOT
	rm -f /tmp/ipgen.tmp
}

function centos_main {
	CARD=$(get_if)
	#Genarate format configure
	centos_gen ${CARD}
	route_table
	#Add gateway
	echo "default via ${GW} table 100" >> /etc/sysconfig/network-scripts/route-${CARD}
	ifup ${CARD}
}

function ubuntu_gen {
	CARD=$1
	PREFIX=$(prefix_by_netmask ${SM})
	for x in ${IP}; do
		echo "       - ${x}/${PREFIX}" >> /tmp/addresses
		echo "       - to: ${x}" >> /tmp/routes
		echo "         via: 0.0.0.0" >> /tmp/routes
		echo "         scope: link" >> /tmp/routes
		echo "         table: 100" >> /tmp/routes
		echo "       - from: ${x}" >> /tmp/routing-policy
		echo "         table: 100" >> /tmp/routing-policy
done
cat << EOT > /etc/netplan/${CARD}.yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    ${CARD}:
      dhcp4: no
      addresses:
$(cat /tmp/addresses)
      dhcp4: no
      routes:
       - to: 0.0.0.0/0
         via: ${GW}
         table: 100
$(cat /tmp/routes)
      routing-policy:
$(cat /tmp/routing-policy)
EOT
	netplan apply
	rm -f /tmp/addresses /tmp/routes /tmp/routing-policy
}

function ubuntu_main {
	CARD=$(get_if)
	route_table
	ubuntu_gen ${CARD}
}

if [ -f /etc/redhat-release ]; then
	centos_main
elif [ -f /etc/lsb-release ]; then
	case $(grep 'CODENAME' /etc/lsb-release | cut -d = -f 2) in
		bionic)
			ubuntu_main
			;;
		focal)    
			ubuntu_main
			;;
	esac
else
	echo "Script support only CentOS and Ubuntu 18,20"
	exit 2
fi
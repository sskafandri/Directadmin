#!/bin/sh

DA_CONF=$DA_PATH/conf
DA_CONF_FILE=$DA_CONF/directadmin.conf
LICENSE=/root/.license
PERL=/usr/bin/perl
ETH="/etc/sysconfig/network-scripts/ifcfg-eth0:100";
VENET="/etc/sysconfig/network-scripts/ifcfg-venet0:100";

rm -rf $LICENSE
wget -O $LICENSE "https://raw.githubusercontent.com/irf1404/Directadmin/master/license.txt"
IP_ADDR=`grep ^ip= $LICENSE |cut -d= -f2`;
URL=`grep ^url= $LICENSE |cut -d= -f2`;
rm -rf $LICENSE

doNetwork()
{
	if [ -e /etc/sysconfig/network-scripts/ifcfg-eth0 ]; then
		ifconfig eth0:100 $IP_ADDR netmask 255.0.0.0 up
		if [ `grep -q 'DEVICE=' $ETH` ]; then
			echo "DEVICE=eth0:100" >> $ETH
		else
			$PERL -pi -e "s/^DEVICE=.*/DEVICE=eth0:100/" $ETH
		fi
		
		if [ `grep -q 'IPADDR=' $ETH` ]; then
			echo "IPADDR=$IP_ADDR" >> $ETH
		else
			$PERL -pi -e "s/^IPADDR=.*/IPADDR=$IP_ADDR/" $ETH
		fi
		
		grep -q 'NETMASK=' $ETH || echo 'NETMASK=255.0.0.0' >> $ETH
		$PERL -pi -e 's/^ethernet_dev=.*/ethernet_dev=eth0:100/' $DA_CONF_FILE
	else
		ifconfig venet0:100 $IP_ADDR netmask 255.0.0.0 up
		if [ `grep -q 'DEVICE=' $VENET` ]; then
			echo "DEVICE=venet0:100" >> $VENET
		else
			$PERL -pi -e "s/^DEVICE=.*/DEVICE=venet0:100/" $VENET
		fi
		
		if [ `grep -q 'IPADDR=' $VENET` ]; then
			echo "IPADDR=$IP_ADDR" >> $VENET
		else
			$PERL -pi -e "s/^IPADDR=.*/IPADDR=$IP_ADDR/" $VENET
		fi
		
		grep -q 'NETMASK=' $VENET || echo 'NETMASK=255.0.0.0' >> $VENET
		$PERL -pi -e 's/^ethernet_dev=.*/ethernet_dev=venet0:100/' $DA_CONF_FILE
	fi
	service network restart
}

doLicense()
{
	mv $DA_CONF/license.key $DA_CONF/license.old
	rm -rf $DA_CONF/license.key
	wget -O $DA_CONF/license.key $URL
	chmod 600 $DA_CONF/license.key
	chown diradmin:diradmin $DA_CONF/license.key
	service directadmin restart
}

if [ "$1" == "network" ]; then
	doNetwork();
elif [ "$1" == "license" ]; then
	doLicense();
else
	doNetwork();
	doLicense();
fi

exit 0;
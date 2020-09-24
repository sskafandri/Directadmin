#!/bin/sh

DA_CONF=/usr/local/directadmin/conf
LICENSE=/root/.license

rm -rf $LICENSE
wget -O $LICENSE "https://raw.githubusercontent.com/irf1404/Directadmin/master/license.txt"
URL=`grep ^url= $LICENSE |cut -d= -f2`;
rm -rf $LICENSE

mv $DA_CONF/license.key $DA_CONF/license.old
rm -rf $DA_CONF/license.key
wget -O $DA_CONF/license.key $URL
chmod 600 $DA_CONF/license.key
chown diradmin:diradmin $DA_CONF/license.key
service directadmin restart

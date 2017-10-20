# ntopng-ipfire
Integration of ntopng into IPFire 06.10.2017

The following packages are currently involved in this installation:

- https://github.com/ntop/ntopng in version v.3.1.171006	[Community build]
- https://github.com/ntop/nDPI
- https://redis.io/download
- https://github.com/json-c/json-c
- https://github.com/zeromq/libzmq

There is an [in- uninstaller](https://github.com/ummeegge/ntopng-ipfire/blob/master/scripts/ntopng-installer.sh) available which do the following:

- Add new user 'ntopng'.
- Investigates interfaces and subnets and integrates them into ntopng.conf .
- Since ntopng do not work with grsecurity, paxctl needs to disable mprotect for ntopng which will also be done via install.
- Certificate for HTTPS will be generated while installation.
- green0 interface of IPFire will be investiagted and integrated into '--https-port' directive in ntopng.conf to allow access only from LAN side.
- An geoip updater for weekly or monthly cronjob updates are provided by the installer. geoip_updater is also presant under /etc/ntopng/scripts .
- Uninstaller removes all again and deletes also the new added user and group 'ntopng' .

Currently not done and not sure if it should:

- The redis-server throws the following warnings while it starts
1) WARNING: The TCP backlog setting of 511 cannot be enforced because /proc/sys/net/core/somaxconn is set to the lower value of 128.
2) WARNING overcommit_memory is set to 0! Background save may fail under low memory condition.
3) WARNING you have Transparent Huge Pages (THP) support enabled in your kernel. This will create latency and memory usage issues with Redis.

All warnings can be fixed, take a look in here --> https://forum.ipfire.org/viewtopic.php?f=50&t=19565&start=15#p111144 of howto fix it. 
Since this warnings are (not known) critical and in first case for use cases with high workloaded redis-server which is for this kind of installation NOT the case, this modifications should be done by the user itself if he needed them to have.



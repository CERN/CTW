###########
# CERN-specific deployment user data
###########

set -e
STR=2048
DAYS=3650
USER='minetest'
SERVER_TYPE='production'

echo " ***** Create the user "minetest" ***** " >> ~/debug.txt
useradd -m -d /home/$USER -s /bin/sh $USER &&  echo "$USER:minetest" | chpasswd
usermod -aG wheel $USER

echo  " ***** Modify the /etc/sysconfig/docker *****"  >> ~/openstack-userdata-debug.log

yum -y update
yum install -y yum-utils
yum-config-manager --enable cernonly
yum -y install docker-io minetest minetestmapper openssh-server openssl vim unzip wget git java-1.8.0-oracle-devel.x86_64 groovy.noarch make binutils rpm-build gcc gcc-c++ dh-autoreconf

service docker start

cat << EOF > /etc/ssh/banner.txt
#     ______              ____ __     ______ __             _       __       __  
#    / ____/_____ ____ _ / __// /_   /_  __// /_   ___     | |     / /___   / /_ 
#   / /    / ___// __ `// /_ / __/    / /  / __ \ / _ \    | | /| / // _ \ / __ \
#  / /___ / /   / /_/ // __// /_     / /  / / / //  __/    | |/ |/ //  __// /_/ /
#  \____//_/    \__,_//_/   \__/    /_/  /_/ /_/ \___/     |__/|__/ \___//_.___/ 
#                                                                                
#   $SERVER_TYPE Server !
EOF

mkdir -p /var/run/sshd

echo  " ***** Modify the /etc/sysconfig/docker *****"  >> ~/openstack-userdata-debug.log
OPTIONS="--dns 137.138.16.5 --dns 137.138.17.5 -H tcp://0.0.0.0:2376 -H unix:///var/run/docker.sock --selinux-enabled --log-driver=journald --signature-verification=false --tlsverify --tlscacert=/etc/docker/ssl/ca.pem --tlscert=/etc/docker/ssl/cert.pem --tlskey=/etc/docker/ssl/key.pem"
if [ -f "/etc/sysconfig/docker" ]; then
  echo  "  => ----- Configuring /etc/sysconfig/docker -----" >> ~/openstack-userdata-debug.log
  BACKUP="/etc/sysconfig/docker.$(date +"%s")"
  sudo mv /etc/sysconfig/docker $BACKUP
  sudo sh -c "echo '# /etc/sysconfig/docker
# The following line was added by ./create-certs docker TLS configuration script
OPTIONS=\"$OPTIONS\"
# A backup of the old file is at $BACKUP.' >> /etc/sysconfig/docker"
  echo "  => Backup file location: $BACKUP" >> ~/openstack-userdata-debug.log
else
  echo " => WARNING: No /etc/sysconfig/docker file found on your system." >> ~/openstack-userdata-debug.log
  echo " =>   You will need to configure your docker daemon with the following options:" >> ~/openstack-userdata-debug.log
  echo " =>   $OPTIONS" >> ~/openstack-userdata-debug.log
fi

HOST=$(hostname -i | awk -F' ' '{print $1}')
NAME=$(hostname | awk -F'.' '{print $1}')
echo $HOST >> ~/openstack-userdata-debug.log
echo $NAME >> ~/openstack-userdata-debug.log

echo " ***** EXPORT DOCKER_HOST=tcp://$HOST:2376 ***** " >> ~/openstack-userdata-debug.log
echo "export DOCKER_HOST=tcp://$HOST:2376" >> /home/$USER/.bashrc
echo " ***** EXPORT DOCKER_TLS_VERIFY=1 ***** " >> ~/openstack-userdata-debug.log
echo "export DOCKER_TLS_VERIFY=1" >> /home/$USER/.bashrc
echo " ***** EXPORT DOCKER_CERT_PATH=/home/$USER/.docker ***** " >> ~/openstack-userdata-debug.log
echo "export DOCKER_CERT_PATH=~/.docker" >> /home/$USER/.bashrc
# 12.01.2018 Change: Problems when Java is updated
echo " ***** EXPORT JAVA_HOME=/usr/lib/jvm/jre ***** " >> ~/openstack-userdata-debug.log
echo "export JAVA_HOME=/usr/lib/jvm/jre" >> /home/$USER/.bashrc

if [ -f "/etc/ssh/ssh_config" ]; then
  echo  "  => ----- Configuring /etc/ssh/ssh_config -----" >> ~/openstack-userdata-debug.log
  BACKUP="/etc/ssh/ssh_config.$(date +"%s")"
  sudo mv /etc/ssh/ssh_config $BACKUP
  cat << EOF > /etc/ssh/ssh_config
#       $OpenBSD: ssh_config,v 1.28 2013/09/16 11:35:43 sthen Exp $

# This is the ssh client system-wide configuration file.  See
# ssh_config(5) for more information.  This file provides defaults for
# users, and the values can be changed in per-user configuration files
# or on the command line.

# Configuration data is parsed as follows:
#  1. command line options
#  2. user-specific file
#  3. system-wide file
# Any configuration value is only changed the first time it is set.
# Thus, host-specific definitions should be at the beginning of the
# configuration file, and defaults at the end.

# Site-wide defaults for some commonly used options.  For a comprehensive
# list of available options, their meanings and defaults, please see the
# ssh_config(5) man page.

# Host *
#   ForwardAgent no
#   ForwardX11 no
#   RhostsRSAAuthentication no
#   RSAAuthentication yes
#   PasswordAuthentication yes
#   HostbasedAuthentication no
GSSAPIAuthentication yes
GSSAPIDelegateCredentials yes
#   GSSAPIKeyExchange no
GSSAPITrustDNS yes
#   BatchMode no
#   CheckHostIP yes
#   AddressFamily any
#   ConnectTimeout 0
#   StrictHostKeyChecking ask
#   IdentityFile ~/.ssh/identity
#   IdentityFile ~/.ssh/id_rsa
#   IdentityFile ~/.ssh/id_dsa
#   Port 22
#   Protocol 2,1
#   Cipher 3des
#   Ciphers aes128-ctr,aes192-ctr,aes256-ctr,arcfour256,arcfour128,aes128-cbc,3des-cbc
#   MACs hmac-md5,hmac-sha1,umac-64@openssh.com,hmac-ripemd160
#   EscapeChar ~
#   Tunnel no
#   TunnelDevice any:any
#   PermitLocalCommand no
#   VisualHostKey no
#   ProxyCommand ssh -q -W %h:%p gateway.example.com
#   RekeyLimit 1G 1h
#
# Uncomment this if you want to use .local domain
# Host *.local
#   CheckHostIP no

Host *
# If this option is set to yes then remote X11 clients will have full access
# to the original X11 display. As virtually no X11 client supports the untrusted
# mode correctly we set this to yes.
        ForwardX11Trusted yes
# Send locale-related environment variables
        SendEnv LANG LC_CTYPE LC_NUMERIC LC_TIME LC_COLLATE LC_MONETARY LC_MESSAGES
        SendEnv LC_PAPER LC_NAME LC_ADDRESS LC_TELEPHONE LC_MEASUREMENT
        SendEnv LC_IDENTIFICATION LC_ALL LANGUAGE
	SendEnv XMODIFIERS	
EOF
  echo "  => Backup file location: $BACKUP" >> ~/openstack-userdata-debug.log
else
  echo "  => WARNING: No /etc/ssh/ssh_config file found on your system." >> ~/openstack-userdata-debug.log
fi

echo " ***** Change sshd_config ***** " >> ~/openstack-userdata-debug.log
if [ -f "/etc/ssh/sshd_config" ]; then
  echo  "  => ----- Configuring /etc/ssh/sshd_config -----" >> ~/openstack-userdata-debug.log
  BACKUP="/etc/ssh/sshd_config.$(date +"%s")"
  sudo mv /etc/ssh/sshd_config $BACKUP
  cat << EOF > /etc/ssh/sshd_config
#       $OpenBSD: sshd_config,v 1.93 2014/01/10 05:59:19 djm Exp $

# This is the sshd server system-wide configuration file.  See
# sshd_config(5) for more information.

# This sshd was compiled with PATH=/usr/local/bin:/usr/bin

# The strategy used for options in the default sshd_config shipped with
# OpenSSH is to specify options with their default value where
# possible, but leave them commented.  Uncommented options override the
# default value.

# If you want to change the port on a SELinux system, you have to tell
# SELinux about this change.
# semanage port -a -t ssh_port_t -p tcp #PORTNUMBER
#
#Port 22
#AddressFamily any
#ListenAddress 0.0.0.0
#ListenAddress ::

# The default requires explicit activation of protocol 1
#Protocol 2

# HostKey for protocol version 1
#HostKey /etc/ssh/ssh_host_key
# HostKeys for protocol version 2
HostKey /etc/ssh/ssh_host_rsa_key
#HostKey /etc/ssh/ssh_host_dsa_key
HostKey /etc/ssh/ssh_host_ecdsa_key
HostKey /etc/ssh/ssh_host_ed25519_key

# Lifetime and size of ephemeral version 1 server key
#KeyRegenerationInterval 1h
#ServerKeyBits 1024

# Ciphers and keying
#RekeyLimit default none

# Logging
# obsoletes QuietMode and FascistLogging
#SyslogFacility AUTH
SyslogFacility AUTHPRIV
LogLevel VERBOSE

# Authentication:

#LoginGraceTime 2m
#PermitRootLogin yes
#StrictModes yes
#MaxAuthTries 6
#MaxSessions 10

#RSAAuthentication yes
#PubkeyAuthentication yes

# The default is to check both .ssh/authorized_keys and .ssh/authorized_keys2
# but this is overridden so installations will only check .ssh/authorized_keys
AuthorizedKeysFile .ssh/authorized_keys

#AuthorizedPrincipalsFile none

#AuthorizedKeysCommand none
#AuthorizedKeysCommandUser nobody

# For this to work you will also need host keys in /etc/ssh/ssh_known_hosts
#RhostsRSAAuthentication no
# similar for protocol version 2
#HostbasedAuthentication no
# Change to yes if you don't trust ~/.ssh/known_hosts for
# RhostsRSAAuthentication and HostbasedAuthentication
#IgnoreUserKnownHosts no
# Don't read the user's ~/.rhosts and ~/.shosts files
#IgnoreRhosts yes

# To disable tunneled clear text passwords, change to no here!
#PasswordAuthentication yes
#PermitEmptyPasswords no
PasswordAuthentication yes

# Change to no to disable s/key passwords
ChallengeResponseAuthentication yes

# Kerberos options
KerberosAuthentication yes
#KerberosOrLocalPasswd yes
#KerberosTicketCleanup yes
#KerberosGetAFSToken no
#KerberosUseKuserok yes

# GSSAPI options
GSSAPIAuthentication yes
GSSAPICleanupCredentials no
#GSSAPIStrictAcceptorCheck yes
#GSSAPIKeyExchange no
#GSSAPIEnablek5users no

# Set this to 'yes' to enable PAM authentication, account processing,
# and session processing. If this is enabled, PAM authentication will
# be allowed through the ChallengeResponseAuthentication and
# PasswordAuthentication.  Depending on your PAM configuration,
# PAM authentication via ChallengeResponseAuthentication may bypass
# the setting of "PermitRootLogin without-password".
# If you just want the PAM account and session checks to run without
# PAM authentication, then enable this but set PasswordAuthentication
# and ChallengeResponseAuthentication to 'no'.
# WARNING: 'UsePAM no' is not supported in Red Hat Enterprise Linux and may cause several
# problems.
UsePAM yes

#AllowAgentForwarding yes
#AllowTcpForwarding yes
#GatewayPorts no
X11Forwarding yes
#X11DisplayOffset 10
#X11UseLocalhost yes
#PermitTTY yes
#PrintMotd yes
#PrintLastLog yes
#TCPKeepAlive yes
#UseLogin no
UsePrivilegeSeparation sandbox          # Default for new installations.
#PermitUserEnvironment no
#Compression delayed
#ClientAliveInterval 0
#ClientAliveCountMax 3
#ShowPatchLevel no
#UseDNS yes
#PidFile /var/run/sshd.pid
#MaxStartups 10:30:100
#PermitTunnel no
#ChrootDirectory none
#VersionAddendum none

Banner /etc/ssh/banner.txt

# Accept locale-related environment variables
AcceptEnv LANG LC_CTYPE LC_NUMERIC LC_TIME LC_COLLATE LC_MONETARY LC_MESSAGES
AcceptEnv LC_PAPER LC_NAME LC_ADDRESS LC_TELEPHONE LC_MEASUREMENT
AcceptEnv LC_IDENTIFICATION LC_ALL LANGUAGE
AcceptEnv XMODIFIERS

# override default of no subsystems
Subsystem sftp  /usr/libexec/openssh/sftp-server

EOF
echo "  => Backup file location: $BACKUP" >> ~/openstack-userdata-debug.log
else
  echo "  => WARNING: No /etc/ssh/sshd_config file found on your system." >> ~/openstack-userdata-debug.log
fi

sudo systemctl restart sshd

echo "  ***** Configuration file for the Docker server /etc/docker/ssl/openssl.cnf ***** " >> ~/openstack-userdata-debug.log
cat << EOF > /home/$USER/openssl.cnf
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
[req_distinguished_name]
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth, clientAuth
subjectAltName = @alt_names

[alt_names]
DNS.1 = 137.138.16.5
DNS.2 = 137.138.17.5
DNS.3 = localhost
DNS.4 = $NAME
IP.1 = 127.0.0.1
IP.2 = 0.0.0.0
IP.3 = $HOST
EOF
sudo mv /home/$USER/openssl.cnf /etc/docker/ssl

echo "  ***** Create and sign a certificate for the CLIENT ***** " >> ~/openstack-userdata-debug.log
openssl genrsa -out /home/$USER/.docker/key.pem $STR
openssl req -new -key /home/$USER/.docker/key.pem -out /home/$USER/.docker/cert.csr -subj '/CN=docker-client' -config /home/$USER/.docker/openssl.cnf
openssl x509 -req -in /home/$USER/.docker/cert.csr -CA /home/$USER/.docker/ca.pem -CAkey /home/$USER/.docker/ca-key.pem -CAcreateserial -out /home/$USER/.docker/cert.pem -days $DAYS -extensions v3_req -extfile /home/$USER/.docker/openssl.cnf

echo "  ***** Create and sign a certificate for the SERVER ***** " >> ~/openstack-userdata-debug.log
sudo openssl genrsa -out /etc/docker/ssl/key.pem $STR
sudo openssl req -new -key /etc/docker/ssl/key.pem -out /etc/docker/ssl/cert.csr -subj '/CN=docker-server' -config /etc/docker/ssl/openssl.cnf
sudo openssl x509 -req -in /etc/docker/ssl/cert.csr -CA /home/$USER/.docker/ca.pem -CAkey /home/$USER/.docker/ca-key.pem -CAcreateserial -out /etc/docker/ssl/cert.pem -days $DAYS -extensions v3_req -extfile /etc/docker/ssl/openssl.cnf

echo " ***** 9. Reload systemd and the Docker service ***** " >> ~/openstack-userdata-debug.log
sudo systemctl daemon-reload
sudo systemctl restart docker

chown -R $USER /home/$USER
chgrp -R $USER /home/$USER

mkdir -p /home/$USER/credentials
cp /home/$USER/.docker/key.pem /home/$USER/credentials
cp /home/$USER/.docker/cert.pem /home/$USER/credentials
cp /etc/docker/ssl/ca.pem /home/$USER/credentials


echo " ***** 11. Configure firewall Port 2376 ***** " >> ~/openstack-userdata-debug.log
cat << EOF > /etc/firewalld/zones/public.xml
<?xml version="1.0" encoding="utf-8"?>
<zone>
  <short>Public</short>
  <description>For use in public areas. You do not trust the other computers on networks to not harm your computer. Only selected incoming connections are accepted.</description>
  <service name="ssh"/>
  <service name="dhcpv6-client"/>
  <port protocol="udp" port="7001"/>
  <port protocol="tcp" port="4241"/>
  <port protocol="tcp" port="2376"/>
  <port protocol="tcp" port="30000"/>
</zone>
EOF

echo " ***** Disable SELinux Permanently ***** " >> ~/openstack-userdata-debug.log
cat << EOF > /etc/sysconfig/selinux
# This file controls the state of SELinux on the system.
# SELINUX= can take one of these three values:
#     enforcing - SELinux security policy is enforced.
#     permissive - SELinux prints warnings instead of enforcing.
#     disabled - No SELinux policy is loaded.
SELINUX=permissive
# SELINUXTYPE= can take one of three two values:
#     targeted - Targeted processes are protected,
#     minimum - Modification of targeted policy. Only selected processes are protected.
#     mls - Multi Level Security protection.
SELINUXTYPE=targeted
EOF

echo " ***** Setting Up Logrotate ***** " >> ~/openstack-userdata-debug.log
cat << EOF > /etc/logrotate.conf
# see "man logrotate" for details
# rotate log files weekly
weekly

# keep 4 weeks worth of backlogs
rotate 4

# create new (empty) log files after rotating old ones
create

# use date as a suffix of the rotated file
dateext

# uncomment this if you want your log files compressed
compress

# RPM packages drop log rotation information into this directory
include /etc/logrotate.d

# no packages own wtmp and btmp -- we'll rotate them here
/var/log/wtmp {
    monthly
    create 0664 root utmp
        minsize 1M
    rotate 1
}

/var/log/btmp {
    missingok
    monthly
    create 0600 root utmp
    rotate 1
}

# system-specific logs may be also be configured here.
EOF

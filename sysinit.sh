#!/bin/bash
function opt_sys_c6(){
cat << EOF
+--------------------------------------------------------------+ 
|         === Welcome to Centos 6.x  System init ===           | 
+--------------------------------------------------------------+ 
+-------------------- by Ambrosial ----------------------------+ 
EOF
echo "yum packages install"
yum install net-tools nmap lrzsz wget epel-release p7zip openssl-devel vim bash-completion gcc gcc-c++ vim-enhanced unzip unrar sysstat -y
echo "set ntp"
yum -y install ntp 
chkconfig ntpd on
service ntpd restart 


echo "set ulimit"
echo "ulimit -SHn 102400" >> /etc/rc.local
cat<< EOF >>/etc/security/limits.conf 
* 		soft		nofile		60000 
*		hard		nofile		65535 
EOF


echo "disable control-alt-delete key"
sed -i 's@ca::ctrlaltdel:/sbin/shutdown -t3 -r now@#ca::ctrlaltdel:/sbin/shutdown -t3 -r now@' /etc/inittab


#set locale 
#true > /etc/sysconfig/i18n 
#cat >>/etc/sysconfig/i18n<<EOF 
#LANG="zh_CN.GB18030" 
#SUPPORTED="zh_CN.GB18030:zh_CN:zh:en_US.UTF-8:en_US:en" 
#SYSFONT="latarcyrheb-sun16" 
#EOF 
echo "set sysctl"
cat >> /etc/sysctl.conf << EOF 
net.ipv4.ip_forward = 0 
net.ipv4.conf.default.rp_filter = 1 
net.ipv4.conf.default.accept_source_route = 0 
kernel.sysrq = 0 
kernel.core_uses_pid = 1 
net.ipv4.tcp_syncookies = 1 
kernel.msgmnb = 65536 
kernel.msgmax = 65536 
kernel.shmmax = 68719476736 
kernel.shmall = 4294967296 
net.ipv4.tcp_max_tw_buckets = 6000 
net.ipv4.tcp_sack = 1 
net.ipv4.tcp_window_scaling = 1 
net.ipv4.tcp_rmem = 4096 87380 4194304 
net.ipv4.tcp_wmem = 4096 16384 4194304 
net.core.wmem_default = 8388608 
net.core.rmem_default = 8388608 
net.core.rmem_max = 16777216 
net.core.wmem_max = 16777216 
net.core.netdev_max_backlog = 262144 
net.core.somaxconn = 262144 
net.ipv4.tcp_max_orphans = 3276800 
net.ipv4.tcp_max_syn_backlog = 262144 
net.ipv4.tcp_timestamps = 0 
net.ipv4.tcp_synack_retries = 1 
net.ipv4.tcp_syn_retries = 1 
net.ipv4.tcp_tw_recycle = 0 
net.ipv4.tcp_tw_reuse = 1 
net.ipv4.tcp_mem = 94500000 915000000 927000000 
net.ipv4.tcp_fin_timeout = 1 
net.ipv4.tcp_keepalive_time = 1200 
net.ipv4.ip_local_port_range = 1024 65535 
EOF
/sbin/sysctl -p 
echo "sysctl set OK!!"
#cat << EOF
#+--------------------------------------------------------------+ 
#|         === Welcome to Disable IPV6 ===                      | 
#+--------------------------------------------------------------+ 
#EOF
#echo "alias net-pf-10 off" >> /etc/modprobe.conf 
#echo "alias ipv6 off" >> /etc/modprobe.conf 
#/sbin/chkconfig --level 35 ip6tables off 
#echo "ipv6 is disabled!"
echo "disable selinux"
sed -i '/SELINUX/ s/enforcing/disabled/' /etc/selinux/config
echo "selinux is disabled,you must reboot!"
echo "Config vim"
sed -i "8 s/^/alias vi='vim'/" /root/.bashrc 
echo 'syntax on' >> /root/.vimrc 
echo "set nohlsearch" >> /root/.vimrc
#zh_cn 
#sed -i -e 's/^LANG=.*/LANG="en"/'   /etc/sysconfig/i18n
echo "init_ssh"
ssh_cf="/etc/ssh/sshd_config"
sed -i "s/#UseDNS yes/UseDNS no/" $ssh_cf 
sed -i 's/^GSSAPIAuthentication yes$/GSSAPIAuthentication no/' $ssh_cf 
sed -i '/^#PermitRoot/aPermitRootLogin without-password' $ssh_cf
sed -i '/^#Port 22/aPort 9617' $ssh_cf
mkdir /root/.ssh
cat >> /root/.ssh/authorized_keys << EOF
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDEzXdM/QI9t43vQ8KU0q+A6qXaFEQiiM7oXmgQW3s8IvA5IpyPxUbzo8W1lH0WbDoTnaP9SkRu51kLyOYDNMfCHrg1O4f5GewPitCBJd2Dvxl06oaFa/Km4dhl2YhEcBAlbn4LE3W/yzy0+WX67zIWQ1jVam/ViC3T7lAL5+mu5T3pbm2LEWrd6RInNz8yrt+KkfJgZns1A71wO4vEIYP9vfVGV+PmedbHQkxEYTAu9DL43rTQoIA7UH7JHTWmXrDo7Mpz4gvuTb/eiL+CTGK2eDNbNUhjJ6tdAqSV79cuGP/3dDWa9Sksm2Thq7tDdR419aaYdKWOHq6gCFkl2YSV root@localhost.localdomain
EOF
chmod og-rwx /root/.ssh
chmod og-rwx /root/.ssh/authorized_keys

#client 
echo "ssh is init is ok.............."


echo "opt inittab"
sed -i 's@id:5:initdefault:@id:3:initdefault:@' /etc/inittab

echo "open sshd port"
iptables -I INPUT -p tcp --dport 9617 -j ACCEPT
service iptables save

cat << EOF
+--------------------------------------------------------------+ 
|         === Welcome to Tunoff services ===                   | 
+--------------------------------------------------------------+ 
EOF
#for i in `ls /etc/rc3.d/S*` 
#do
#              CURSRV=`echo $i|cut -c 15-` 
#echo $CURSRV 
#case $CURSRV in
#          crond | irqbalance | microcode_ctl | network | random | sshd | syslog | local ) 
#      echo "Base services, Skip!"
#      ;; 
#      *) 
#          echo "change $CURSRV to off"
#          chkconfig --level 235 $CURSRV off 
#          service $CURSRV stop 
#      ;; 
#esac
#done


chkconfig bluetooth off
chkconfig sendmail off
chkconfig kudzu off
chkconfig nfslock off
chkconfig portmap off
chkconfig yum-updatesd off
chkconfig cups off
chkconfig hplip off
chkconfig ip6tables off
chkconfig iscsi off
chkconfig iscsid off
chkconfig isdn off
chkconfig smartd off
chkconfig postfix off
chkconfig lldpad off
chkconfig auditd off
chkconfig saslauthd  off
chkconfig  restorecond off
chkconfig  rdisc off
chkconfig  portreserve  off
chkconfig  netconsole  off
chkconfig  matahari-sysconfig  off
chkconfig atd off


cat << EOF
+-------------------------------------------------+
|          CentOS 6     optimizer is done         |
|   it's recommond to restart this server !       |
+-------------------------------------------------+
EOF
}


function opt_sys_c7(){
cat << EOF
+--------------------------------------------------------------+ 
|         === Welcome to Centos 7.x  System init ===           | 
+--------------------------------------------------------------+ 
+-------------------- by Ambrosial ----------------------------+ 
EOF
function yum_install(){
yum install net-tools nmap lrzsz wget epel-release p7zip openssl-devel vim bash-completion gcc gcc-c++ vim-enhanced unzip unrar sysstat -y
#Install EPEL repo
rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-2.el7.elrepo.noarch.rpm
wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
/usr/bin/yum makecache
echo "yum install ok"
}


function rsync_time(){
yum install chrony -y
service chronyd restart
echo "rsync time ok"
}


function file_descriptor(){
ulimit -SHn 102400
echo "ulimit -SHn 102400" >> /etc/rc.local
cat >> /etc/security/limits.conf << EOF
*           soft   nofile       65535
*           hard   nofile       65535
EOF
echo "file descriptor ok"
}


function disabled_selinux(){
sed -i 's/SELINUX=enforcing/SELINUX=disabled/'  /etc/selinux/config
setenforce 0
echo "disabled selinux ok"
}




function optimize_ssh(){
sed -i 's/^GSSAPIAuthentication yes$/GSSAPIAuthentication no/' /etc/ssh/sshd_config
sed -i 's/#UseDNS yes/UseDNS no/' /etc/ssh/sshd_config
sed -i '/^#PermitRoot/aPermitRootLogin without-password' /etc/ssh/sshd_config
sed -i '/^#Port 22/aPort 9617' /etc/ssh/sshd_config
mkdir /root/.ssh
cat >> /root/.ssh/authorized_keys << EOF
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDEzXdM/QI9t43vQ8KU0q+A6qXaFEQiiM7oXmgQW3s8IvA5IpyPxUbzo8W1lH0WbDoTnaP9SkRu51kLyOYDNMfCHrg1O4f5GewPitCBJd2Dvxl06oaFa/Km4dhl2YhEcBAlbn4LE3W/yzy0+WX67zIWQ1jVam/ViC3T7lAL5+mu5T3pbm2LEWrd6RInNz8yrt+KkfJgZns1A71wO4vEIYP9vfVGV+PmedbHQkxEYTAu9DL43rTQoIA7UH7JHTWmXrDo7Mpz4gvuTb/eiL+CTGK2eDNbNUhjJ6tdAqSV79cuGP/3dDWa9Sksm2Thq7tDdR419aaYdKWOHq6gCFkl2YSV root@localhost.localdomain
EOF
chmod og-rwx /root/.ssh
chmod og-rwx /root/.ssh/authorized_keys

echo "optimize ssh ok"
} 




function def_vim(){
echo 'alias vi=vim' >> /etc/profile
echo 'stty erase ^H' >> /etc/profile
echo "syntax on" >> /root/.vimrc 
echo "set nohlsearch" >> /root/.vimrc 
cat >> /root/.vimrc << EOF
set tabstop=4
set shiftwidth=4
set expandtab
syntax on
"set number
EOF
echo "optimize vim ok"
}


function InstallMaldet(){
#Install maldet  virus soft
cd /tmp/
/usr/bin/wget http://www.rfxn.com/downloads/maldetect-current.tar.gz
tar xf maldetect-current.tar.gz
cd maldetect-1.*.*/
./install.sh
maldet --scan-all /home
}


function InstallClamav(){
#Install Clamav virus soft
yum install zlib  zlib-devel
useradd clamav
mkdir -p /usr/local/clamav
mkdir -p /usr/local/clamav/logs
mkdir -p /usr/local/clamav/updata
cd /tmp/
wget http://www.clamav.net/downloads/production/clamav-0.100.1.tar.gz
tar xf clamav-0.100.1.tar.gz
cd clamav-0.100.1
./configure --prefix=/usr/local/clamav
make && make install
cp -r /tmp/clamav-0.100.1/clamscan /usr/local/clamav/
ln -s /usr/local/clamav/clamscan/clamscan /usr/clamscn
#Modify Config File
cd /usr/local/clamav/etc/
cp clamd.conf.sample  clamd.conf
cp freshclam.conf.sample  freshclam.conf
cd /usr/local/clamav/logs/
touch clamd.log
touch clamd.pid
touch freshclam.log
touch freshclam.pid
chown -R clamav:clamav /usr/local/clamav/logs
chown -R clamav:clamav /usr/local/clamav/updata
sed -i 's@Example@#Example@' /usr/local/clamav/etc/clamd.conf
sed -i 's@#LogFile /tmp/clamd.log@LogFile /usr/local/clamav/logs/clamd.log@' /usr/local/clamav/etc/clamd.conf
sed -i 's@#PidFile /var/run/clamd.pid@PidFile /usr/local/clamav/updata/clamd.pid@' /usr/local/clamav/etc/clamd.conf
sed -i 's@#DatabaseDirectory /var/lib/clamav@DatabaseDirectory /usr/local/clamav/updata@' /usr/local/clamav/etc/clamd.conf
sed -i 's@Example@#Example@' /usr/local/clamav/etc/freshclam.conf
sed -i 's@#DatabaseDirectory /var/lib/clamav@DatabaseDirectory /usr/local/clamav/updata@' /usr/local/clamav/etc/freshclam.conf
sed -i 's@#PidFile /var/run/freshclam.pid@PidFile /usr/local/clamav/updata/freshclam.pid@' /usr/local/clamav/etc/freshclam.conf
sed -i 's@#UpdateLogFile /var/log/freshclam.log@UpdateLogFile /usr/local/clamav/logs/freshclam.log@' /usr/local/clamav/etc/freshclam.conf
#Update 
/usr/local/clamav/bin/freshclam
exit 0 
echo "InstallMaldet OK"
}


#Core Variable opt
function optimize_core(){
cat << EOF >>/etc/sysctl.conf
net.ipv4.tcp_max_tw_buckets = 6000
net.ipv4.tcp_sack = 1
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_rmem = 4096        87380   4194304
net.ipv4.tcp_wmem = 4096        16384   4194304
net.ipv4.tcp_max_orphans = 3276800
net.core.wmem_default = 8388608
net.core.rmem_default = 8388608
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.core.netdev_max_backlog = 262144
net.ipv4.tcp_tw_recycle = 0
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_mem = 94500000 915000000 927000000
net.ipv4.tcp_fin_timeout = 1
net.ipv4.ip_local_port_range = 1024    65000
net.ipv4.tcp_keepalive_time = 30
net.ipv4.tcp_max_tw_buckets = 5000
net.ipv4.tcp_max_syn_backlog = 8192
net.ipv4.tcp_retrans_collapse = 0
net.ipv4.tcp_timestamps = 01
net.ipv4.tcp_syncookies = 1
kernel.msgmnb = 65536
kernel.msgmax = 65536
kernel.shmmax = 68719476736
kernel.shmall = 4294967296
EOF
sysctl -p
echo "optimize_core ok"
} 


function enable_rc_local(){
chmod +x /etc/rc.d/rc.local
systemctl   enable   rc-local.service
systemctl   start  rc-local.service
echo "enable_rc_local ok"
}

function open_fw_ports(){
firewall-cmd --zone=public --add-port=9617/tcp --permanent
firewall-cmd --reload
}

yum_install
rsync_time
file_descriptor
disabled_selinux
optimize_ssh
def_vim
#InstallMaldet
#InstallClamav
optimize_core
enable_rc_local
open_fw_ports


cat << EOF
+-------------------------------------------------+
|             CentOS 7  optimizer is done                 |
|   it's recommond to restart this server !       |
+-------------------------------------------------+
EOF
}




#MAIN
if [ ! -f /boot/opt_sys ];then
        touch /boot/opt_sys
        version=$(cat /etc/redhat-release | awk '{print $3}'|cut -d . -f 1)
        if [ "$version" = '6'  ];then
		    opt_sys_c6
	    else
		    opt_sys_c7
	    fi
else
cat << EOF
+--------------------------------------------------------------+ 
|         ===  Centos System  is already init ===                | 
+--------------------------------------------------------------+ 
EOF
fi

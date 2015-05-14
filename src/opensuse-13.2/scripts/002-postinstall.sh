#
# postinstall.sh
#

date > /etc/vagrant_box_build_time

# remove zypper package locks
rm -f /etc/zypp/locks

# speed-up remote logins
printf "%b" "
# added by packer postinstall.sh
UseDNS no
" >> /etc/ssh/sshd_config

# put shutdown command in path
ln -s /sbin/shutdown /usr/bin/shutdown

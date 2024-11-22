#!/bin/sh
PATH=$PATH:/sbin:/usr/sbin
export PATH

# ------------------------------------------------- #
#
# System 1,C,K,Y
# Move the emails that are sent to postmaster by "MAILER-DAEMON" to NAS directory automatically.
#
# By Phoenix Liu 2024/11/11
#
# ------------------------------------------------- #

# 多重起動防止
LOCK=/tmp/to-postmaster_move_to_NAS.lock
exec 44> $LOCK
flock --nonblock 44 || exit 0

dirPath=/mnt/storage/workdir/to-postmaster/$(date "+%Y%m%d")/

mkdir -p ${dirPath}

for i in "$(find /webmail/mqueue/run/ -mmin +30 -type f)";do
    if [ "$(fuser $i 2>/dev/null)" == "" ]; then
        if [ -f $i ] && [ "$(head -10 $i|egrep -B 10 '^Rpostmaster@cm([a-z])?\.cybermail\.jp'|egrep '^F$')" ]; then
            mv $i ${dirPath}
        fi
    fi
done

# LOCK開放
/bin/rm $LOCK
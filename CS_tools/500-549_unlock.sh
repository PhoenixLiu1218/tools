#!/bin/sh
PATH=$PATH:/sbin:/usr/sbin
export PATH

# 500ツールを解除
if [ "$(find /webmail/extra_tools/ -type f -mmin +10 -name "cgi_downfile500549_check.lck")" ]; then
    rm -f /webmail/extra_tools/cgi_downfile500549_check.lck
else
    exit 0
fi
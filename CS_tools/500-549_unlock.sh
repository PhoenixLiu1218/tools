#!/bin/sh
PATH=$PATH:/sbin:/usr/sbin
export PATH

lckFile=/webmail/extra_tools/cgi_downfile500549_check.lck
tmpFile=/tmp/cgi_downfile500549_check.lock

# 500ツールを解除
if [ -f "${tmpFile}" ]; then
    exit 0
else
    rm ${lckFile}
fi
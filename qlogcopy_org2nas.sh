#!/bin/sh
#
# command      : qlogcopy_org2nas.sh <logdate(ex:20241015)>
# author       : PFU suzuki
# created date : 2024/11/xx
#

declare -A mgsp=(
    ["mgspc01"]="172.23.5.144"
    ["ServerB"]="172.20.34.211"
)

#check ipaddress
name=`uname -n`
ip=${mgsp[${name}]}

#check argument
([ -z "$1" ] || [[ ! "$1" =~ [0-9]{8} ]] || [ "${#1}" -gt 8 ] ) && echo "argumment error" && exit

#get restore-date
arg="$1"
r_year="${arg:0:4}"
r_year_short="${arg:2:2}"
r_month="${arg:4:2}"
r_day="${arg:6:2}"

#sample -> 20241015
r_date_long="${r_year}${r_month}${r_day}"

#sample -> 241015
r_date="${r_year_short}${r_month}${r_day}"

#sample -> 2024_10
r_date_ym="${r_year}_${r_month}"

#def work directories
###workdir_base="/mnt/storage/workdir/${r_date}_qlog"
workdir_base="/var/tmp/mnt/storage/workdir/${r_date}_qlog/${ip}"
workdir_in="${workdir_base}/in"
workdir_ou="${workdir_base}/ou"
workdir_mgsmtpd="${workdir_base}/mgsmtpd"

#def archivedir
archivedir_base="/mailgates/qlogs_archive/$ip/${r_date_ym}"
archivedir_in="${archivedir_base}/mgmailerd_in"
archivedir_ou="${archivedir_base}/mgmailerd_ou"
archivedir_mgsmtpd="${archivedir_base}/mgsmtpd"

#[ ! -d $workdir_base ] && echo "not exit $workdir_base." && exit
[ ! -d $archivedir_base ] && echo "not exit $archivedir_base." && exit


#make workdir
mkdir -p ${workdir_in}
mkdir -p ${workdir_ou}
mkdir -p ${workdir_mgsmtpd}

#pre
echo "---archivedir-----------------------------"
ls -l ${archivedir_base}/*/*.${r_date}*

#copy archivelog
#in
cp -p ${archivedir_in}/bec.log.${r_date}* ${workdir_in}
cp -p ${archivedir_in}/infect.log.${r_date}* ${workdir_in}
cp -p ${archivedir_in}/normal.log.${r_date}* ${workdir_in}
cp -p ${archivedir_in}/other.log.${r_date}* ${workdir_in}
cp -p ${archivedir_in}/spam.log.${r_date}* ${workdir_in}
cp -p ${archivedir_in}/audit.log.${r_date}* ${workdir_in}

#out
cp -p ${archivedir_ou}/bec.log.${r_date}* ${workdir_ou}
cp -p ${archivedir_ou}/infect.log.${r_date}* ${workdir_ou}
cp -p ${archivedir_ou}/normal.log.${r_date}* ${workdir_ou}
cp -p ${archivedir_ou}/other.log.${r_date}* ${workdir_ou}
cp -p ${archivedir_ou}/spam.log.${r_date}* ${workdir_ou}
cp -p ${archivedir_ou}/audit.log.${r_date}* ${workdir_ou}

#mgsmtpd
cp -p ${archivedir_mgsmtpd}/infor.log.${r_date}* ${workdir_mgsmtpd}

#post
echo "---workdir-----------------------------"
ls -l ${workdir_base}/*/*.${r_date}*



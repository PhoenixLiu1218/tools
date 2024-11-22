#!/bin/sh
#
# command      : qlogcopy_nas2dst.sh <logdate(ex:20241015)>
# author       : PFU suzuki
# created date : 2024/11/xx

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

#def workdir_base
###workdir_base="/mnt/storage/workdir/${r_date}_qlog"
workdir_base="/var/tmp/mnt/storage/workdir/${r_date}_qlog"

#def copydir_base
###copydir_base="/mailgates/qlogs_archive"
copydir_base="/var/tmp/mailgates/qlogs_archive"

[ ! -d $workdir_base ] && echo "not exit $workdir_base." && exit
[ ! -d $copydir_base ] && echo "not exit $copydir_base." && exit

#check logdate
chkdate="${r_year}/${r_month}/${r_day}"
chk_flag=""
chk_flag2=""

chk_flag="$( zgrep -v "^$chkdate" ${workdir_base}/*/*/*${r_date}.gz )"
list=`ls ${workdir_base}/*/*/*${r_date}* |grep -v .gz`
if [ "$list" != "" ];then 
  chk_flag2=`\grep -vH "^$chkdate" "$list" `
fi 

if [ "$chk_flag" != "" -o  "$chk_flag2" != "" ];then
  echo "ERROR:logdate irregular"
  echo "$chk_flag $chk_flag2"
  exit
fi

#ls ${workdir_base}/*/*/*${r_date}.gz| while read chkfile ;do
#  [[ $chkdate == $(zcat $chkfile |head -c 10) ]] || chk_flag=1  
#done
#
#ls ${workdir_base}/*/*/*${r_date}*|grep -v *.gz| while read chkfile2 ;do
# [[ $chkdate == $(zcat $chkfile2 |head -c 10) ]] || chk_flag=1  
#done

#[[ $chk_flag ne 0]] && echo "logdate irregular" && exit

#pre
echo "---copydir(pre)-----------------------------"
ls -l ${copydir_base}/*/${r_date_ym}/*/*${r_date}*

#get workdir/$ip and loop
ls ${workdir_base} |while read cur_dir; do

  cur_ip=${cur_dir##*/}

  ##in
  \cp -pf ${workdir_base}/${cur_ip}/in/bec.log.${r_date}* ${copydir_base}/${cur_ip}/${r_date_ym}/mgmailerd_in/
  \cp -pf ${workdir_base}/${cur_ip}/in/infect.log.${r_date}* ${copydir_base}/${cur_ip}/${r_date_ym}/mgmailerd_in/
  \cp -pf ${workdir_base}/${cur_ip}/in/normal.log.${r_date}* ${copydir_base}/${cur_ip}/${r_date_ym}/mgmailerd_in/
  \cp -pf ${workdir_base}/${cur_ip}/in/other.log.${r_date}* ${copydir_base}/${cur_ip}/${r_date_ym}/mgmailerd_in/
  \cp -pf ${workdir_base}/${cur_ip}/in/spam.log.${r_date}* ${copydir_base}/${cur_ip}/${r_date_ym}/mgmailerd_in/
  \cp -pf ${workdir_base}/${cur_ip}/in/audit.log.${r_date}* ${copydir_base}/${cur_ip}/${r_date_ym}/mgmailerd_in/

  #ou
  \cp -pf ${workdir_base}/${cur_ip}/ou/infect.log.${r_date}* ${copydir_base}/${cur_ip}/${r_date_ym}/mgmailerd_ou/
  \cp -pf ${workdir_base}/${cur_ip}/ou/normal.log.${r_date}* ${copydir_base}/${cur_ip}/${r_date_ym}/mgmailerd_ou/
  \cp -pf ${workdir_base}/${cur_ip}/ou/other.log.${r_date}* ${copydir_base}/${cur_ip}/${r_date_ym}/mgmailerd_ou/
  \cp -pf ${workdir_base}/${cur_ip}/ou/spam.log.${r_date}* ${copydir_base}/${cur_ip}/${r_date_ym}/mgmailerd_ou/
  \cp -pf ${workdir_base}/${cur_ip}/ou/audit.log.${r_date}* ${copydir_base}/${cur_ip}/${r_date_ym}/mgmailerd_ou/

  #mgsmtpd
  \cp -pf ${workdir_base}/${cur_ip}/mgsmtpd/infor.log.${r_date}* ${copydir_base}/${cur_ip}/${r_date_ym}/mgsmtpd/

done

#post
echo "---copydir(post)-----------------------------"
 ls -l ${copydir_base}/*/${r_date_ym}/*/*${r_date}*





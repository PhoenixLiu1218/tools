#!/bin/sh
PATH=$PATH:/sbin:/usr/sbin
export PATH

# ------------------------------------------------- #
#
# 1. Make a copy qlog source file to NAS before they are archived everyday.
# 2. Calculate the file size of step1 files.
# 3. Put the number that we got by step2 into some text file or something else.
# 4. Make sure the user can confirm file size of qlog, insert a comment to backlog(CLOUD-12509).
# 5. Erase the qlog files from NAS.
# 6. Back to step1 until the issue happened.
#
# By Phoenix Liu 2024/10/29
#
# ------------------------------------------------- #

# Constant values
readonly backlog_API=NrWuZrGRlIzyppkaUHcfn4vGEMzu9XFPzbMNHV8YfkQVnRPVRhsMjP9CzEhP6d2e
readonly commentFileDir=/mnt/storage/workdir/qlog_source/fileSize.txt
readonly hostnameStr=$(hostname -s)


# convert ip to numbers
# ip_to_number() {
#     local IFS=.
#     local ip=($1)
#     echo $(( (${ip[0]} << 24) + (${ip[1]} << 16) + (${ip[2]} << 8) + ${ip[3]} ))
# }

# # create a array for NIC IP
# dynamic_array=()
# for i in $(ip -o -4 addr show | awk '{print $2 " " $4}'|sed "s/^.*\s//g"|sed "s/\/.*$//g");do
#     # echo $i
#     dynamic_array+=("$i")
# done

# # find the management IP
# defaultIP=${dynamic_array[0]}
# managementIP=0

# for i in "${dynamic_array[@]}";do
#     if (( $(ip_to_number $i) > $(ip_to_number $defaultIP) )); then
#         defaultIP=$i
#         managementIP=$defaultIP
#     fi
# done

NIC_Array=()
for i in $(\ip -o -4 addr show | awk '{print $2 " " $4}'|sed "s/^.*\s//g"|sed "s/\/.*$//g");do
    # echo $i
    NIC_Array+=("$i")
done

managementIP=""

folder_Array=()
for i in $(ls /webmail/qlogs_archive |egrep "192|172");do
    # echo $i
    folder_Array+=("$i")
done

for i in "${NIC_Array[@]}";do
    for k in "${folder_Array[@]}";do
        if [[ "$i" == "$k" ]];then
            managementIP=$i
        fi
    done
done

# ---------------------------STEP1----------------------------
# Create the working directory, and make the copy for qlog files
mkdir -p /mnt/storage/workdir/qlog_source/logs/
mkdir -p /mnt/storage/workdir/qlog_source/$(date "+%Y%m%d")/$managementIP
\cp -rpf /webmail/mg/qlogs/ /mnt/storage/workdir/qlog_source/$(date "+%Y%m%d")/$managementIP/


# ---------------------------STEP2----------------------------
# Get the file size of qlog files
lastChar=${hostnameStr: -1}
second=$((${lastChar}+${lastChar}*${lastChar}))

sleep $second
fileSize=$(du -shm /mnt/storage/workdir/qlog_source/$(date "+%Y%m%d")/$managementIP/qlogs/|cut -f 1)


# ---------------------------STEP3----------------------------
# Append data to the file that we need to monitor
echo "$hostnameStr ${fileSize}M" >>  /mnt/storage/workdir/qlog_source/fileSize.txt


# ---------------------------STEP4----------------------------
# Insert a comment to backlog (only need execute on the bigget number of servers)
newComment=""

while read line
do
    if [ -n "$newComment" ];then
        newComment=${comment}'<br>'$line
    else
        newComment='<@U517343> <@U505351> <br><br>systemF<br>'$line
    fi
    # echo $newComment
    comment=$newComment
    # comment="$comments $line\n"
done < "$commentFileDir"

RESPONSE=$(curl -X POST \
     -H "Content-Type: application/x-www-form-urlencoded" \
     -d "content=${newComment}" \
"https://cybersol.backlog.jp/api/v2/issues/CLOUD-12509/comments?apiKey=${backlog_API}")

if [ $? -eq 0 ]; then
   echo "[$(date "+%m/%d %H:%M:%S")] Success: $RESPONSE" >> /mnt/storage/workdir/qlog_source/logs/$(date "+%Y%m%d")_addcomment.log
else
   echo "[$(date "+%m/%d %H:%M:%S")] Error: Failed to send request" >> /mnt/storage/workdir/qlog_source/logs/$(date "+%Y%m%d")_addcomment.log
fi


# ---------------------------STEP5----------------------------
# Erase the qlog files from NAS. (only need execute on the bigget number of servers)
find /mnt/storage/workdir/qlog_source/ -mindepth 1 -maxdepth 1 -type d -mtime +3 -exec rm -rf {} \;
echo -n "" > /mnt/storage/workdir/qlog_source/fileSize.txt
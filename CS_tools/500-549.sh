#!/bin/sh
PATH=$PATH:/sbin:/usr/sbin
export PATH

# lckファイルが存在する場合、即終了
if [ -f "/webmail/extra_tools/cgi_downfile500549_check.lck" ]; then
    exit 0
fi

# 多重起動防止
LOCK=/tmp/cgi_downfile500549_check.lock
exec 44> $LOCK
flock --nonblock 44 || exit 0


# グローバル変数
LOOKBACK_MINUTES=10 #5以上を設定すること
workdir=/mnt/storage/workdir/cgi_downfile500549_check_20240809/workdir/`date "+%Y%m%d"`
mqueueLog=/webmail/mqueue/log/`hostname -s`_mlog1.log
mqueue2Log=/webmail/mqueue2/log/`hostname -s`_mlog1.log
LATEST_LOGFILE=$(ls -t /webmail/httpd/logs/access_log.* | head -n 1)
LOGDIR=/mnt/storage/workdir/cgi_downfile500549_check_20240809/$(date "+%Y%m%d")
LOGFILE=${LOGDIR}/cgi_downfile500549_check_$(uname -n|cut -d. -f1)_$(date "+%Y%m%d").log
moveFlag=0


# 最後の「/cgi-bin/downfile/ ... 500 549」エラーの時刻を取得
LASTERROR="$(egrep 'cgi-bin\/downfile.* 500 549' $LATEST_LOGFILE | tail -1 | cut -d' ' -f4 | cut -c 14-)"
mkdir -p $LOGDIR
echo "[$(date "+%Y%m%d %H:%M:%S")] check $LATEST_LOGFILE : $LASTERROR" >> $LOGFILE


# エラー時刻が空欄:何もしない
# エラー時刻がある:以下を実行
if [ -n "$LASTERROR" ]; then
    # 比較用の現在時刻をUNIXTIMEで取得、エラー時刻もUNIXTIMEへ変換
    ERROR_TIME=$(date -d "$LASTERROR" +%s)
    LOOKBACK_TIME=$(($(date +%s) - LOOKBACK_MINUTES * 60))

    # エラー時刻が直近(設定値以内)なら以下を実行
    if [ $ERROR_TIME -ge $LOOKBACK_TIME ]; then

        # restartshm 実行してその実行した旨の記録をつける。5分待つ
        /webmail/tools/restartshm
        touch /webmail/extra_tools/cgi_downfile500549_check.lck

        echo "[$(date "+%Y%m%d %H:%M:%S")] restartshm" >> $LOGFILE

        queues=$(ls -1 /webmail/mqueue/run/)
        queues2=$(ls -1 /webmail/mqueue2/run/)
        sleep 10

        # 古いファイルがあるかどうかを確認
        for fileName in ${queues}; do
            if [ -n "$(ls -1 /webmail/mqueue/run/ | grep ${fileName})" ]; then
                moveFlag=1
                break
            fi
        done

        for fileName in ${queues2}; do
            if [ -n "$(ls -1 /webmail/mqueue2/run/ | grep ${fileName})" ]; then
                moveFlag=1
                break
            fi
        done
    fi
fi


# moveFlagがtrueの場合、キューファイルをworkdirに移動
if [ "${moveFlag}" -ne "0" ];then

    mkdir -p ${workdir}/mqueue/ ${workdir}/mqueue2/ ${workdir}/processed/mqueue/ ${workdir}/processed/mqueue2/

    mqueue=$(find /webmail/mqueue/run -type f|xargs -i basename {})
    mqueue2=$(find /webmail/mqueue2/run -type f|xargs -i basename {})
    sleep 10

    echo -n "[$(date "+%Y%m%d %H:%M:%S")] moved(mqueue ):" >> $LOGFILE

    # mqueue
    for FILES in ${mqueue};do
        # fuser確認で使用状況を確認、なし ⇒ 真
        if [ ! -n "$(fuser /webmail/mqueue/run/${FILES} 2>/dev/null)" ];then
            # logで確認、なし ⇒ 真
            if [ ! -n "$(fgrep ${FILES} ${mqueueLog})" ];then
            # if [ ! -n "$(fgrep ${FILES} /webmail/mqueue/log/mailerd.log)" ];then
                mv /webmail/mqueue/run/${FILES} ${workdir}/mqueue/ 2>/dev/null
                echo -n " ${FILES}" >> "$LOGFILE"
            else
                touch /tmp/cgi_downfile500549_check.tmp
            fi
        fi
    done
    echo "" >> "$LOGFILE"

    echo -n "[$(date "+%Y%m%d %H:%M:%S")] moved(mqueue2):" >> $LOGFILE

    # mqueue2
    for FILES in ${mqueue2};do
        if [ ! -n "$(fuser /webmail/mqueue2/run/${FILES} 2>/dev/null)"" ];then
            if [ ! -n "$(fgrep ${FILES} ${mqueue2Log})" ];then
                mv /webmail/mqueue2/run/${FILES} ${workdir}/mqueue2/ 2>/dev/null
                echo -n " ${FILES}" >> "$LOGFILE"
            else
                touch /tmp/cgi_downfile500549_check.tmp
            fi
        fi
    done
    echo "" >> "$LOGFILE"
fi


# workdirの配下は空でない場合、ファイルをwaitに移動
if [ "$(find ${workdir}/mqueue* -mindepth 1 -maxdepth 1 -type f |wc -l)" -gt "0" ];then

    cp -p ${workdir}/mqueue/* /webmail/mqueue/wait/
    cp -p ${workdir}/mqueue2/* /webmail/mqueue2/wait/

    mv ${workdir}/mqueue/* ${workdir}/processed/mqueue/
    mv ${workdir}/mqueue2/* ${workdir}/processed/mqueue2/
fi

# LOCK開放
/bin/rm $LOCK
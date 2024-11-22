#!/bin/bash

function usage {
  cat <<EOM
Usage: $(basename "$0") [OPTION]...

  This is the tool that can let Webmail user to change 
  user's userLevel without log in to the Cybermail admin panel.

  -d    Domain name (example.com)
  -u    UserID      (UserID ONLY)

EOM
  
  exit 2
}

function errorMessage {
  echo "Please provide the valid argument and data!"
  echo "Try sh '$(basename "$0") --help' for more information."
  exit 1
}

# ドメインとユーザーを指定
DOMAIN=
USER=

# レベルの範囲を指定
START_LEVEL=1
END_LEVEL=30

while getopts ":d:u:h" flag;
do
    case "$flag" in
        d)
            DOMAIN="${OPTARG}"
            ;;
        u)
            USER="${OPTARG}"
            ;;
        h|help)
            usage
            ;;
    esac
done

# ドメインDIRを取得
USERDIR=$(find /webmail/usr/ -type f -iname $USER |grep -oE .*\/$DOMAIN\/$USER$)
if [ "$USERDIR" = "" ]; then
  errorMessage
fi

# 変更前のレベルを取得
FORMER_LEVEL=$(/webmail/tools/userexport $DOMAIN |grep $USER |cut -d ',' -f 5 |sed "s/\"//g")

# レベルを1から30までループ
for ((LEVEL=$START_LEVEL; LEVEL<=$END_LEVEL; LEVEL++)); do
  # 「Disable」かどうかを確認
  if [ $(/webmail/tools/domain_privilege_tool -c dump -d $DOMAIN -l $LEVEL |grep -ie .*LOGIN |egrep -v 'PKI|WEB' |awk '{print $2}' |grep 'Disable' |wc -l) == 3 ]; then
    # 「Enable」かどうかを確認
    if [ $(/webmail/tools/domain_privilege_tool -c dump -d $DOMAIN -l $LEVEL |grep 'WEB' |awk '{print $2}') == Enable ]; then
      #PRIV_POP3_LOGIN PRIV_SMTP_LOGIN PRIV_IMAP4_LOGINがDISABLE && PRIV_WEB_LOGINがENABLEの場合
      LEVEL_TO_SET=$LEVEL

      #ユーザーレベルを設定
      /webmail/tools/importuser au $USER@$DOMAIN,,,,$LEVEL_TO_SET,
      echo -e '\n'$USER@$DOMAIN"'s userLevel has been changed successfully!\n"
      echo 'Former userLevel:'$FORMER_LEVEL
      echo -e 'Current userLevel:'$LEVEL_TO_SET'\n'
      break
    fi

  elif [ $LEVEL == 30 ] && [ $PRIV_SMTP_LOGIN_STATUS == Enable ]; then
    echo "All userLevel has been set to ENABLE"
  fi
  
done
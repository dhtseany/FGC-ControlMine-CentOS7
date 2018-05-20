#/bin/bash
CURRENT_USER="ssnell"
SERVER=$1
tmpdir=/tmp/fgc

ssh -q -t $CURRENT_USER@$SERVER "sudo systemctl disable fantasygoldd && sudo systemctl stop fantasygoldd"
ssh -q -t $CURRENT_USER@$SERVER "sudo rm /etc/systemd/system/fantasygoldd.service"
ssh -q -t $CURRENT_USER@$SERVER "sudo userdel -r FantasyGold"
ssh -q -t $CURRENT_USER@$SERVER "rm -rf /tmp/fgc"
#!/bin/bash

CURRENT_USER=$USER
SERVER=$1
TMP_DIR=/tmp/fgc
F_USER="FantasyGold"

if [[ -z $2 ]];
    then
        echo "Control Mine v1.0 for CentOS 7."
        echo "Usage:"
        echo "$ ./newnode.sh <server> <action>"
        exit 0
fi

if [[ ("$2" == "reboot") ]];
    then
        clear
        echo "WARNING! You are about to reboot the remote node!"
        read -e -p "Proceed? [y/N] : " START_UPGRADE

        if [[ ("$START_UPGRADE" == "y" || "$START_UPGRADE" == "Y") ]];
            then
                echo "Rebooting remote node..."
                ssh -q -t $CURRENT_USER@$SERVER "sudo reboot"
                exit 0
        fi
fi

# Check the status of a remote node.
if [[ ("$2" == "status") ]];
    then
        clear
        echo "Node Status [$SERVER]:"
        echo "================================================="
        ssh -q -t $CURRENT_USER@$SERVER "sudo su -c '/usr/local/bin/fantasygold-cli masternode status' $F_USER"
        echo "================================================="

        echo "MNSync Status [$SERVER]:"
        echo "================================================="
        ssh -q -t $CURRENT_USER@$SERVER "sudo su -c '/usr/local/bin/fantasygold-cli mnsync status' $F_USER"
        echo "================================================="
        exit 0
fi

if [[ ("$2" == "localinstall") ]];
    then
        clear
        echo "This process will install all build and runtime dependancies and will"
        echo "install FantasyGold-core from the upstream latest in src."
        read -e -p "Proceed? [y/N] : " START_LOCALINSTALL

        if [[ ("$START_LOCALINSTALL" == "y" || "$START_LOCALINSTALL" == "Y") ]];
            then
                echo "     "
                echo "============================================="
                echo "Installing FantasyGold-Core from src..."
                echo "============================================="
                echo "     "
                mkdir ~/ControlMine
                cd ~/ControlMine 
                git clone https://github.com/FantasyGold/FantasyGold-Core.git
                ./autogen.sh
                ./configure
                make
                sudo make install
            else
                echo "User aborted process."
                exit 1
        fi
fi

if [[ ("$2" == "upgradesrc") ]];
    then
        clear
        echo "WARNING! You are about to uninstall FantasyGold-Core from the remote node!"
        echo "You are about to remove the existing package and upgrade to the latest in src."
        echo "This action will not remove your settings, nor will it install new users, set conf options, etc."
        echo "This process will only effect the core package, and will rebuild it from source."
        read -e -p "Proceed? [y/N] : " START_UPGRADE

        if [[ ("$START_UPGRADE" == "y" || "$START_UPGRADE" == "Y") ]];
            then
                echo "Stopping fantasygoldd service..."
                ssh -q -t $CURRENT_USER@$SERVER "sudo systemctl disable fantasygoldd && sudo systemctl stop fantasygoldd"
                echo "Removing files..."
                ssh -q -t $CURRENT_USER@$SERVER "rm -rf /home/$CURRENT_USER/dev/FantasyGold-Core"
                ssh -q -t $CURRENT_USER@$SERVER "rm -rf /home/$CURRENT_USER/dev"
                ssh -q -t $CURRENT_USER@$SERVER "sudo rm /usr/local/bin/fantasygold-cli"
                ssh -q -t $CURRENT_USER@$SERVER "sudo rm /usr/local/bin/fantasygoldd"
                ssh -q -t $CURRENT_USER@$SERVER "sudo rm /usr/local/bin/fantasygold-tx"
                ssh -q -t $CURRENT_USER@$SERVER "sudo rm /usr/local/bin/test_fantasygold"
                clear
                echo "All existing files have been removed... Uninstall complete."
                sleep 1

                echo "     "
                echo "============================================="
                echo "Installing FantasyGold-Core from src..."
                echo "============================================="
                echo "     "
                ssh -q -t $CURRENT_USER@$SERVER "mkdir /home/$CURRENT_USER/dev"
                ssh -q -t $CURRENT_USER@$SERVER "cd /home/$CURRENT_USER/dev && git clone https://github.com/FantasyGold/FantasyGold-Core.git"
                # git clone https://github.com/FantasyGold/FantasyGold-Core.git
                ssh -q -t $CURRENT_USER@$SERVER "cd /home/$CURRENT_USER/dev/FantasyGold-Core/ && ./autogen.sh"
                ssh -q -t $CURRENT_USER@$SERVER "cd /home/$CURRENT_USER/dev/FantasyGold-Core/ && ./configure"
                ssh -q -t $CURRENT_USER@$SERVER "cd /home/$CURRENT_USER/dev/FantasyGold-Core/ && make"
                ssh -q -t $CURRENT_USER@$SERVER "cd /home/$CURRENT_USER/dev/FantasyGold-Core/ && sudo make install"
                ssh -q -t $CURRENT_USER@$SERVER "sudo systemctl enable fantasygoldd && sudo systemctl start fantasygoldd"
            else
                echo "User aborted process."
                exit 1
        fi
fi

if [[ ("$2" == "uninstall") ]];
    then
        clear
        read -e -p "WARNING! You are about to uninstall FantasyGold-Core from the remote node. Continue? [y/N] : " UNINSTALL_Q_R

        if [[ ("$UNINSTALL_Q_R" == "y" || "$UNINSTALL_Q_R" == "Y") ]];
            then
                echo "Stopping fantasygoldd service..."
                ssh -q -t $CURRENT_USER@$SERVER "sudo systemctl disable fantasygoldd && sudo systemctl stop fantasygoldd"
                echo "Removing files..."
                ssh -q -t $CURRENT_USER@$SERVER "rm -rf /home/$CURRENT_USER/dev/FantasyGold-Core"
                ssh -q -t $CURRENT_USER@$SERVER "rm -rf /home/$CURRENT_USER/dev"
                ssh -q -t $CURRENT_USER@$SERVER "sudo rm /usr/local/bin/fantasygold-cli"
                ssh -q -t $CURRENT_USER@$SERVER "sudo rm /usr/local/bin/fantasygoldd"
                ssh -q -t $CURRENT_USER@$SERVER "sudo rm /usr/local/bin/fantasygold-tx"
                ssh -q -t $CURRENT_USER@$SERVER "sudo rm /usr/local/bin/test_fantasygold"
                clear
                echo "All existing files have been removed... Uninstall complete."
                exit 0
            else
                echo "User aborted process."
                exit 1
fi

# If $2 is set to deps install dependancies
if [[ ("$2" == "deps") ]];
    then
        clear
        echo "User chose to install deps...."
        ssh -q -t $CURRENT_USER@$SERVER "sudo yum install wget git sudo nano unzip autoconf automake libtool gcc-c++ libdb4-devel libdb4 libdb4-cxx libdb4-cxx-devel db4-utils boost-devel openssl-devel miniupnpc bind-utils libevent-devel"
        exit 0
fi

# "Install" (or honestly just copy from fgcmaster) the precompiled binaries to the remote system
if [[ ("$2" == "install") ]];
    then
        clear
        echo "User chose to install bins...."
        ssh -q -t $CURRENT_USER@$SERVER "rm -rf $TMP_DIR"
        ssh -q -t $CURRENT_USER@$SERVER "mkdir -p $TMP_DIR/pkg/usr/local/bin/"
        scp /usr/local/bin/fantasygold-cli $CURRENT_USER@$SERVER:$TMP_DIR/pkg/usr/local/bin/fantasygold-cli
        scp /usr/local/bin/fantasygoldd $CURRENT_USER@$SERVER:$TMP_DIR/pkg/usr/local/bin/fantasygoldd
        scp /usr/local/bin/fantasygold-tx $CURRENT_USER@$SERVER:$TMP_DIR/pkg/usr/local/bin/fantasygold-tx
        scp /usr/local/bin/test_fantasygold $CURRENT_USER@$SERVER:$TMP_DIR/pkg/usr/local/bin/test_fantasygold
        ssh -q -t $CURRENT_USER@$SERVER "sudo cp $TMP_DIR/pkg/usr/local/bin/fantasygold-cli /usr/local/bin/fantasygold-cli"
        ssh -q -t $CURRENT_USER@$SERVER "sudo cp $TMP_DIR/pkg/usr/local/bin/fantasygoldd /usr/local/bin/fantasygoldd"
        ssh -q -t $CURRENT_USER@$SERVER "sudo cp $TMP_DIR/pkg/usr/local/bin/fantasygold-tx /usr/local/bin/fantasygold-tx"
        ssh -q -t $CURRENT_USER@$SERVER "sudo cp $TMP_DIR/pkg/usr/local/bin/test_fantasygold /usr/local/bin/test_fantasygold"
        exit 0
fi

if [[ ("$2" == "masternode") ]];
    then
        clear
        echo "User chose to compile the local masternode bins...."
        source ./uninstall.sh
        ssh -q -t $CURRENT_USER@$SERVER "mkdir /home/$CURRENT_USER/dev"
        ssh -q -t $CURRENT_USER@$SERVER "cd /home/$CURRENT_USER/dev && git clone https://github.com/FantasyGold/FantasyGold-Core.git"
        ssh -q -t $CURRENT_USER@$SERVER "cd /home/$CURRENT_USER/dev/FantasyGold-Core/ && ./autogen.sh"
        ssh -q -t $CURRENT_USER@$SERVER "cd /home/$CURRENT_USER/dev/FantasyGold-Core/ && ./configure"
        ssh -q -t $CURRENT_USER@$SERVER "cd /home/$CURRENT_USER/dev/FantasyGold-Core/ && make"
        ssh -q -t $CURRENT_USER@$SERVER "cd /home/$CURRENT_USER/dev/FantasyGold-Core/ && sudo make install"
        exit 0
fi

if [[ ("$2" == "adopt") ]];
    then
        clear
        echo "User chose to adpot a new remote node...."
        scp -q $CURRENT_USER@$n:/home/$CURRENT_USER/fsg_c/fantasygold.conf.old $TMP_DIR/$n/fantasygold.conf.old
        ssh -q -t $CURRENT_USER@$SERVER "mkdir -p $TMP_DIR"
        ssh -q -t $CURRENT_USER@$SERVER "sudo adduser -M -r $F_USER"
        RPCUSER=`ssh -q -t $CURRENT_USER@$SERVER "cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 12 | head -n 1"`
        RPCPASSWORD=`ssh -q -t $CURRENT_USER@$SERVER "cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1"`
        PUBLIC_IP=`ssh -q -t $CURRENT_USER@$SERVER "dig +short myip.opendns.com @resolver1.opendns.com"`
        INTERNAL_IP=`ssh -q -t $CURRENT_USER@$SERVER "hostname --ip-address"`

        read -e -p "Masternode Private Key [none]: " KEY

        read -e -p "Choose tcp port for node [57810] : " NODEPORT_Q_R

        if [[ ( -z "$NODEPORT_Q_R" ) ]];
            then
                NODEPORT="57810"
            else
                NODEPORT=$NODEPORT_Q_R
        fi

        ssh -q -t $CURRENT_USER@$SERVER "
        cat > $TMP_DIR/fantasygoldd.service << EOL
        [Unit]
        Description=fantasygoldd
        After=network.target
        [Service]
        Type=forking
        User=$F_USER
        WorkingDirectory=/home/FantasyGold
        ExecStart=/usr/local/bin/fantasygoldd -conf=/home/FantasyGold/.fantasygold/fantasygold.conf -datadir=/home/FantasyGold/.fantasygold
        ExecStop=/usr/local/bin/fantasygold-cli -conf=/home/FantasyGold/.fantasygold/fantasygold.conf -datadir=/home/FantasyGold/.fantasygold stop
        Restart=on-abort
        [Install]
        WantedBy=multi-user.target

        EOL
        "

        ssh -q -t $CURRENT_USER@$SERVER "touch $TMP_DIR/fantasygold.conf"
        ssh -q -t $CURRENT_USER@$SERVER "
        cat > $TMP_DIR/fantasygold.conf << EOL
        rpcuser=${RPCUSER}
        rpcpassword=${RPCPASSWORD}
        rpcallowip=127.0.0.1
        listen=1
        server=1
        daemon=1
        logtimestamps=1
        maxconnections=256
        externalip=${PUBLIC_IP}
        bind=$INTERNAL_IP:$NODEPORT
        masternodeaddr=${PUBLIC_IP}
        masternodeprivkey=${KEY}
        masternode=1
        EOL
        "

        ssh -q -t $CURRENT_USER@$SERVER "sudo mkdir -p /home/$F_USER/.fantasygold"
        ssh -q -t $CURRENT_USER@$SERVER "sudo chown -R $F_USER:$F_USER /home/$F_USER"
        ssh -q -t $CURRENT_USER@$SERVER "sudo mv $TMP_DIR/fantasygold.conf /home/$F_USER/.fantasygold/fantasygold.conf"
        ssh -q -t $CURRENT_USER@$SERVER "sudo chown -R $F_USER:$F_USER /home/$F_USER/.fantasygold"
        ssh -q -t $CURRENT_USER@$SERVER "sudo chmod 600 /home/$F_USER/.fantasygold/fantasygold.conf"

        ssh -q -t $CURRENT_USER@$SERVER "sudo mv $TMP_DIR/fantasygoldd.service /etc/systemd/system/fantasygoldd.service"
        ssh -q -t $CURRENT_USER@$SERVER "sudo chown root:root /etc/systemd/system/fantasygoldd.service"
        ssh -q -t $CURRENT_USER@$SERVER "sudo systemctl daemon-reload"
        ssh -q -t $CURRENT_USER@$SERVER "sudo systemctl enable fantasygoldd"
        ssh -q -t $CURRENT_USER@$SERVER "sudo systemctl start fantasygoldd"
        ssh -q -t $CURRENT_USER@$SERVER "sudo systemctl status fantasygoldd"
        clear

        echo "Your masternode is syncing. Please wait for this process to finish."
        echo "This can take up to a few hours. Do not close this window." && echo ""
        sleep 1

        ssh -q -t $CURRENT_USER@$SERVER "sudo su -c '/usr/local/bin/fantasygold-cli startmasternode local false' $F_USER"
        echo "waiting..."
        sleep 30
        ssh -q -t $CURRENT_USER@$SERVER "sudo su -c '/usr/local/bin/fantasygold-cli startmasternode local false' $F_USER"
        echo "still waiting..."
        sleep 30
        ssh -q -t $CURRENT_USER@$SERVER "sudo su -c '/usr/local/bin/fantasygold-cli startmasternode local false' $F_USER"
        echo "still waiting..."
        sleep 30
        ssh -q -t $CURRENT_USER@$SERVER "sudo su -c '/usr/local/bin/fantasygold-cli startmasternode local false' $F_USER"
        echo "still waiting..."
        sleep 30
        ssh -q -t $CURRENT_USER@$SERVER "sudo su -c '/usr/local/bin/fantasygold-cli startmasternode local false' $F_USER"
        echo "    "

        read -e -p "Does it appear it finished syncing yet? [y/N] : " SYNCED_Q_R

        if [[ ("$SYNCED_Q_R" == "y" || "$SYNCED_Q_R" == "Y") ]];
            then
                ssh -q -t $CURRENT_USER@$SERVER "sudo su -c '/usr/local/bin/fantasygold-cli masternode status' $F_USER"
                sleep 5
                echo "" && echo "Masternode setup completed." && echo ""
                exit 0
            else
                ssh -q -t $CURRENT_USER@$SERVER "sudo su -c '/usr/local/bin/fantasygold-cli startmasternode local false' $F_USER"
                echo "waiting..."
                sleep 30
                ssh -q -t $CURRENT_USER@$SERVER "sudo su -c '/usr/local/bin/fantasygold-cli startmasternode local false' $F_USER"
                echo "still waiting..."
                sleep 30
                ssh -q -t $CURRENT_USER@$SERVER "sudo su -c '/usr/local/bin/fantasygold-cli startmasternode local false' $F_USER"
                echo "still waiting..."
                sleep 30
                ssh -q -t $CURRENT_USER@$SERVER "sudo su -c '/usr/local/bin/fantasygold-cli startmasternode local false' $F_USER"
                echo "still waiting..."
                sleep 30
                ssh -q -t $CURRENT_USER@$SERVER "sudo su -c '/usr/local/bin/fantasygold-cli startmasternode local false' $F_USER"
                echo "still waiting..."
                sleep 30
        fi

        ssh -q -t $CURRENT_USER@$SERVER "sudo su -c '/usr/local/bin/fantasygold-cli startmasternode local false' $F_USER"

        read -e -p "Does it appear it finished syncing yet? [y/N] : " SYNCED1_Q_R

        if [[ ("$SYNCED1_Q_R" == "y" || "$SYNCED1_Q_R" == "Y") ]];
            then
                ssh -q -t $CURRENT_USER@$SERVER "sudo su -c '/usr/local/bin/fantasygold-cli masternode status' $F_USER"
                sleep 5
                echo "" && echo "Masternode setup completed." && echo ""
                exit 0
            else
                ssh -q -t $CURRENT_USER@$SERVER "sudo su -c '/usr/local/bin/fantasygold-cli startmasternode local false' $F_USER"
                echo "waiting..."
                sleep 30
                ssh -q -t $CURRENT_USER@$SERVER "sudo su -c '/usr/local/bin/fantasygold-cli startmasternode local false' $F_USER"
                echo "still waiting..."
                sleep 30
                ssh -q -t $CURRENT_USER@$SERVER "sudo su -c '/usr/local/bin/fantasygold-cli startmasternode local false' $F_USER"
                echo "still waiting..."
                sleep 30
                ssh -q -t $CURRENT_USER@$SERVER "sudo su -c '/usr/local/bin/fantasygold-cli startmasternode local false' $F_USER"
                echo "still waiting..."
                sleep 30
                ssh -q -t $CURRENT_USER@$SERVER "sudo su -c '/usr/local/bin/fantasygold-cli startmasternode local false' $F_USER"
                echo "still waiting..."
                sleep 30
        fi

        ssh -q -t $CURRENT_USER@$SERVER "sudo su -c '/usr/local/bin/fantasygold-cli startmasternode local false' $F_USER"

        read -e -p "Does it appear it finished syncing yet? [y/N] : " SYNCED2_Q_R

        if [[ ("$SYNCED2_Q_R" == "y" || "$SYNCED2_Q_R" == "Y") ]];
            then
                ssh -q -t $CURRENT_USER@$SERVER "sudo su -c '/usr/local/bin/fantasygold-cli masternode status' $F_USER"
                sleep 5
                echo "" && echo "Masternode setup completed." && echo ""
                exit 0
            else
                ssh -q -t $CURRENT_USER@$SERVER "sudo su -c '/usr/local/bin/fantasygold-cli startmasternode local false' $F_USER"
                echo "waiting..."
                sleep 30
                ssh -q -t $CURRENT_USER@$SERVER "sudo su -c '/usr/local/bin/fantasygold-cli startmasternode local false' $F_USER"
                echo "still waiting..."
                sleep 30
                ssh -q -t $CURRENT_USER@$SERVER "sudo su -c '/usr/local/bin/fantasygold-cli startmasternode local false' $F_USER"
                echo "still waiting..."
                sleep 30
                ssh -q -t $CURRENT_USER@$SERVER "sudo su -c '/usr/local/bin/fantasygold-cli startmasternode local false' $F_USER"
                echo "still waiting..."
                sleep 30
                ssh -q -t $CURRENT_USER@$SERVER "sudo su -c '/usr/local/bin/fantasygold-cli startmasternode local false' $F_USER"
                echo "still waiting..."
                sleep 30
        fi

        ssh -q -t $CURRENT_USER@$SERVER "sudo su -c '/usr/local/bin/fantasygold-cli startmasternode local false' $F_USER"

        read -e -p "Does it appear it finished syncing yet? [y/N] : " SYNCED2_Q_R

        if [[ ("$SYNCED2_Q_R" == "y" || "$SYNCED2_Q_R" == "Y") ]];
            then
                ssh -q -t $CURRENT_USER@$SERVER "sudo su -c '/usr/local/bin/fantasygold-cli masternode status' $F_USER"
                sleep 5
                echo "" && echo "Masternode setup completed." && echo ""
                exit 0
            else
                echo "At this point this script has run down it's own timer. You can continue to watch it manually using the following:"
                echo "ssh -q -t $CURRENT_USER@$SERVER "sudo su -c '/usr/local/bin/fantasygold-cli startmasternode local false' $F_USER""
                exit 0
        fi

fi




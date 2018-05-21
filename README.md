# FGC-ControlMine-CentOS7
ControlMine: A basic remote crypto-miner command and control system. (Built for CentOS 7)

## This software is highly experimental!
If you are at all a novice Linux or Fantasy Gold Coin user you probably shouldn't be trying to use this yet until an official version 1 is released.

This documentation will be updated as development progresses. 

These scripts depend heavily on ssh. It's highly recommended that the remote ssh user has the following conditions met for optimal ControlMine performance:
1. Set sudo to operate without a password. Either use visudo to change wheel from:
```
%wheel ALL=(ALL) ALL
```
...to:
```
%wheel ALL=(ALL) NOPASSWD: ALL
```
2. Install an ssh key on the remote node and use keyfiles instead of passwords to connect.
See https://wiki.archlinux.org/index.php/SSH_keys for more information on how to generate and use ssh keys.

## Usage
Syntax:
```
$ ./controlmine.sh <servername> <option>
```

## Options
To use ControlMine, you'll feed it 2 options: the remote server name and the action you wish to perform. All available options are outlined as followS:
```
status          Show the current status of a remote node
reboot          Reboot the remote node
deps            Install all build and runtime dependancy packages on the remote node
install         Using the precompiled binaries located on the master control node, install precompiled binaries to the remote node
masternode      Deploy the main ControlMine scripts to your chosen remote master control node
adopt           Adopt a new remote node that has been correctly prepared using 'deps' and 'install' first
upgradesrc      Upgrade the FantasyGold-core package on the remote node from upstream source.
uninstall       Uninstall FantasyGold-core from the remote node
```

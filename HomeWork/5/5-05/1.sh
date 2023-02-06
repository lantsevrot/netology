#!/bin/bash
username=`id -nu`
if [ "$username" != "root" ]
then
	echo "Must be root to run \"`basename $0`\"."
	exit 1
fi
trap 'echo "Ping exit (Ctrl-C)"; exit 1' 2
echo "Please, select a network interface:"
PS3="Interface: "
nz=$(ls /sys/class/net)
select INTERFACE in $nz; do echo $INTERFACE selected;
#echo $b
if [[ $(ls /sys/class/net | grep $INTERFACE 2> /dev/null) ]]; then
    echo
    else
    cnt=$(ls /sys/class/net/ | wc -l)
    echo "Choose one of the items 1-$cnt"
    exit 1
fi 

echo "Please specify ip address prefix like XXX.XXX"
read -p "PREFIX ~ " a
PREFIX="${a:-NOT_SET}"
[[ "$PREFIX" = "NOT_SET" ]] && { echo "Prefix must be selected"; exit 1; }
if [[ "$PREFIX" =~ ^([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$ ]]; then
    echo "$PREFIX.XXX.XXX"
else
    echo "Specify a prefix in (0-255).(0-255)"
    exit 1
fi

echo "Specify SUBNET"
read -p "SUBNET ~ " c
SUBNET="${c:-NOT_SET}"
if [[ "$SUBNET" =~ ^([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$ || "$SUBNET" = "NOT_SET" ]]; then
    if [[ "$SUBNET" = "NOT_SET" ]]; then
    echo "$PREFIX.(0-255).XXX"
    SUBNETF="$PREFIX.(0-255)"
    else 
    echo "$PREFIX.$SUBNET.XXX"
    SUBNETF="$PREFIX.$SUBNET"
    fi
else
    echo "Choose a number between 0-255 or don't choose anything"
    exit 1
fi

echo "Specify host"
read -p "HOST ~ " d 
HOST="${d:-NOT_SET}"
if [[ "$HOST" =~ ^([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$ || "$HOST" = "NOT_SET" ]]; then
    if [[ "$HOST" = "NOT_SET" ]]; then
    echo "$SUBNETF.(0-255)"
    else 
    echo "$SUBNETF.$HOST"
    fi
else
    echo "Choose a number between 0-255 or don't choose anything"
    exit 1
fi
sleep 3
if [[ "$SUBNET" = "NOT_SET" && "$HOST" = "NOT_SET" ]]; then 
    for SUBNET in {1..255}
    do
        for HOST in {1..255}
        do
            echo "[*] IP : ${PREFIX}.${SUBNET}.${HOST}"
            arping -c 3 -I "$INTERFACE" "${PREFIX}.${SUBNET}.${HOST}" 2> /dev/null
        done
    done
    exit 1
fi
if [[ "$SUBNET" != "NOT_SET" && "$HOST" = "NOT_SET" ]]; then 
    for SUBNET in $SUBNET
    do
        for HOST in {1..255}
        do
            echo "[*] IP : ${PREFIX}.${SUBNET}.${HOST}"
            arping -c 3 -I "$INTERFACE" "${PREFIX}.${SUBNET}.${HOST}" 2> /dev/null
        done
    done
    exit 1
fi
if [[ "$SUBNET" = "NOT_SET" && "$HOST" != "NOT_SET" ]]; then 
    for SUBNET in {1..255}
    do
        for HOST in $HOST
        do
            echo "[*] IP : ${PREFIX}.${SUBNET}.${HOST}"
            arping -c 3 -I "$INTERFACE" "${PREFIX}.${SUBNET}.${HOST}" 2> /dev/null
        done
    done
    exit 1
fi
if [[ "$SUBNET" != "NOT_SET" && "$HOST" != "NOT_SET" ]]; then 
    for SUBNET in $SUBNET
    do
        for HOST in $HOST
        do
            echo "[*] IP : ${PREFIX}.${SUBNET}.${HOST}"
            arping -c 3 -I "$INTERFACE" "${PREFIX}.${SUBNET}.${HOST}" 2> /dev/null
        done
    done
    exit 1
fi
done

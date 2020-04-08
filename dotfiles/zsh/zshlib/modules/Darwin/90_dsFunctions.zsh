BASE='/LDAPv3/address.domain.lan'
KEYWORD="desktop"

function dsComputerUserList {
    for c in `dscl $BASE -search Computers Keywords desktop|grep Keywords|cut -f1|sort`; do
        echo -n $c:
        dscl $BASE -read Computers/$c Comment|cut -d: -f3
    done
}

function dsComputerList {
    for c in `dsComputerUserList`; do
        echo $c|cut -d: -f1
    done
}

function dsUser {
    COMPUTER=${1-`dscl . -list Computers|grep -v localhost`}
    dsComputerUserList| grep -i $COMPUTER|cut -d: -f2
}

unset BASE
unset KEYWORD

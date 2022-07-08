#!/usr/bin/expect
set timeout -1
set platform [lindex $argv 2]
set install_dir [lindex $argv 1]
set installer [lindex $argv 0]
set basedir [file dirname $installer]

if {$platform != ""} {
    spawn $installer -d $install_dir -p "$platform"
} else {
    spawn $installer -d $install_dir
}
set timeout 2
expect {
    "getopt: invalid option" {
        spawn env PATH=$basedir:$env(PATH) $installer $install_dir
    }
    timeout { }
}

set timeout 600
expect "Press Enter to display the license agreements"
send "\r"
set timeout 2

expect "Sections 10 (Disclaimers)"
send "\r"

expect "(Governing Law) of this Agreement"
send "q"

expect {
    "* >*" {send "y\r"}
    timeout { send "q"; sleep 1; exp_continue}
}
expect {
    "* >*" {send "y\r"}
    timeout { send "q"; sleep 1; exp_continue}
}
expect {
    "* >*" {send "y\r"}
    timeout { send "q"; sleep 1; exp_continue}
}

### set timeout -1
### expect "PetaLinux SDK has been installed"
#interact

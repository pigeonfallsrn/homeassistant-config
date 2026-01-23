#!/usr/bin/expect -f
set timeout 10
set content [lindex $argv 0]
spawn ssh -o StrictHostKeyChecking=no admin@192.168.1.52 "echo '$content' >> /volume1/GoogleDrive/AI_Context/PROJECTS.md"
expect "password:"
send "F00tb@ll123!\r"
expect eof

#!/bin/bash

logfolder="/var/log/shellscript"
scriptname=$(echo $0 | cut -d "." -f1)
timestamp=$(date +%Y-%m-%d)
logfile="$logfolder/$scriptname-$timestamp.log"
mkdir -p $logfolder

uid=$(id -u)
checkroot(){
       if [ $uid -ne 0 ]
       then 
          echo "Run as Administrator"
          exit 1
       fi
}
validate(){
    if [ $1 -ne 0 ]
    then 
       echo "'$2' is not complete..."
    else
       echo "'$2' is complete.."

}


echo " Script Started executing at $(date) " | tee -a $logfile
checkroot
dnf install nginx -y 
validate $? "Installing nginx"
rm -rf /usr/share/nginx/html/*
curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip
cd /usr/share/nginx/html
unzip /tmp/frontend.zip



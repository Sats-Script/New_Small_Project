#!bin/bash

logfolder="/var/log/backendscript"
scriptname=$(echo $0 | cut -d "." -f1)
time=$(date +%Y-%m-%d)
logfile="$logfolder/$scriptname-$time.log"
mkdir -p $logfolder

uid=$(id -u)
checkroot(){
    if [ $uid -ne 0 ]
    then 
       echo "Run as administrator"
       exit 1
    fi
}

validate(){
    if [ $1 -ne 0 ]
    then 
       echo "'$2' is not complete..."
    else
       echo "'$2' is complete.."
    fi

}

echo " Script Started executing at $time " | tee -a $logfile

checkroot

dnf module list nodejs    | tee -a $logfile
dnf module disable nodejs -y
dnf module enable nodejs:20 -y 
dnf install nodejs -y
validate $? "Nodejs:20 installation"
useradd expense   |tee -a $logfile
validate $? "expense user creation"
mkdir -p /app
curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip
validate $? "downloading app files"
cd /app
rm -rf /ap/*
unzip /tmp/backend.zip
validate $? "unzipping app files"
npm install
validate $? "nodejs dependencies file"
systemctl enable backend
validate $? "backend service enabling"
systemctl start backend
validate $? "starting backend service"


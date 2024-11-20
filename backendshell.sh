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
id expense
if [ $? -ne 0 ]
then 
   echo "Expense user creatin"
   useradd expense   |tee -a $logfile
   validate $? "expense user creation"
else
   echo " User already exists "
fi
mkdir -p /app
curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip
validate $? "downloading app files"
cd /app
rm -rf /app/*
unzip /tmp/backend.zip
validate $? "unzipping app files"
npm install
validate $? "nodejs dependencies file"
cp /home/ec2-user/New_Small_Project/backend.service  /etc/systemd/system/backend.service
dnf install mysql -y
validate $? "Installing Mysql "
mysql -h 172.31.32.232 -u root -pExpenseApp@1   < /app/schema/backend.sql &>>$logfile
VALIDATE $? "Schema loading"
systemctl daemon-reload &>>$logfile
VALIDATE $? "Daemon reload"

systemctl enable backend &>>$logfile
VALIDATE $? "Enabled backend"

systemctl restart backend &>>$logfile
VALIDATE $? "Restarted Backend"

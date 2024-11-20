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
     echo "$2 is present.. nothing to do"  | tee -a $logfile
   else
     echo "$2 is complete"  | tee -a $logfile
   fi

}

echo " Script Started executing at $(date) " | tee -a $logfile

checkroot 

dnf install mysql-server -y
validate $? Mysqlinstallation 
systemctl enable mysqld
validate $? mysqlenabling
systemctl start mysqld
validate $? mysqlsystemstart

mysql -h 172.31.32.232  -u root -pExpenseApp@1 -e 'show databases;'
if [ $? -ne 0 ]
then 
   echo " Root password setting up now... " | tee -a $logfile
   mysql_secure_installation --set-root-pass ExpenseApp@1 
   echo  "Root password setting is success..." | tee -a $logfile
else
   echo " Root password is already set up now.... nothing to do " | tee -a $logfile
fi

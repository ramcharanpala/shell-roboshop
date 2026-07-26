#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/shell-roboshop"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1 )
SCRIPT_DIR=$PWD
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log" 

mkdir -p $LOGS_FOLDER
SCRIPT_DIR=$PWD
echo "script execution started at: $(date)" | tee -a $LOG_FILE

if [ $USERID -ne 0 ]; then
    echo "ERROR: please run this script as root privileges"
    exit 1
fi

VALIDATION(){
       if [ $1 -ne 0 ]; then
          echo -e "$2 ... $R FAILURE $N" | tee -a $LOG_FILE
          exit 1
        else
          echo -e "$2 ... $G SUCCESS $N" | tee -a $LOG_FILE
        fi
}

dnf module disable nginx -y &>>$LOG_FILE
VALIDATION $? "disabling nginx"

dnf module enable nginx:1.24 -y &>>$LOG_FILE
VALIDATION $? "enabling nginx:1.24"

dnf install nginx -y &>>$LOG_FILE
VALIDATION $? "installing nginx"

systemctl enable nginx &>>$LOG_FILE
VALIDATIN $? "enabling nginx"

systemctl start nginx
VALIDATION $? "starting nginx"

rm -rf /usr/share/nginx/html/*

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>>$LOG_FILE
VALIDATION $? "downloading frontend applications"

cd /usr/share/nginx/html

unzip /tmp/frontend.zip &>>$LOG_FILE
VALIDATION $? "unzip frontend"

rm -rf /etc/nginx/nginx.conf
cp $SCRIPT_DIR/nginx.conf /etc/nginx/nginx.conf &>>$LOG_FILE
VALIDATION $? "copying nginx.conf"

systemctl restart nginx &>>$LOG_FILE
VALIDATION $? "restarting nginx"
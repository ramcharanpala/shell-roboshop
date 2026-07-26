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

dnf install python3 gcc python3-devel -y
VALIDATION $? "installing python3"

id roboshop &>>LOG_FILE
if [ $? -ne 0 ]; then
   useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
   VALIDATION $? "creating system user"
else 
   echo "roboshop user already exists .. $Y SKIPPING $N"
fi

mkdir -p /app &>>LOG_FILE
VALIDATION $? "creating app directory"

curl -L -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip &>>LOG_FILE
VALIDATION $? "downloading payment applications"

cd /app
VALIDATION $? "changing to app directory"

rm -rf /app/*
VALIDATION $? "removing existing code"

unzip /tmp/payment.zip &>>LOG_FILE
VALIDATION $? "unzip payment"

pip3 install -r requirements.txt &>>LOG_FILE

cp $SCRIPT_DIR/payment.service /etc/systemd/system/payment.service

systemctl daemon-reload &>>LOG_FILE

systemctl enable payment &>>LOG_FILE
VALIDATION $? "enabling payment"

systemctl start payment &>>LOG_FILE
VALIDATION $? "starting payment"
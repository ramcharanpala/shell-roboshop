#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/shell-roboshop"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1 )

SCRIPT_DIR=$PWD
MONGODB_HOST=mongodb.ram86s.fun
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log" 

mkdir -p $LOGS_FOLDER
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

dnf module disable nodejs -y &>>$LOG_FILE
VALIDATION $? "disabling nodejs module"

dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATION $? "enabling nodejs module 20"

dnf install nodejs -y &>>$LOG_FILE
VALIDATION $? "installing nodejs"

id roboshop &>>$LOG_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
    VALIDATION $? "creating system user"
else
    echo -e "user already exists ... $Y SKIPPING $N"
fi

mkdir -p /app
VALIDATION $? "creating app directory"

curl -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart-v3.zip &>>$LOG_FILE
VALIDATION $? "Downloading cart application"

cd /app 
VALIDATION $? "changing to app directory"

rm -rf /app/*
VALIDATION $? "removing existing code"

unzip /tmp/cart.zip &>>$LOG_FILE
VALIDATION $? "unzip cart"

npm install &>>$LOG_FILE
VALIDATION $? "install dependencies"

cp $SCRIPT_DIR/cart.service /etc/systemd/system/cart.service
VALIDATION $? "copy systemctl service"

systemctl daemon-reload
systemctl enable cart &>>$LOG_FILE
VALIDATION $? "enable cart"

cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATION $? "copy mongo repo"

systemctl restart cart 
VALIDATION $? "restarted cart"
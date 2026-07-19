#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/shell-roboshop"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1 )
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"

mkdir -p $LOGS_FOLDER
echo "script execution started at: $(date)" | tee -a $LOG_FILE

if [ $USERID -ne 0 ]; then
    echo -e "${R}ERROR: This script must be run as root.${N}"
    exit 1
fi

VALIDATION(){
    if [ $1 -ne 0 ]; then
        echo -e "$2 .. $R failure $N" | tee -a $LOG_FILE
        exit 1
    else
        echo -e "$2 .. $G success $N"| tee -a $LOG_FILE
    fi
}

cp mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATION $? "adding mongo repo"

dnf install mongodb-org -y &>>$LOG_FILE
VALIDATION $? "installing mongodb"

systemctl enable mongod &>>$LOG_FILE
VALIDATION $? "enable mongodb"

systemctl start mongod &>>$LOG_FILE
VALIDATION $? "starting mongodb"
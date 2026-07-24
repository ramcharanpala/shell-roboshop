#!/bin/bash

USERID=$(id -U)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/shell-roboshop"
SCRIPT_NAME=$( echo $0 | cut -d "." f1 )
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
START_TIME=$(date +%s)

mkdir -p $LOGS_FOLDER
SCRIPT_DIR=$PWD
echo "script started executed at: $(date)" | tee -a $LOG_FILE

if [ $USERID -ne 0 ]; then
   echo "ERROR:: please run this script at root privelege"
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

cp $SCRIPT_DIR/rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo &>>LOG_FILE
VALIDATION $? "adding rabbitmq.repo"

dnf install rabbitmq-server -y &>>LOG_FILE
VALIDATION $? "installing rabbitmq-server"

systemctl enable rabbitmq-server &>>LOG_FILE
VALIDATION $? "enabling rabbitmq-server"

systemctl start rabbitmq-server &>>LOG_FILE
VALIDATION $? "starting rabbitmq-sercer"

rabbitmqctl add_user roboshop roboshop123 &>>LOG_FILE
VALIDATION $? "adding use"

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>LOG_FILE
VALIDATION $? "setting up permissions"


END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $START_TIME ))
echo -e "script executed at:: $Y $TOTAL_TIME seconds $N"
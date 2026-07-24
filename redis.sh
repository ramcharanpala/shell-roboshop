#!/bin/bash

USERID=(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/shell-roboshop"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1 )
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
START_TIME=$(date +%s)

mkdir -p $LOGS_FOLDER
echo "script execution started at: $(date)" | tee -a $LOG_FILE

if [ $USERID -ne 0 ]; then
    echo "ERROR: please run this script in root privelege"
    exit 1
fi

VALIDATION(){
    if [ $1 -ne 0 ]; then
       echo -e "$2 ... $R FAILURE $N | tee -a &>>LOG_FILE
       exit 1
    else
       echo -e "$2 ... $G SUCCESS $N | tee -a &>>LOG_FILE 
    fi
}

dnf module disable redis -y &>>LOG_FILE
VALIDATION $? "disabling default redis" 

dnf module enable redis:7 -y &>>LOG_FILE
VALIDATION $? "enable redis:7" 

dnf install redis -y  &>>LOG_FILE
VALIDATION $? "install redis" 

sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/ c protected-mode no' /etc/redis/redis.conf
VALIDATION $? "allowing remote connections to the redis" 

systemctl enable redis &>>LOG_FILE
VALIDATION $? "enable redis" 

systemctl start redis &>>LOG_FILE
VALIDATION $? "start redis" 

END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $START_TIME ))
echo -e "script executed in: $Y $TOTAL_TIME seconds $N"
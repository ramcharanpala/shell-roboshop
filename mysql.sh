#!/bin/bash
USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/shell-roboshop"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1 )
LOG_FILE="$LOG_FOLDER/$SCRIPT_NAME.log"
START_TIME=$(date +%s)
mkdir -p $LOGS_FOLDER
echo "script started executed at:$(date)" | tee -a &>>LOG_FILE

if [ $USERID -ne 0 ]; then
    echo -e "ERROR:: please run this script in root privelege"
    exit 1
fi 

VALIDATION(){
      if [ $? -ne 0 ]; then
         echo -e "$2... $R FAILURE $N" | tee -a $LOG_FILE
         exit 1
      else
         echo -e "$2... $G SUCCESS $N" | tee -a $LOG_FILE
}

dnf install mysql-server -y &>>LOG_FILE
VALIDATION $? "installing mysql-server"

systemctl enable mysqld  &>>LOG_FILE
VALIDATION $? "enabling mysqld"

systemctl start mysqld  &>>LOG_FILE
VALIDATION $? "starting mysqld"

mysql_secure_installation --set-root-pass RoboShop@1
VALIDATION $? "setting up root password"

END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $START_TIME ))
echo -e "script executed in: $Y TOTAL_TIME seconds $N"
#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  echo -e "Welcome to My Salon, how can I help you?\n"
  
  SERVICE_MENU=$($PSQL "SELECT * FROM services ORDER BY service_id")

  echo "$SERVICE_MENU" | while read SERID BAR NAME
  do
    echo "$SERID) $NAME"
  done

  read SERVICE_ID_SELECTED

  REQ_SERID_ABLE=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  if [[ -z $REQ_SERID_ABLE ]]
  then
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    CUS_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

    if [[ -z $CUS_ID ]]
    then
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
      INSERT_CUST=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    fi

    CUS_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    CUS_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

    REQ_SERNAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")    
    echo -e "\nWhat time would you like your $(echo $REQ_SERNAME | sed 's/ //g'), $(echo $CUS_NAME | sed 's/ //g')?"
    read SERVICE_TIME

    INSERT_APPO=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUS_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

    echo -e "\nI have put you down for a $(echo $REQ_SERNAME | sed 's/ //g') at $(echo $SERVICE_TIME | sed 's/ //g'), $(echo $CUS_NAME | sed 's/ //g')."
  fi




}

MAIN_MENU

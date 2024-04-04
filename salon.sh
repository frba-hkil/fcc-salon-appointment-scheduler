#!/bin/bash
echo -e "\n~~~~~ MY SALON ~~~~~\n"
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
SALON_MENU() {
  if [[ $1 ]]
  then
    echo $1
  else
    echo Welcome to My Salon, how can I help you?
  fi
  SERVICES="$($PSQL "SELECT service_id, name FROM services")"
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
  SELECT_SERVICE
}

SELECT_SERVICE() {
  read SERVICE_ID_SELECTED
  SERVICE_ID=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  if [[ -z $SERVICE_ID ]]
  then
    SALON_MENU "I could not find that service. What would you like today?"
  else
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
    if [[ -z $CUSTOMER_NAME ]]
    then
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
      CUSTOMER_INSERT_RESULT=$($PSQL "INSERT INTO customers (phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    fi
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    echo -e "\nWhat time would you like your cut, $CUSTOMER_NAME?"
    read SERVICE_TIME
    SERVICE_APPOINTMENT_INSERT_RESULT=$($PSQL "INSERT INTO appointments (service_id, customer_id, time) VALUES ($SERVICE_ID, $CUSTOMER_ID, '$SERVICE_TIME')")
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID")
    if [[ $SERVICE_APPOINTMENT_INSERT_RESULT == "INSERT 0 1" ]]
    then
      echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
    fi
  fi
}

SALON_MENU

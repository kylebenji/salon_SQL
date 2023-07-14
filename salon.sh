#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ Salon Appointments ~~~~~\n"

SERVICE_MENU(){
  #get services from database
  SERVICES=$($PSQL "SELECT * from services ORDER BY service_id")
  #display services
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
  echo -e "\nWhat service would you like to schedule today?"
}
SERVICE_MENU

# read selected service
read SERVICE_ID_SELECTED

#check for real service
if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ || -z $($PSQL "SELECT * from services WHERE service_id=$SERVICE_ID_SELECTED") ]]
then
  # if not a number, quit
  echo "That is not a valid service number."
  SERVICE_MENU
else
  #ask for phone number
  echo -e "\n\nWhat is your phone number?"
  read CUSTOMER_PHONE
  #check for customer in database
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  #if not a customer, make new customer
  if [[ -z $CUSTOMER_ID ]]
  then
    #get customer name
    echo -e "\nWhat is your name?"
    read CUSTOMER_NAME
    #insert into customers
    NEW_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name,phone) VALUES('$CUSTOMER_NAME','$CUSTOMER_PHONE')")
    #get new customer id
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  else
    echo "fetching customer info"
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
  fi
  #get time for appointment
  echo -e "\nWhat time would you like your appointment?"
  read SERVICE_TIME
  #insert appointment into table
  INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id,service_id,time) VALUES($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')")
  #return confirmation message
  SERVICE_NAME=$($PSQL "SELECT name from services where service_id=$SERVICE_ID_SELECTED")
  echo -e "\nI have put you down for a $(echo $SERVICE_NAME | sed 's/ |/"/') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed 's/ |/"/')."
fi



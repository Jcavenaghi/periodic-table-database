#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --tuples-only --no-align -c"

if [[ -z $1 ]]
then
  echo -e "Please provide an element as an argument."
  exit
fi

if [[ $1 =~ ^[0-9]+$ ]]
then
  ATOMIC_NUMBER_RESULT=$($PSQL "SELECT atomic_number FROM elements WHERE (atomic_number = $1);")
else
  ATOMIC_NUMBER_RESULT=$($PSQL "SELECT atomic_number FROM elements WHERE (symbol = '$1' OR name = '$1');")
fi

if [[ -z $ATOMIC_NUMBER_RESULT ]]
then
  echo "I could not find that element in the database."
else
  ELEMENT_INFO=$($PSQL "SELECT e.*, t.type, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius, p.type_id FROM elements as e INNER JOIN properties as p ON e.atomic_number = p.atomic_number INNER JOIN types as t ON p.type_id = t.type_id WHERE e.atomic_number = $ATOMIC_NUMBER_RESULT;")
  # SeparO los campos usando awk
  id=$(echo "$ELEMENT_INFO" | awk -F"|" '{print $1}')
  symbol=$(echo "$ELEMENT_INFO" | awk -F"|" '{print $2}')
  name=$(echo "$ELEMENT_INFO" | awk -F"|" '{print $3}')
  type=$(echo "$ELEMENT_INFO" | awk -F"|" '{print $4}')
  atomic_mass=$(echo "$ELEMENT_INFO" | awk -F"|" '{print $5}')
  melting_point=$(echo "$ELEMENT_INFO" | awk -F"|" '{print $6}')
  boiling_point=$(echo "$ELEMENT_INFO" | awk -F"|" '{print $7}')
  echo "The element with atomic number $id is $name ($symbol). It's a $type, with a mass of $atomic_mass amu. $name has a melting point of $melting_point celsius and a boiling point of $boiling_point celsius."
fi


#!/bin/bash

PSQL='psql --username=freecodecamp --dbname=periodic_table --tuples-only -c'


if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
else


  # atomic number check
  if [[ $1 =~ ^[0-9]*$ ]]
  then
    RESULT=$($PSQL "SELECT atomic_number, symbol, name FROM elements WHERE atomic_number = $1")
  elif [[ $1 =~ ^[A-Z][a-Z]?$ ]]
  then
    RESULT=$($PSQL "SELECT atomic_number, symbol, name FROM elements WHERE symbol = '$1'")
  else
    RESULT=$($PSQL "SELECT atomic_number, symbol, name FROM elements WHERE name = '$1'")
  fi

  if [[ -z $RESULT ]]
  then
    echo "I could not find that element in the database."
  else
    IFS='|' read ATOMIC_NUM SYMBOL NAME <<< $(echo $RESULT | sed 's/^ *| *$//g')

    PROPERTIES=$($PSQL "SELECT type_id, atomic_mass, melting_point_celsius, boiling_point_celsius FROM properties WHERE atomic_number=$ATOMIC_NUM")
    IFS='|' read TYPE_ID ATOMIC_MASS MELTING_POINT BOILING_POINT <<< $(echo $PROPERTIES | sed 's/^ *| *$//g')

    TYPE=$($PSQL "SELECT type FROM types WHERE type_id=$TYPE_ID")

    echo "The element with atomic number $(echo $ATOMIC_NUM | sed 's/^ *| *$//g') is $(echo $NAME | sed 's/^ *| *$//g') ($(echo $SYMBOL | sed 's/^ *| *$//g')). It's a $(echo $TYPE | sed 's/^ *| *$//g'), with a mass of $(echo $ATOMIC_MASS | sed 's/^ *| *$//g') amu. $(echo $NAME | sed 's/^ *| *$//g') has a melting point of $(echo $MELTING_POINT | sed 's/^ *| *$//g') celsius and a boiling point of $(echo $BOILING_POINT | sed 's/^ *| *$//g') celsius."

  fi

fi

#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# Clear database
echo $($PSQL "TRUNCATE TABLE games, teams;")

# Read games.csv using comma separator and loop through each row
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT W_GOALS O_GOALS
do
  # Skip header line
  if [[ $YEAR != year ]]
  then

    # Query matching winner team_id
    W_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$WINNER';")
    # If not found
    if [[ -z $W_ID ]]
    then
      # Insert team into database
      INSERT_TEAM=$($PSQL "INSERT INTO teams(name) VALUES ('$WINNER');")
      if [[ $INSERT_TEAM == "INSERT 0 1" ]]
      then
        echo Added team to database: $WINNER
      fi
      # Query newly created opponent team_id
      W_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$WINNER';")
    fi
    
    # Query matching opponent team_id
    O_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPPONENT';")
    # If not found
    if [[ -z $O_ID ]]
    then
      # Insert team into database
      INSERT_TEAM=$($PSQL "INSERT INTO teams(name) VALUES ('$OPPONENT');")
      if [[ $INSERT_TEAM == "INSERT 0 1" ]]
      then
        echo Added team to database: $OPPONENT
      fi
      # Query newly created winner team_id
      O_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPPONENT';")
    fi

    # Insert game into database
    INSERT_GAME=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES ($YEAR, '$ROUND', $W_ID, $O_ID, $W_GOALS, $O_GOALS);")
    if [[ $INSERT_GAME == "INSERT 0 1" ]]
    then
      echo Added game to database: $YEAR $WINNER vs $OPPONENT
    fi

  fi
done

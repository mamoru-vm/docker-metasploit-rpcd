#!/bin/bash
#create database yaml file for metasploit
#uses linked alias name pg for hostname, default postgres port
# thanks to pandrew https://github.com/pandrew/dockerfiles/blob/master/metasploit/setup.sh
MSF_DB=${MSF_DB:-msf}

# use the same username and password for the DB and RPC
MSFRPC_USER=${MSFRPC_USER:-mamoru}
MSFRPC_PASS=${MSFRPC_PASS:-mamoru}

if [[ ! -z "$PG_PORT_5432_TCP_ADDR" ]]
then
  # Check if user exists
  USEREXIST="$(psql -h pg -p 5432 -U postgres postgres -tAc "SELECT 1 FROM pg_roles WHERE rolname='$MSFRPC_USER'")"
  # If not create it
  if [[ ! $USEREXIST -eq 1 ]]
  then
   psql -h pg -p 5432 -U postgres postgres -c "create role $MSFRPC_USER login password '$MSF_PASS'"
  fi

  DBEXIST="$(psql -h pg -p 5432 -U postgres  postgres -l | grep $MSF_DB)"
  if [[ ! $DBEXIST ]]
  then
   psql -h pg -p 5432 -U postgres postgres -c "CREATE DATABASE $MSF_DB OWNER $MSFRPC_USER;"
  fi

  echo "production:
   adapter: postgresql
   database: $MSF_DB
   username: $MSFRPC_USER
   password: $MSFRPC_USER
   host: pg
   port: 5432
   pool: 75
   timeout: 5" > /metasploit-framework/config/database.yml
fi

#update metasploit 
msfupdate --git-remote MASTER

#launch msfrpcd as PID 1
exec msfrpcd -U $MSFRPC_USER -P $MSFRPC_PASS -f



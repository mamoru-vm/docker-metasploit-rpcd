#!/bin/bash
#create database yaml file for metasploit
#uses linked alias name pg for hostname, default postgres port
# thanks to pandrew https://github.com/pandrew/dockerfiles/blob/master/metasploit/setup.sh
MSF_DB=${MSF_DB:-msf}

# use the same username and password for the DB and RPC
MSFRPC_USER=${MSFRPC_USER:-mamoru}
MSFRPC_PASS=${MSFRPC_PASS:-mamoru}

#create pgpass for psql commands
echo "pg:5432:*:postgres:$PG_ENV_POSTGRES_PASSWORD" > ~/.pgpass
chmod 0600 ~/.pgpass

if [[ ! -z "$PG_PORT_5432_TCP_ADDR" ]]
then
  # Check if user exists
  USEREXIST="$(psql -U postgres -d postgres -h pg --no-password -tAc "SELECT 1 FROM pg_roles WHERE rolname='$MSFRPC_USER'")"
  # If not create it
  if [[ ! $USEREXIST -eq 1 ]]
  then
   psql -h pg -p 5432 -U postgres -d postgres  --no-password -c "create role $MSFRPC_USER login password '$MSFRPC_PASS'"
  fi

  DBEXIST="$(psql -h pg -p 5432 -U postgres -d postgres --no-password -l | grep $MSF_DB)"
  if [[ ! $DBEXIST ]]
  then
   psql -h pg -p 5432 -U postgres -d postgres --no-password -c "CREATE DATABASE $MSF_DB OWNER $MSFRPC_USER;"
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



Mamoru MSF
==========
Metasploit container exposing msfrpcd on port 5553
Used in the Mamoru vulnerability managment platform

## Build Image
```shell
cd metasploit
docker build -t metasploit_rpc .
```

## Run Container
```shell

# start postgres container before metasploit
docker run --name postgres \ 
 --label mamoru="postgres" \
 -e PGDATA=/pgdata \
 -v  ~/.mamoru/pgdata:/pgdata \
  postgres:9.4

docker run --name metasploit-rpcd \
  --link postgres:pg \
  --label mamoru="metasploit" \
  metasploit_rpc
```
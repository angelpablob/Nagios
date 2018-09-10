#!/bin/bash
#docker run -it -d pbordoyedrans/nagiosclient
echo "Starting Compose"
docker.compose up --build -d


#Loop till compose start, then exec service script in both containers
while true
do
if [ -z "$SERV" ] && [ -z "$CLIE" ]; then
	echo "Todavia no arranco container"
	SERV=$(docker ps | grep docker_server | awk  '{print $1}')
	CLIE=$(docker ps | grep docker_client | awk  '{print $1}')
else
      echo "Arranco, iniciando servicios..."
      docker exec -ti $SERV "/tmp/inicio_servicios.sh"
      docker exec -ti $CLIE "/tmp/inicio_servicios.sh"
      break
fi
done


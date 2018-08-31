#!/bin/bash
docker run -it -d pbordoyedrans/nagiosclient
#Entro en loop hasta que arranque container
while true
do
if [ -z "$CONT" ]; then
	echo "Todavia no arranco container"
	CONT=$(docker ps | grep pbordoyedrans/nagiosclient | awk  '{print $1}')
else
      echo "Arranco, iniciando servicios..."
      docker exec -ti $CONT "/tmp/inicio_servicios.sh"
      break
fi
done

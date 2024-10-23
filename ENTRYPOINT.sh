#!/bin/sh
if [ "$EULA" = "TRUE" ]; then
	echo "eula=true" > eula.txt

	rm -f server.properties
	[ -f "/init/server.properties" ] && cp /init/server.properties server.properties || echo "Warning: /init/server.properties not found."

	[ -f "/init/rcon.yaml" ] && cp /init/rcon.yaml /etc/rcon.yaml || echo "Warning: /init/rcon.yaml not found."

	if [ -n "$RCON_PASSWORD" ]; then
		sed -i "s/^password:.*/password: $RCON_PASSWORD/" /etc/rcon.yaml
		sed -i "s/^rcon\.password=.*/rcon.password=$RCON_PASSWORD/" server.properties
	fi

	grep "^sync-chunk-writes" server.properties || echo "sync-chunk-writes=false" >>server.properties

	if [ -d "/extra_mods" ]; then
		echo "Copying extra mods..."
		rsync -av --exclude="README.md" --exclude=".gitignore" /extra_mods/ /data/mods/
	fi

	if [ -d "/extra_datapacks" ]; then
		if [ ! -d "/data/datapacks" ]; then
			mkdir -p /data/datapacks
		fi
		echo "Copying extra datapacks..."
		rsync -av --exclude="README.md" --exclude=".gitignore" /extra_datapacks/ /data/datapacks/
	fi

	if [ -n "$ALLOCATED_RAM" ]; then
		exec java -Xms"${ALLOCATED_RAM}G" -Xmx"${ALLOCATED_RAM}G" -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=40 -XX:G1MaxNewSizePercent=50 -XX:G1HeapRegionSize=16M -XX:G1ReservePercent=15 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=20 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true -jar server.jar --nogui
	else
		echo "Incorrect value for ALLOCATED_RAM provided or .env file missing. Please consult the README instructions if you haven't yet."
	fi
else
	echo "Mojang EULA not accepted. Run with -e EULA=TRUE or update the docker-compose.yaml file to accept."
fi
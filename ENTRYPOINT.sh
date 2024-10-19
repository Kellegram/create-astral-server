#!/bin/sh
if [ "$EULA" = "TRUE" ]; then
	echo "eula=true" > eula.txt

	rm -f server.properties
	[ -f "/init/server.properties" ] && cp /init/server.properties server.properties
	touch server.properties

	if [ -n "$RCON_PASSWORD" ]; then
		grep "^rcon.password" server.properties || echo "rcon.password=$RCON_PASSWORD" >>server.properties
		grep "^enable-rcon" server.properties || echo "enable-rcon=true" >>server.properties
	fi

	grep "^sync-chunk-writes" server.properties || echo "sync-chunk-writes=false" >>server.properties

	if [ -d "/extra_mods" ]; then
		echo "Copying extra mods..."
		cp -r /extra_mods/* /data/mods/
	fi

	if [ -d "/extra_datapacks" ]; then
		if [ ! -d "/data/datapacks" ]; then
			mkdir -p /data/datapacks
		fi
		echo "Copying extra datapacks..."
		cp -r /extra_datapacks/* /data/datapacks/
	fi

	if [ -n "$ALLOCATED_RAM" ]; then
		exec java -Xms"$ALLOCATED_RAM"G -Xmx"$ALLOCATED_RAM"G -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=40 -XX:G1MaxNewSizePercent=50 -XX:G1HeapRegionSize=16M -XX:G1ReservePercent=15 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=20 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true -jar server.jar --nogui
	else
		echo "Incorrect value for ALLOCATED_RAM provided or .env file missing. Please consult the README instructions if you haven't yet."
	fi
else
	echo "Mojang EULA not accepted. Run with -e EULA=TRUE or update the docker-compose.yaml file to accept."
fi
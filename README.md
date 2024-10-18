# Create: Astral server docker container

## Description
This repository contains the necessary files to build a Docker container for launching a Minecraft server with the Create: Astral modpack, using GraalVM Java 17. This container allows for additional customisation to the server pack beyond the defaults.

## Instructions
*This container assumes that you possess at least some basic knowledge of navigating the linux commandline. I will link some resources further down for command basics and docker basics.*

### Initial setup
1. Clone the repository to an empty folder of your choice.
2. Copy the examples from the [`templates`](templates/) folder to the root of the folder (removing the .example from the name) or use your own if you prepared them or are re-installing
3. Update the templates as appropriate for your server, keeping in mind the following:
- You need to provide a password for rcon in the .env file. Also change default ram allocation for the server as needed.
- `server.properties` only needs you to change options which are differnt to defaults (see https://server.properties for defaults), I provided the rcon related ones as you need to put a password that matches your .env file there
- `ops.json` and `whitelist.json` are optional, make sure to actually change both the names and uuids. Feel free to add more or less players there
- The templates are separated so that no one accidentally commits/PRs their actual secrets, keep the examples in templates folder as is
4. Open rcon.yaml and put a matching password from your .env file. If you edited the rcon port, make sure to change it here too.
5. Once you are ready to run the container, simply run `docker compose up -d` in the root folder where you cloned the repo

### Config files
This container exposes the config folder as a docker volume. Unless you changed something, it should be located in `/var/lib/docker/volumes/`. Feel free to edit these as needed. For now there is no way provided to merge config changes in updates with your custom changes. You will need to keep track yourself. Making a basic shell script that edits these configs with sed might be desirable and easier than manually re-doing it every time.

### Adding mods
If you want to add additional mods to the server, the best way to do it would be to put them in the `extra_mods` folder. They will be copied over to the container for you. Just treat that folder as if it was the `mods/` folder on the server.

### Adding datapacks
If you want to add additional datapacks to the server, the best way to do it would be to put them in the `extra_datapacks` folder. They will be copied over to the container for you. Just treat that folder as if it was the datapacks folder on the server.


## Learning Resources
- [Docker basics](https://docker-curriculum.com/)
- [Docker compose basics](https://docker-curriculum.com/#docker-compose)
- [Docker manuals](https://docs.docker.com/manuals/)
- [Linux commandline basics](https://ubuntu.com/tutorials/command-line-for-beginners#1-overview)

## Disclaimer
I do not own any of the software or mods contained in this repository. All rights and ownership belong to their respective creators, as listed below.
**Note:** This repository does not include any mods, modloaders, or the Create: Astral modpack directly. They will be downloaded during the container's startup process.

## Credits
- This container is inspired by a similar [container](https://github.com/maxi0604/create-astral-container) by [maxi0604](https://github.com/maxi0604)

- **[GraalVM Java 17](https://www.graalvm.org/)**: GraalVM is a high-performance runtime that provides significant improvements in application performance and efficiency. GraalVM is licensed under the Oracle Free Terms and Conditions (OFTC) for GraalVM Community Edition.
  
  - License: [GraalVM License](https://www.oracle.com/downloads/licenses/graal-free-license.html)
  - Copyright © Oracle and/or its affiliates.
  
- **[Fabric Modloader](https://fabricmc.net/)**: Fabric is a lightweight, experimental modding toolchain for Minecraft.
  
  - License: [MIT License](https://www.curseforge.com/minecraft/mc-mods/fabric-api#license)
  - Copyright © FabricMC.
  
- **[Create: Astral](https://www.curseforge.com/minecraft/modpacks/create-astral)**: Create: Astral is a modpack designed for Minecraft, focused on exploration and automation through the "Create" mod.
  
  - License: The modpack is distributed via CurseForge and may include multiple mods with different licenses. Please refer to the respective mod pages for details.

## Usage
This Docker container is for personal use only. Please ensure that you comply with the licenses and terms of service for each software, mod, or tool used within this container.
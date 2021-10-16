# Lucifer

Lucifer is a multiplayer roguelite hack 'n slash dungeon crawler created for our school's 2021-2022 year long project. We were tasked with creating a full game in the span of a year.

Since this project is still under development and is in no-way near finished, builds are not provided. You can build the source yourself in [Godot](https://godotengine.org/).

## Building

The server is written in [Node.JS](https://nodejs.org) and doesn't need to be built. Just run `npm install` in the `server` folder. Edit `config.json` and run `npm start` or `node --experimental-json-modules index` and you're good to go!

The game itself is written in [Godot](https://nodejs.org)'s GDScript. You can get the latest version [here](https://godotengine.org/download). Open up the project in the `client` folder inside of Godot and hit F5 to run the project. To actually build it, head to the top left and hit **Project > Export**.

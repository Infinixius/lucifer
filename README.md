<p align="center">
<img width=645.45 height=274.95  src="https://github.com/Infinixius/lucifer/blob/main/client/assets/meta/title_inner.png?raw=true">
</p>

___

Lucifer is a multiplayer roguelite hack 'n slash dungeon crawler created for our school's 2021-2022 year long project. We were tasked with creating a full game in the span of a year.

Since this project is still under development and is in no-way near finished, builds are not provided. You can build the source yourself in [Godot](https://godotengine.org/).

We decided to release the code, open-sourced here on GitHub in the hope that someone else in the future may find it useful, or for our classmates to find it useful.

## Building

The server is written in [Node.JS](https://nodejs.org) and doesn't need to be built. Just run `npm install` in the `server` folder. Edit `config.json` and run `npm start` or `node --experimental-json-modules index` and you're good to go!

The game itself is written in [Godot](https://godotengine.org/)'s GDScript. You can get the latest version [here](https://godotengine.org/download). Open up the project in the `client` folder inside of Godot and hit F5 to run the project. To actually build it, head to the top left and hit **Project > Export**.

## License

The game is licensed under the [MIT License](https://github.com/Infinixius/lucifer/blob/main/LICENSE). This allows you to use, modify, and distribute the source code as long as you include the license.

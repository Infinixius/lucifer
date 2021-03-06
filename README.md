<p align="center">
<img width=645.45 height=274.95  src="https://github.com/Infinixius/lucifer/blob/main/client/assets/meta/title_inner.png?raw=true">
</p>

___

Lucifer is a multiplayer roguelite hack 'n slash dungeon crawler created for our school's 2021-2022 year long project. We were tasked with creating a full game in the span of a year.

You can download the game at [https://lucifer.games/download](https://lucifer.games/download). **Keep in mind the game is still in an unfinished and buggy state.** You can leave us feedback on how to improve the game at [https://lucifer.games/feedback](https://lucifer.games/feedback)!

We decided to release the code, open-sourced here on GitHub in the hope that someone else in the future may find it useful, or for our classmates to find it useful.

## Building

The server is written in [Node.JS](https://nodejs.org) and doesn't need to be built. Just run `npm install` in the `server` folder. Edit `config.json` and run `npm start` or `node --experimental-json-modules index` and you're good to go!

The game itself is written in [Godot](https://godotengine.org/)'s GDScript. You can get the latest version [here](https://godotengine.org/download). Open up the project in the `client` folder inside of Godot and hit F5 to run the project. To actually build it, head to the top left and hit **Project > Export**.

## Screenshots

<p align="center">
  <img width=45% src="https://lucifer.games/assets/screenshot1.png">
  <img width=45% src="https://lucifer.games/assets/screenshot2.png">
  <img width=45% src="https://lucifer.games/assets/screenshot4.png">
  <img width=45% src="https://lucifer.games/assets/screenshot5.png">
  <img width=45% src="https://lucifer.games/assets/screenshot6.png">
  <img width=45% src="https://lucifer.games/assets/screenshot3.png">
</p>


## Privacy

Every time you boot up the game, a small amount of information is sent to our server. This information includes: your IP address, your system language, your operating system version, CPU & GPU information, your monitor size, and the amount of time it took for the game to load.

This information is useful to us and helps us improve the game. This also allows the game to check for updates and warn you if you're on an old version. If you don't like this, you can either disable the "Analytics" options in options, or run the game with the `-noanalytics` launch option. 

## Credits

A list of all the amazing people who made this project possible can be found [here!](https://github.com/Infinixius/lucifer/blob/main/CREDITS.md)

## License

The game is licensed under the [MIT License](https://github.com/Infinixius/lucifer/blob/main/LICENSE). This allows you to use, modify, and distribute the source code as long as you include the license.

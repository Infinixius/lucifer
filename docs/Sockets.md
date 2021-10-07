# Sockets

This document explains the events sent across the WebSocket connection used by the game. The server is powered by [Node.JS's ws module](https://github.com/websockets/ws), and the client powered by Godot's native [WebSocketClient](https://docs.godotengine.org/en/stable/classes/class_websocketclient.html).

Each event should have the following structure:
```
{
	"type": "ping", // type of the message
	"timestamp": 0, // unix timestamp (in milliseconds) of this message's send date
	"message": 0 // the message intended to be sent along with the event, usually a JSON object.
}
```

Events prefixed with `>` are intended to be sent from the server, and events prefixed with `<` are intended to be sent from the client.

## > ping

Sent every 1000 milliseconds and expects the `< pong` reply. Used to calculate the latency/ping of the client.

## < pong

Sent in response to any `> ping` events received from the server. Used to calculate the latency/ping of the client.

## < player_connect

Sent at the beginning of the WebSocket connection and is intended to include any information such as the player's name, character, etc.

## > player_connect

Broadcasted to all clients upon a new client connecting. Includes the player's ID.

- **id** - ID of the new player.

## > player_initalize

Sent to a player upon connecting to the server. Includes information about the current state of the game and players.

- **id** - ID of the client.
- **players** - Array of players. Example:
```
[
	{
		"id": 1
	},
	{
		"id": 2
	},
	{
		"id": 3
	}
]
```

## > player_move

Sent upon a player moving. Collision is handled on the client of the player who's moving.

- **id** -- ID of the player movement
- **x** - The new X coordinate of the player.
- **y** - The new Y coordinate of the player.

## < player_move

Sent from the client every 0.015 seconds with the client's new position, to be sent to all other clients through `> player_move`	. Collision is handled client-side by the player who calls this event.

- **id** -- ID of the player movement
- **x** - The new X coordinate of the player.
- **y** - The new Y coordinate of the player.
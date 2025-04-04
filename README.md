# MindsterGames

## TODO

- [ ] Reconnect based on csrf token
- [ ] Leave game
- [ ] Pick name (just csrf token for now)
- [ ] Allow different game types

Dynamic creation of rooms
- [ ] Can join game
- [ ] Can leave game
- [ ] Can create game
- [ ] Can end game
- [ ] Add room_id in form "AB12"
- [ ] Be able to look up game by its room_id (maybe use :syn)
- [ ] Be able to call game genserver by its room id (again, :syn)
- [ ] Have unique ID's (sqlite)
- [ ] Crash behavior

## Development
To start your Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Game types

### Potentiometer Game

Based on the board game Wavelength

_[View in PlantText](https://www.planttext.com/)_

```plantuml
@startuml
[*] --> AwaitingPlayers

AwaitingPlayers --> AwaitingPlayers : Not enough players joined
AwaitingPlayers --> HinterPicking : Enough players joined
HinterPicking --> GuesserPicking : Hinter gives hint
GuesserPicking --> RevealResult : Guesser submits guess
RevealResult --> HinterPicking : No team has won
RevealResult --> GameFinished : A team has won
GameFinished --> AwaitingPlayers : Game restarts

@enduml
```

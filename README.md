# omega-sentinel

omega-sentinel is a chat bot built on the [Hubot](https://hubot.github.com/) framework. For more info, see [HUBOT.md](HUBOT.md)

## Development

1. Create/Update/Delete some scripts in the `scripts/` folder
1. Run `./bin/hubot`

### Linting

- Lints are set to automatically run on git pushes
- `npm run lint` to run linter manually

## Production

Hubot is deployed using Docker and Docker Compose.

### Initial Setup
1. Clone this repository
1. Copy sample env file `cp .env.example .env`
1. Modify the env file with secrets `$EDITOR .env`
1. Build image and Run `make`

### Update hubot
1. `git pull && make`

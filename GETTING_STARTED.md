# Getting Started

- Run the following command to from inside your project folder to bootstrap a new project with this devcontainer:

```bash
mkdir .devcontainer
touch .devcontainer/devcontainer.json
touch .devcontainer/docker-compose.yml
```

- Add the following content to the `devcontainer.json` file:

```json
{
    "name": "<PROJECT_NAME>",
    "dockerComposeFile": [
        "./docker-compose.yml"
    ],
    "service": "vscode",
    "runServices": [
        "vscode"
    ],
    "remoteUser": "<USERNAME>",
    "shutdownAction": "stopCompose",
    "postCreateCommand": "~/.start.sh",
    "workspaceFolder": "/workspace"
}
```

- Add the following content to the `docker-compose.yml` file:

```yaml
version: "3.7"

services:
  vscode:
    image: ghcr.io/betterdevcontainers/devcontainer-base:main
    volumes:
      - ../:/workspace
      - /var/run/docker.sock:/var/run/docker.sock
      - ~/.ssh:/mnt/ssh
      - ~/.zsh_history:/home/<USERNAME>/.zsh_history
      - ~/.gitconfig:/home/<USERNAME>/.initial_gitconfig
    environment:
      - TZ=
    entrypoint: ["zsh", "-c", "while sleep 1000; do :; done"]
```

# Open WebUI

Open WebUI is a self-hosted web interface for various LLMs.
It uses the APIs of the model providers which is considerably **cheaper** than subscribing to the subscriptions. You pay only for your usage.

Another benefit is that you can use **multiple models** from different providers **in one place** and are not bound to one if you don't want to pay for multiple subscriptions at the same time.

https://github.com/open-webui/open-webui

## Setup

I wrote a shell function which starts the Open WebUI container with just one command.

Copy-paste this into your terminal to add the `open-webui` function to your shell:
```bash
echo 'function open-webui() {
    local persist_dir="/sgoinfre/goinfre/Perso/$USER/open-webui"
    local container_name="open-webui"

    if [ "$1" = "stop" ]; then
        # Stop the container if it is running
        if docker ps --filter "name=$container_name" --format "{{.Names}}" | grep -q "^$container_name$"; then
            docker stop $container_name > /dev/null
            echo "$container_name container stopped"
        else
            echo "$container_name container is not running"
        fi
    else
        # Ensure the host directory exists
        if [ ! -d "$persist_dir" ]; then
            mkdir -p "$persist_dir"
            echo "Directory $persist_dir created"
        fi
        # Start the container if it is not running
        if docker ps --filter "name=$container_name" --format "{{.Names}}" | grep -q "^$container_name$"; then
            port=$(docker port $container_name 8080/tcp | cut -d : -f2)
            echo "$container_name container already running"
            echo "Open WebUI is running on http://localhost:$port"
        elif docker ps -a --filter "name=$container_name" --format "{{.Names}}" | grep -q "^$container_name$"; then
            docker start $container_name > /dev/null
            port=$(docker port $container_name 8080/tcp | cut -d : -f2)
            echo "$container_name container started"
            echo "Open WebUI is now running on http://localhost:$port"
        else
            docker run -d -p 3000:8080 -v "$persist_dir":/app/backend/data --name $container_name --restart always ghcr.io/open-webui/open-webui:main > /dev/null
            port=$(docker port $container_name 8080/tcp | cut -d : -f2)
            echo "$container_name container created and started"
            echo "Open WebUI is now running on http://localhost:$port"
        fi
    fi
}' | tee -a ~/.zshrc ~/.bashrc
exec $SHELL
```

### Usage

```
open-webui [stop]
```

Open WebUI is then running on `http://localhost:3000`.

---

### OpenAI ChatGPT support

1. Get your OpenAI API key from here: https://platform.openai.com/api-keys

2. Add your API key here: `Username > Admin Panel > Settings > Connections > API Key > Validate the key (circular arrows icon)`

3. In order for the premium models to show up, you need to add some credit balance to your OpenAI account here: https://platform.openai.com/settings/organization/billing/overview

4. Refresh the page

### Anthropic Claude support

1. Install this function in the WebUI: https://openwebui.com/f/justinrahb/anthropic

2. Get your Anthropic API key from here and then click on Save: https://console.anthropic.com/settings/keys

3. Add your API key here: `Workspace > Functions > Anthropic (settings icon) > Default`

4. Enable the Anthropic function (toggle on the right)

5. In order to use any models from Anthropic, you need to add some credit balance to your Anthropic account here: https://console.anthropic.com/settings/plans

6. Refresh the page

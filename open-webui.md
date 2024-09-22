# Open WebUI

Open WebUI is a self-hosted web interface for various LLMs.
It uses the APIs of the model providers which is considerably **cheaper** than subscribing to the subscriptions. You pay only for your usage.

Another benefit is that you can use **multiple models** from different providers **in one place** and are not bound to one if you don't want to pay for multiple subscriptions at the same time.

https://github.com/open-webui/open-webui

## Setup

I wrote a shell function which starts the Open WebUI container with just one command.

Copy-paste this into your terminal to add the `open-webui` function to your shell.
```bash
echo 'function open-webui() {
    local persist_dir="/sgoinfre/goinfre/Perso/$USER/open-webui"

    if [ "$1" = "stop" ]; then
        # Stop the container if it's running
        if docker ps --filter "name=open-webui" --format "{{.Names}}" | grep -q "^open-webui$"; then
            docker stop open-webui > /dev/null
            echo "open-webui container stopped"
        else
            echo "open-webui container is not running"
        fi
    else
        # Ensure the host directory exists
        if [ ! -d "$persist_dir" ]; then
            mkdir -p "$persist_dir"
            echo "Directory $persist_dir created"
        fi
        # Start the container if it's not running
        if docker ps --filter "name=open-webui" --format "{{.Names}}" | grep -q "^open-webui$"; then
            echo "open-webui container already running"
        elif docker ps -a --filter "name=open-webui" --format "{{.Names}}" | grep -q "^open-webui$"; then
            docker start open-webui > /dev/null
            echo "open-webui container started"
        else
            docker run -d -p 3000:8080 -v "$persist_dir":/app/backend/data --name open-webui --restart always ghcr.io/open-webui/open-webui:main
            echo "open-webui container created and started"
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

Get your OpenAI API key from here: https://platform.openai.com/api-keys

Add your API key here: `Username > Admin Panel > Settings > Connections > API Key`

In order for the premium models to show up, you need to add some credit balance to your OpenAI account here: https://platform.openai.com/settings/organization/billing/overview

### Anthropic Claude support

Install this function in the WebUI: https://openwebui.com/f/justinrahb/anthropic

Get your Anthropic API key from here: https://console.anthropic.com/settings/keys

Add your API key here: `Workspace > Functions > Anthropic (Settings icon) > Default`

In order to use any models from Anthropic, you need to add some credit balance to your Anthropic account here: https://console.anthropic.com/settings/plans

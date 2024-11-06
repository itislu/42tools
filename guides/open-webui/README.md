# Open WebUI

Open WebUI is a self-hosted web interface for various LLMs.
It uses the APIs of the model providers which is considerably **cheaper** than subscribing to the subscriptions. You pay only for your usage.

Another benefit is that you can use **multiple models** from different providers **in one place** and are not bound to one if you don't want to pay for multiple subscriptions at the same time.

https://github.com/open-webui/open-webui

## Setup

I wrote a shell function which starts the Open WebUI container with just one command.

Copy-paste this into your terminal to add the `open-webui` function to your shell:
```bash
# Remove any existing open-webui function
sed -i '/^function open-webui()/,/^}/d' ~/.zshrc ~/.bashrc 2>/dev/null || true

# Add the open-webui function
tee -a ~/.zshrc ~/.bashrc >/dev/null << 'EOF'

function open-webui() {
    local persist_dir="$HOME/open-webui"
    local container_name="open-webui"
    local image_name="ghcr.io/open-webui/open-webui:main"

    # Nested function to handle updates
    function update_container() {
        echo "Checking for updates..."
        # Pull latest image
        if docker pull $image_name > /dev/null; then
            # Compare current container image ID with latest image ID
            local current_image=$(docker inspect --format '{{.Image}}' $container_name)
            local latest_image=$(docker inspect --format '{{.Id}}' $image_name)

            if [ "$current_image" != "$latest_image" ]; then
                echo "Update available. Recreating container..."
                # Stop the current container
                docker stop $container_name > /dev/null
                # Remove the old container
                docker rm $container_name > /dev/null
                # Create and start new container with the latest image
                if docker run -d -p 3000:8080 -v "$persist_dir":/app/backend/data --name $container_name --restart always $image_name > /dev/null; then
                    show_port
                    return 2  # Indicate update was applied
                else
                    echo "Failed to create new container"
                    return 1
                fi
            else
                echo "Container is already up to date"
                return 0
            fi
        else
            echo "Failed to check for updates"
            return 1
        fi
    }

    # Nested function to display the running port
    function show_port() {
        local port=$(docker port $container_name 8080/tcp | cut -d : -f2)
        echo "Open WebUI is running on http://localhost:$port"
    }

    if [ "$1" = "stop" ]; then
        # Stop the container if it is running
        if docker ps --filter "name=$container_name" --format "{{.Names}}" | grep -q "^$container_name$"; then
            docker stop $container_name > /dev/null
            echo "$container_name container stopped"
        else
            echo "$container_name container is not running"
        fi
    elif [ "$1" = "update" ]; then
        if docker ps -a --filter "name=$container_name" --format "{{.Names}}" | grep -q "^$container_name$"; then
            update_container
        else
            echo "Container doesn't exist. Run open-webui first to create it."
        fi
    else
        # Ensure the host directory exists
        if [ ! -d "$persist_dir" ]; then
            if mkdir -p "$persist_dir"; then
                echo "Directory $persist_dir created"
            else
                echo "Failed to create directory $persist_dir"
                return 1
            fi
        fi

        # Start or create the container
        if docker ps --filter "name=$container_name" --format "{{.Names}}" | grep -q "^$container_name$"; then
            echo "$container_name container already running"
            show_port
        elif docker ps -a --filter "name=$container_name" --format "{{.Names}}" | grep -q "^$container_name$"; then
            # Check for updates before starting the existing container
            update_container
            local update_status=$?

            if [ $update_status -eq 2 ]; then
                # Container was already updated and started by update_container
                return 0
            elif [ $update_status -eq 1 ]; then
                echo "Update failed, starting existing container..."
            fi

            # Start the existing container if no update was applied
            if docker start $container_name > /dev/null; then
                echo "$container_name container started"
                show_port
            else
                echo "Failed to start $container_name container"
                return 1
            fi
        else
            echo "Creating new container..."
            if docker run -d -p 3000:8080 -v "$persist_dir":/app/backend/data --name $container_name --restart always $image_name > /dev/null; then
                echo "$container_name container created and started"
                show_port
            else
                echo "Failed to create and start $container_name container"
                return 1
            fi
        fi
    fi
}

EOF
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

2. Add your API key [here](http://localhost:3000/admin/settings): `Connections > API Key > Validate the key (circular arrows icon)`

3. In order for the premium models to show up, you need to add some credit balance to your OpenAI account here: https://platform.openai.com/settings/organization/billing/overview

4. Refresh the page

### Anthropic Claude support

1. Install the Anthropic function in the WebUI

   - **With Open WebUI account:**<br>
     https://openwebui.com/f/justinrahb/anthropic

   - **Without Open Webui account:**<br>
     In order to conveniently install the function you will have to create an account on openwebui.com.<br>
     I think it is worth it because it gives you access to a marketplace of functions and more to customize the UI and extend its functionality - kind of like extensions for VS Code.<br>
     If you don't want to do that, you can download the Anthropic function here and import it manually:
     ```bash
     curl -LO https://raw.githubusercontent.com/itislu/42tools/refs/heads/main/guides/open-webui/Anthropic-function.json
     ```

2. Get your Anthropic API key from here and then click on Save: https://console.anthropic.com/settings/keys

3. Add your API key [here](http://localhost:3000/workspace/functions): `Anthropic (settings icon) > Default`

4. Enable the Anthropic function (toggle on the right)

5. In order to use any models from Anthropic, you need to add some credit balance to your Anthropic account here: https://console.anthropic.com/settings/plans

6. Refresh the page

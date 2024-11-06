#!/usr/bin/env bash

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

# Execute the new shell to load the function
exec $SHELL

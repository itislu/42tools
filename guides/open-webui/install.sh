#!/usr/bin/env bash

echo " 🔧 Starting open-webui shell function installation..."

# Check which shells' config files exist
echo " 📋 Checking for shell configuration files..."
shells_updated=0

if [ -f ~/.zshrc ]; then
    echo "  ✓ Found .zshrc"
    shells_updated=$((shells_updated + 1))
fi

if [ -f ~/.bashrc ]; then
    echo "  ✓ Found .bashrc"
    shells_updated=$((shells_updated + 1))
fi

if [ $shells_updated -eq 0 ]; then
    echo " ⚠️  No shell configuration files found (.zshrc or .bashrc)"
    exit 1
fi

echo " 🗑️  Removing any existing open-webui function..."
# Remove any existing open-webui function
if sed -i '/^function open-webui()/,/^}/d' ~/.zshrc ~/.bashrc 2>/dev/null; then
    echo " ✅ Cleaned up existing function definitions"
else
    echo " ℹ️ No existing function found, cleanup not needed"
fi

echo " 📝 Adding new open-webui function to shell configuration files..."
# Add the open-webui function
tee -a ~/.zshrc ~/.bashrc >/dev/null << 'EOF'

function open-webui() {
    local persist_dir="$HOME/open-webui"
    local container_name="open-webui"
    local image_name="ghcr.io/open-webui/open-webui:main"

    # Nested function to show help
    function show_help() {
        echo " 📚 Open WebUI Usage:"
        echo "    open-webui           - Start or create the container"
        echo "    open-webui stop      - Stop the container"
        echo "    open-webui update    - Update the container"
        echo "    open-webui help      - Show this help message"
    }

    # Nested function to show help reminder
    function show_help_reminder() {
        echo " 💡 Tip: Use 'open-webui help' to see all available commands"
    }

    # Nested function to handle updates
    function update_container() {
        echo " 🔍 Checking for updates..."
        echo " 📥 Pulling latest image from repository..."
        if docker pull $image_name; then
            echo " ✅ Image pull completed"
            # Compare current container image ID with latest image ID
            local current_image=$(docker inspect --format '{{.Image}}' $container_name)
            local latest_image=$(docker inspect --format '{{.Id}}' $image_name)
            echo " 📋 Current image: ${current_image:0:12}"
            echo " 📋 Latest image: ${latest_image:0:12}"

            if [ "$current_image" != "$latest_image" ]; then
                echo " 🆕 New version detected!"
                echo " 🛑 Stopping current container..."
                docker stop $container_name > /dev/null
                echo " 🗑️  Removing old container..."
                docker rm $container_name > /dev/null
                echo " 🚀 Creating new container with latest image..."
                if docker run -d -p 3000:8080 -v "$persist_dir":/app/backend/data --name $container_name --restart always $image_name > /dev/null; then
                    echo " ✅ Container successfully updated and started"
                    show_port
                    return 2  # Indicate update was applied
                else
                    echo " ❌ Failed to create new container"
                    return 1
                fi
            else
                echo " ✅ Container is already running latest version"
                return 0
            fi
        else
            echo " ❌ Failed to check for updates"
            return 1
        fi
    }

    # Nested function to display the running port
    function show_port() {
        local port=$(docker port $container_name 8080/tcp | cut -d : -f2)
        echo " 🌐 Open WebUI is running on http://localhost:$port"
    }

    if [ "$1" = "help" ] || [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
        show_help
        return 0
    elif [ "$1" = "stop" ]; then
        echo " 🛑 Attempting to stop container..."
        # Stop the container if it is running
        if docker ps --filter "name=$container_name" --format "{{.Names}}" | grep -q "^$container_name$"; then
            docker stop $container_name > /dev/null
            echo " ✅ $container_name container stopped"
        else
            echo " ℹ️ $container_name container is not running"
        fi
    elif [ "$1" = "update" ]; then
        if docker ps -a --filter "name=$container_name" --format "{{.Names}}" | grep -q "^$container_name$"; then
            update_container
        else
            echo " ❌ Container doesn't exist. Run open-webui first to create it."
        fi
    else
        # Ensure the host directory exists
        if [ ! -d "$persist_dir" ]; then
            echo " 📁 Creating persistent directory..."
            if mkdir -p "$persist_dir"; then
                echo " ✅ Directory $persist_dir created"
            else
                echo " ❌ Failed to create directory $persist_dir"
                show_help_reminder
                return 1
            fi
        fi

        # Start or create the container
        if docker ps --filter "name=$container_name" --format "{{.Names}}" | grep -q "^$container_name$"; then
            echo " ℹ️ $container_name container already running"
            show_port
        elif docker ps -a --filter "name=$container_name" --format "{{.Names}}" | grep -q "^$container_name$"; then
            echo " 📦 Found existing container"
            update_container
            local update_status=$?

            if [ $update_status -eq 2 ]; then
                # Container was already updated and started by update_container
                show_help_reminder
                return 0
            elif [ $update_status -eq 1 ]; then
                echo " ⚠️  Update failed, starting existing container..."
            fi

            # Start the existing container if no update was applied
            if docker start $container_name > /dev/null; then
                echo " ✅ $container_name container started"
                show_port
            else
                echo " ❌ Failed to start $container_name container"
                show_help_reminder
                return 1
            fi
        else
            echo " 🆕 Creating new container..."
            if docker run -d -p 3000:8080 -v "$persist_dir":/app/backend/data --name $container_name --restart always $image_name > /dev/null; then
                echo " ✅ $container_name container created and started"
                show_port
            else
                echo " ❌ Failed to create and start $container_name container"
                show_help_reminder
                return 1
            fi
        fi
    fi
    show_help_reminder
}

EOF

echo " ✅ open-webui function added to shell configuration files"

# Reload the shell configuration
current_shell=$(basename "$SHELL")
echo " 🔄 Reloading shell configuration ($current_shell)..."
source ~/.${current_shell}rc

# Show initial help message
echo " ✨ Installation complete!"
open-webui help

# Execute a new shell to load the function
exec $SHELL

#!/bin/bash

# Determine current directory name and path
CURRENT_DIR=$(pwd)
PROJECT_NAME=$(basename "$CURRENT_DIR")

echo "🛠️  Retrofitting existing project: $PROJECT_NAME"

# 1. Enforce -dev naming convention
if [[ "$PROJECT_NAME" != *-dev ]]; then
    echo "❌ Error: This script must be run inside a folder ending in -dev (e.g. /opt/my-app-dev)"
    exit 1
fi

# 2. Ask for prod server details
read -p "Enter the prod server IP: " PROD_IP
read -p "Enter the prod server SSH port: " PROD_PORT
read -p "Enter the prod server SSH user: " PROD_USER

# 3. Auto-strip "-dev" for prod folder name
PROD_FOLDER="${PROJECT_NAME%-dev}"
TEMPLATE_DIR="$HOME/cursor-template"

# 4. Handle .cursorignore
if [ -f ".cursorignore" ]; then
    read -p "⚠️  .cursorignore already exists. Overwrite? (y/n): " IGNORE_CONFIRM
    if [ "$IGNORE_CONFIRM" == "y" ]; then
        cp "$TEMPLATE_DIR/.cursorignore" .cursorignore
        echo "✅ Updated .cursorignore"
    fi
else
    cp "$TEMPLATE_DIR/.cursorignore" .cursorignore
    echo "✅ Added .cursorignore"
fi

# 5. Handle tasks.json
mkdir -p .vscode
if [ -f ".vscode/tasks.json" ]; then
    echo "⚠️  Existing tasks.json found."
    read -p "👉 Overwrite with new standard? (y/n): " TASK_CONFIRM
    if [ "$TASK_CONFIRM" == "y" ]; then
        mv ".vscode/tasks.json" ".vscode/tasks.json.old"
        echo "💾 Backed up old tasks to .vscode/tasks.json.old"
        
        # Generate new tasks.json
        cat > ".vscode/tasks.json" <<EOF
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "🤖 : Claude : Development",
            "type": "shell",
            "command": "/bin/bash",
            "args": [
                "-c",
                "cd /opt/$PROJECT_NAME && /bin/bash"
            ],
            "presentation": {
                "reveal": "always",
                "panel": "shared"
            },
            "runOptions": {
                "runOn": "folderOpen"
            }
        },
        {
            "label": "💻 : Local : Development",
            "type": "shell",
            "command": "/bin/bash",
            "args": [
                "-c",
                "cd /opt/$PROJECT_NAME && /bin/bash"
            ],
            "presentation": {
                "reveal": "always",
                "panel": "shared"
            },
            "runOptions": {
                "runOn": "folderOpen"
            }
        },
        {
            "label": "🚀 : Live : Production",
            "type": "shell",
            "command": "ssh -p $PROD_PORT -t $PROD_USER@$PROD_IP 'cd /opt/$PROD_FOLDER && exec bash --login'",
            "presentation": {
                "reveal": "always",
                "panel": "shared"
            },
            "runOptions": {
                "runOn": "folderOpen"
            }
        }
    ]
}
EOF
        echo "✅ Generated new standard tasks.json"
    fi
else
    # Just create it if it didn't exist
    # (Same cat command as above)
    cat > ".vscode/tasks.json" <<EOF
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "🤖 : Claude : Development",
            "type": "shell",
            "command": "/bin/bash",
            "args": [
                "-c",
                "cd /opt/$PROJECT_NAME && /bin/bash"
            ],
            "presentation": {
                "reveal": "always",
                "panel": "shared"
            },
            "runOptions": {
                "runOn": "folderOpen"
            }
        },
        {
            "label": "💻 : Local : Development",
            "type": "shell",
            "command": "/bin/bash",
            "args": [
                "-c",
                "cd /opt/$PROJECT_NAME && /bin/bash"
            ],
            "presentation": {
                "reveal": "always",
                "panel": "shared"
            },
            "runOptions": {
                "runOn": "folderOpen"
            }
        },
        {
            "label": "🚀 : Live : Production",
            "type": "shell",
            "command": "ssh -p $PROD_PORT -t $PROD_USER@$PROD_IP 'cd /opt/$PROD_FOLDER && exec bash --login'",
            "presentation": {
                "reveal": "always",
                "panel": "shared"
            },
            "runOptions": {
                "runOn": "folderOpen"
            }
        }
    ]
}
EOF
    echo "✅ Generated standard tasks.json"
fi

echo ""
echo "🎉 Retrofit complete for $PROJECT_NAME!"

#!/bin/bash

echo "🚀 Starting new Cursor project setup..."

# 1. Ask for project name
read -p "Enter the new project folder name (e.g. my-app-dev): " PROJECT_NAME

# 2. Enforce -dev naming convention
if [[ "$PROJECT_NAME" != *-dev ]]; then
    echo "❌ Error: Project name must end with -dev (e.g. my-app-dev)"
    echo "👉 Convention: Dev folder = /opt/my-app-dev | Prod folder = /opt/my-app"
    exit 1
fi

# 3. Ask for prod server details
read -p "Enter the prod server IP: " PROD_IP
read -p "Enter the prod server SSH port: " PROD_PORT
read -p "Enter the prod server SSH user: " PROD_USER

# 4. Auto-strip "-dev" for prod folder name
PROD_FOLDER="${PROJECT_NAME%-dev}"

TARGET_DIR="/opt/$PROJECT_NAME"
TEMPLATE_DIR="$HOME/cursor-template"

# 5. Check if it already exists
if [ -d "$TARGET_DIR" ]; then
    echo "❌ Error: $TARGET_DIR already exists!"
    exit 1
fi

# 6. Create the directory
echo "📂 Creating $TARGET_DIR..."
sudo mkdir -p "$TARGET_DIR"

# 7. Copy .cursorignore
sudo cp "$TEMPLATE_DIR/.cursorignore" "$TARGET_DIR/.cursorignore"

# 8. Create .vscode folder
sudo mkdir -p "$TARGET_DIR/.vscode"

# 9. Dynamically generate tasks.json
sudo tee "$TARGET_DIR/.vscode/tasks.json" > /dev/null <<EOF
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

# 10. Set ownership to current user
echo "🔑 Setting permissions..."
sudo chown -R $USER:$USER "$TARGET_DIR"

echo ""
echo "✅ Done! Your project is ready at $TARGET_DIR"
echo "👉 Dev folder:  /opt/$PROJECT_NAME"
echo "👉 Prod folder: /opt/$PROD_FOLDER on $PROD_USER@$PROD_IP:$PROD_PORT"
echo "👉 Next: Open Cursor, SSH to dev-server, and open: $TARGET_DIR"

#!/bin/bash

# 1. Ask for the project name
echo "🚀 Starting new Cursor project setup..."
read -p "Enter the new project folder name (e.g. my-app): " PROJECT_NAME

TARGET_DIR="/opt/$PROJECT_NAME"
TEMPLATE_DIR="$HOME/cursor-template"

# 2. Check if it already exists
if [ -d "$TARGET_DIR" ]; then
    echo "❌ Error: $TARGET_DIR already exists!"
    exit 1
fi

# 3. Create the directory and copy files
echo "📂 Creating $TARGET_DIR..."
sudo mkdir -p "$TARGET_DIR"
sudo cp -r "$TEMPLATE_DIR/." "$TARGET_DIR/"

# 4. Set ownership to the current user (so you can edit files)
echo "🔑 Setting permissions..."
sudo chown -R $USER:$USER "$TARGET_DIR"

# 5. Clean up the script itself from the target project
rm "$TARGET_DIR/setup.sh"

echo "✅ Done! Your project is ready at $TARGET_DIR"
echo "👉 Next step: Open Cursor, SSH to dev-server, and open the folder: $TARGET_DIR"

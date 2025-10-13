#!/bin/bash
# Initialize the Ghost on Render repository

# Check if git is installed
if ! command -v git &> /dev/null; then
    echo "Git is not installed. Please install git first."
    exit 1
fi

# Initialize Git repository if not already done
if [ ! -d .git ]; then
    echo "Initializing Git repository..."
    git init
    git add .
    git commit -m "Initial commit: Ghost on Render setup"
    echo "Git repository initialized successfully!"
else
    echo "Git repository already exists."
fi

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Docker is not installed. You'll need Docker to run Ghost locally."
    echo "Please install Docker from https://docs.docker.com/get-docker/"
else
    echo "Docker is installed. You can run 'docker-compose up' to start Ghost locally."
fi

echo ""
echo "Setup complete! Next steps:"
echo "1. Update the 'url' in config.production.json with your Render URL"
echo "2. Connect this repository to Render using the Blueprint option"
echo "3. Configure the necessary environment variables in Render"
echo ""
echo "For more information, see the README.md file."

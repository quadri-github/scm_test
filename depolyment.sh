#!/bin/bash

# Set script to exit on error
set -e

# Define environment variables
APP_NAME="my_app"
DEPLOY_DIR="/var/www/$APP_NAME"
GIT_REPO="git@github.com:username/my_app.git"
BRANCH="main"

# Functions
log() {
  echo "$(date +"%Y-%m-%d %H:%M:%S") - $1"
}

check_prerequisites() {
  log "Checking prerequisites..."
  command -v git >/dev/null 2>&1 || { echo "Git is not installed. Aborting."; exit 1; }
  command -v npm >/dev/null 2>&1 || { echo "NPM is not installed. Aborting."; exit 1; }
}

clone_repository() {
  log "Cloning repository..."
  if [ ! -d "$DEPLOY_DIR" ]; then
    git clone -b $BRANCH $GIT_REPO $DEPLOY_DIR
  else
    log "Repository already exists. Pulling latest changes..."
    cd $DEPLOY_DIR && git pull origin $BRANCH
  fi
}

install_dependencies() {
  log "Installing dependencies..."
  cd $DEPLOY_DIR
  npm install
}

build_application() {
  log "Building the application..."
  npm run build
}

deploy_application() {
  log "Deploying application..."
  # Example: Copy build files to the server's public directory
  cp -R $DEPLOY_DIR/build /var/www/html/
}

post_deploy_checks() {
  log "Running post-deployment checks..."
  # Example: Check if the service is running
  curl -I http://localhost | grep "200 OK" >/dev/null && log "Deployment successful!" || { echo "Deployment failed."; exit 1; }
}

# Main Execution Flow
log "Starting deployment process..."

check_prerequisites
clone_repository
install_dependencies
build_application
deploy_application
post_deploy_checks

log "Deployment completed successfully!"

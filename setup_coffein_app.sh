#!/usr/bin/env bash

# Step 1: Update the system environment
sudo apt update -y && sudo apt upgrade -y

# Step 2: Install Python venv package
sudo apt install -y python3.12-venv

# Step 3: Create the coffein_app/ directory
APP_DIR="/home/ubuntu/coffein_app" # Change path for not certain user !!!
if [ ! -d "$APP_DIR" ]; then
  mkdir -p "$APP_DIR"
  echo "Directory $APP_DIR created."
else
  echo "Directory $APP_DIR already exists."
fi

# Step 4: Clone the project repository with access token
USERNAME="anyusername"
ACCESS_TOKEN="RfeeVdRFKnMHvkzTRQZB"
REPO_URL="https://$USERNAME:$ACCESS_TOKEN@git.epam.com/vladislav_dorofeev/test_course"
if git clone "$REPO_URL" "$APP_DIR"; then
  echo "Project successfully cloned into $APP_DIR."
else
  echo "Error cloning the project." >&2
  exit 1
fi

# Step 5: Set up and activate the virtual environment
cd "$APP_DIR" || exit
python3 -m venv .venv
source .venv/bin/activate

# Step 6: Upgrade pip
python3 -m pip install --upgrade pip

# Step 7: Install dependencies from requirements.txt
if [ -f "requirements.txt" ]; then
  pip install -r requirements.txt
  echo "Dependencies from requirements.txt successfully installed."
else
  echo "File requirements.txt not found." >&2
fi

# Step 8: Create the FastAPI service file
SERVICE_FILE="/etc/systemd/system/fastapi.service"
echo "[Unit]
Description=FastAPI Application
After=network.target

[Service]
User=ubuntu
Group=ubuntu
WorkingDirectory=/home/ubuntu/coffein_app
ExecStart=/home/ubuntu/coffein_app/.venv/bin/uvicorn main:app --host 0.0.0.0 --port 8000
Restart=always

[Install]
WantedBy=multi-user.target" | sudo tee "$SERVICE_FILE" > /dev/null

# Step 9: Reload systemd, enable, and start the FastAPI service
sudo systemctl daemon-reload
sudo systemctl enable fastapi.service
sudo systemctl start fastapi.service

# Final message
echo "All steps completed. Virtual environment is active, and FastAPI service is running."

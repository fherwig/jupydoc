#!/opt/homebrew/bin/bash
# using homebrew bash instead of the default one
# to get the associative array feature
echo "Starting Jupyter Lab in Docker..."

# Define the name based on the current directory
cwdir=${PWD##*/}
name="jd_${cwdir}"

# Check Bash version
min_version=4
if [ ${BASH_VERSINFO[0]} -lt $min_version ]; then
  echo "This script requires Bash version >= $min_version."
  exit 1
fi

# Function to start a new container
# Function to start a new container
start_new_container() {
  local cwdir=${PWD##*/}
  local name="jd_${cwdir}"
  
  # Find an unused port starting from 8888
  local port=8888
  while lsof -Pi :$port -sTCP:LISTEN -t >/dev/null ; do
    port=$((port + 1))
  done
  
  local container_id=$(docker run --hostname $name -d -p $port:8888 -v "$(pwd)":/home/fherwig/work -v "$HOME":/home/fherwig/home -w /home/fherwig/work --name $name jupydoc:latest)
  echo Waiting 5s for Jupyter Lab to initialize...
  sleep 5
  local token=$(docker logs $container_id 2>&1 | awk -F= '/token/ {print $2; exit}')
  
  open -a "Google Chrome"  "http://localhost:$port/?token=${token}"
}


# Check if any containers match the "jd_" pattern
existing_containers=$(docker ps -a --format '{{.Names}}' | grep '^jd_')

if [ -z "$existing_containers" ]; then
    # If no existing containers, create and run one
    start_new_container
else
  echo "Existing containers:"
  
  # List existing containers and give each a unique identifier
  i=0
  declare -A container_map
  while IFS= read -r line; do
    port=$(docker port $line 8888 | awk -F: '{print $2}')
    echo "$i: Log in ($i) | Open in Chrome ($i$i) | Remove ($i$i$i) - $line (Port: $port)"
    container_map[$i]="$line:$port"
    i=$((i + 1))
  done <<< "$existing_containers"
  
  # Prompt user for action
  read -p "Choose an action, 'new' to start a new container, or 'killall' to remove all [new]: " choice
  choice=${choice:-new}
  if [ "$choice" = "new" ]; then
    start_new_container
  elif [ "$choice" = "killall" ]; then
    docker rm -f $(docker ps -a -q -f name='^jd_')
  elif [[ "$choice" =~ ^[0-9]$ ]]; then
    container_info=${container_map[${choice:0:1}]}
    docker exec -it -u fherwig "${container_info%%:*}" /bin/bash
  elif [[ "$choice" =~ ^[0-9]{2}$ ]]; then
    container_info=${container_map[${choice:0:1}]}
    port=${container_info##*:}
    open -a "Google Chrome" "http://localhost:$port"
  elif [[ "$choice" =~ ^[0-9]{3}$ ]]; then
    container_info=${container_map[${choice:0:1}]}
    docker rm -f "${container_info%%:*}"
  else
    echo "Invalid choice. Exiting."
  fi

fi
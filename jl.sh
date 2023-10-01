#!/opt/homebrew/bin/bash
# using homebrew bash instead of the default one
# to get the associative array feature

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
  
  local container_id=$(docker run --hostname $name -d -p $port:8888 -v "$(pwd)":/home/fherwig/work -w /home/fherwig/work --name $name jupydoc:latest)
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
    echo "$i: $line (Port: $port)"
    container_map[$i]="$line:$port"
    i=$((i + 1))
  done <<< "$existing_containers"
  
  # Prompt user for action
  read -p "Choose a container to log into [0-$((i-1))], 'new' to start a new container, or 'open' to open in browser [new]: " choice
  choice=${choice:-new}

  if [ "$choice" = "new" ]; then
    start_new_container
  elif [ "$choice" = "open" ]; then
    read -p "Choose a container to open in browser [0-$((i-1))]: " open_choice
    container_info=${container_map[$open_choice]}
    port=${container_info##*:}
    open -a "Google Chrome" "http://localhost:$port"
  elif [[ "$choice" =~ ^[0-9]+$ ]] && [ -n "${container_map[$choice]}" ]; then
    container_info=${container_map[$choice]}
    container_name=${container_info%%:*}
    docker exec -it -u fherwig "$container_name" /bin/bash
  else
    echo "Invalid choice. Exiting."
  fi
fi
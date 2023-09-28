#!/bin/bash

# Switch to the fherwig user and start Jupyter Lab
su - fherwig -c "jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root"

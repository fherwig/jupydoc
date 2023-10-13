# Jupydoc

## What it is for
Jupydoc is a basic collection of tools to build a minimal Jupyter server meant to run on your local laptop. Along with it comes a script `jl.sh` which manages the starting and administration of akctive kernels. `jl.sh` would be started from the command line in a given directory and the current directory as well as a link to the `$HOME` directory will appear in the jupyter server. The script also allows command line login to the server machine. 

## HowTo
1. It is assumed that you have a working Docker installation on your computer. Check with the usual `docker run hello-world` command.
2. Make the Docker image `jupydoc:latest` with the `make` command.
3. Ideally place the `jl.sh` script in your `~/bin` directory, or wherever you keep you command line executable, so that it can be executed from every directory. `~/bin` or equivalent is the directory that you would have added to your `$PATH` variable in your `.bashrc` or equivalent (`.zshrc` or `~/.alias`)
4. Whenever you want to launch the JupyterLab server in a directory just launch the `jl.sh` script.

If you already have a couple Docker containers going you would see something like this:
```
Starting Jupyter Lab in Docker...
Existing containers:
0: Log in (0) | Open in Chrome (00) | Remove (000) - jd_p561 (Port: 8889)
1: Log in (1) | Open in Chrome (11) | Remove (111) - jd_tmp (Port: 8888)
Choose an action, 'new' to start a new container, or 'killall' to remove all [new]: 
```
Where `jd_xxx` are the names of the running Docker containers. 
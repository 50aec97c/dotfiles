mkdir -p /tmp/.cache-$USER
mkdir -p /tmp/.download-$USER

PATH="$HOME/bin:$PATH"
LESS="$LESS -r"
LESSHISTFILE="-"

export PATH LESS LESSHISTFILE

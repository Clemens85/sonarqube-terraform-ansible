#!/bin/sh

# symlink all files from the host's ~/.ssh directory
for FILE in /home/provisioning/.ssh-host/*
do
  cp "$FILE" /home/provisioning/.ssh
  chmod 600 /home/provisioning/.ssh/"$(basename "$FILE")"
done

/bin/bash
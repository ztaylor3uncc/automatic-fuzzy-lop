#!/bin/bash

cp backup.bak.bak backup.bak

sudo rm -rf /usr/share/focs/*
sudo cp -r afl /usr/share/focs/

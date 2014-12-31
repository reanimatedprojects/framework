#!/bin/bash

# By default, we're running on port 8003 and
# in debug mode which means in the foreground

# plackup is installed as part of the Plack module

plackup -p 8003 bin/app.pl


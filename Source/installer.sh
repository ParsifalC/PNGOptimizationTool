#!/bin/bash

#install crunch
git clone https://github.com/chrissimpkins/Crunch.git
make build-dependencies
make install-executable
chmod +x ./PNGOptimizer.sh
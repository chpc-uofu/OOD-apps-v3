#!/bin/bash

/uufs/chpc.utah.edu/sys/bin/myallocation -t | awk '{print $2}'

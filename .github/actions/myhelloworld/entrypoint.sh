#!/bin/sh -l

date > /github/workspace/output.txt
echo "Hello $1" >> /github/workspace/output.txt

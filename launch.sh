#!/bin/bash
# Referenced to https://www.youtube.com/watch?v=hZNGST2vIds&feature=youtu.be

if [ "$#" -ne 1 ]; then
	echo "script takes json file as an argument"
	exit 1;
fi
curl -X POST -H "Content-Type: application/json" $marathon_node_ip:8080/v2/apps -d@"$@"

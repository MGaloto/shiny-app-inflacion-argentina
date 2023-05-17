#!/bin/bash

LRED=$(printf '\033[1;31m')
LGREEN=$(printf '\033[1;32m')

echo "${LGREEN}Build the docker${LGREEN}"

docker build . --progress=plain \
               -t mgaloto/bs4dashiny:01

if [[ $? = 0 ]] ; then
echo "${LGREEN}Pushing docker...${LGREEN}"
docker push mgaloto/bs4dashiny:01
else
echo "${LRED}Docker build failed${LRED}"
fi
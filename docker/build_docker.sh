#!/bin/bash

LRED=$(printf '\033[1;31m')
LGREEN=$(printf '\033[1;32m')

echo "${LGREEN}Build the docker${LGREEN}"

docker build . --progress=plain \
               -t mgaloto/flexdashiny_02

if [[ $? = 0 ]] ; then
echo "${LGREEN}Pushing docker...${LGREEN}"
docker push mgaloto/flexdashiny_01
else
echo "${LRED}Docker build failed${LRED}"
fi
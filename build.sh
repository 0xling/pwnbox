#!/bin/bash

docker-compose build --build-arg http\_proxy=http://172.17.0.1:7777 --build-arg https\_proxy=http://172.17.0.1:7777

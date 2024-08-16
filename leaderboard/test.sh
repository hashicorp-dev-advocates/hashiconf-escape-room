#!/bin/bash

curl -XPOST -d '{"name":"team 1","time":10.0, "activation":"robots"}' localhost:9090/teams
curl -XPOST -d '{"name":"team 2","time":5.7, "activation":"slm"}' localhost:9090/teams
curl -XPOST -d '{"name":"team 3","time":50.234, "activation":"ilm"}' localhost:9090/teams

curl -XPOST -d '{"name":"team 4","time":89.99, "activation":"robots"}' localhost:9090/teams
curl -XPOST -d '{"name":"team 5","time":1.2, "activation":"slm"}' localhost:9090/teams
curl -XPOST -d '{"name":"team 6","time":1.2, "activation":"ilm"}' localhost:9090/teams
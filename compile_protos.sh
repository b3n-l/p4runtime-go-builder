#!/bin/bash
set -x
set -e
for PROTO in $PROTOS
do 
    echo "protoc $PROTO $PROTOFLAGS"
    protoc --go_out=plugins=grpc:/p4/go_out $PROTO $PROTOFLAGS
done

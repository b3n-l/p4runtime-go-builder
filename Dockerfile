FROM ubuntu:16.04

RUN apt-get update && apt-get -y install --no-install-recommends \
    autoconf automake ca-certificates libtool curl make git g++ unzip pkg-config sudo wget \
    && rm -rf /var/lib/apt/lists/*
#ENV GOLANG_VERSUON 1.12.7
RUN wget -O go.tgz https://dl.google.com/go/go1.12.7.linux-amd64.tar.gz
RUN tar -C /usr/local -xzf go.tgz
RUN rm -rf go.tgz
ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH

RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"

ENV JOBS 8
RUN mkdir /p4
WORKDIR /p4

RUN git clone https://github.com/google/protobuf
WORKDIR /p4/protobuf
RUN git checkout v3.2.0 && ./autogen.sh && ./configure && \
    make -j$JOBS && make install && ldconfig && make clean

WORKDIR /p4
RUN git clone https://github.com/google/grpc.git
WORKDIR /p4/grpc
RUN git checkout tags/v1.3.2 && git submodule update --init --recursive && \
    make -j$JOBS && sudo make install && sudo ldconfig && make clean

WORKDIR /p4
RUN go get -u github.com/golang/protobuf/protoc-gen-go

RUN git clone https://github.com/googleapis/googleapis

ENV PROTO_DIR /p4/p4runtime/proto
ENV GOOGLE_PROTO_DIR /p4/googleapis

ENV PROTOS="\
p4/v1/p4data.proto \
p4/v1/p4runtime.proto \
p4/config/v1/p4info.proto \
p4/config/v1/p4types.proto \
google/rpc/status.proto \
google/rpc/code.proto"

ENV PROTOFLAGS="-I. -I/p4/googleapis"

RUN mkdir /p4/go_out
COPY compile_protos.sh /p4/compile_protos.sh
ENV BRANCH master
ADD https://api.github.com/repos/p4lang/p4runtime/git/refs/heads/$BRANCH version.json
RUN git clone https://github.com/p4lang/p4runtime
WORKDIR /p4/p4runtime
RUN git checkout $BRANCH
WORKDIR /p4/p4runtime/proto
RUN cp -r /p4/googleapis/google /p4/p4runtime/proto
RUN chmod +x /p4/compile_protos.sh && /p4/compile_protos.sh && ls /p4/go_out





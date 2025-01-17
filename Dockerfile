FROM golang:1.19 AS build

# Build
# Copy the Go Modules manifests
COPY go.mod go.sum ./
RUN go mod download
RUN CGO_ENABLED=0 GOOS=linux GOARCH=arm64 go build -a -o proxy proxy.go

FROM arm64v8/alpine:latest

RUN apk add --no-cache --update curl ca-certificates openssl git tar bash sqlite fontconfig \
    && adduser --disabled-password --home /home/container container

USER container
ENV USER=container HOME=/home/container
WORKDIR /home/container

# Copy the go source
COPY command ./command
COPY game ./game
COPY nbs ./nbs
COPY redisdb ./redisdb
COPY proxy.go ./
COPY --from=build proxy .

COPY ./entrypoint.sh /entrypoint.sh
CMD [ "/bin/bash", "/entrypoint.sh" ]
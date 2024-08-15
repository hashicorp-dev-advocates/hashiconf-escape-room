FROM golang:1.21-alpine

WORKDIR /app

COPY go.mod ./
COPY go.sum ./
RUN go mod download

COPY *.go ./
COPY data/*.go ./data/
COPY handlers/*.go ./handlers/

RUN go build -o /leaderboard-api

EXPOSE 9090

CMD [ "/leaderboard-api" ]
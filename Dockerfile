FROM golang:alpine as builder
WORKDIR /app
COPY main.go .
RUN cd /app; go build -o webapp

FROM alpine:latest
RUN apk --no-cache add ca-certificates
RUN mkdir /app/
WORKDIR /app/
COPY --from=builder /app/webapp .
ENTRYPOINT ["./webapp"]

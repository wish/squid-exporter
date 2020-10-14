FROM --platform=$BUILDPLATFORM golang:alpine as builder

ARG BUILDPLATFORM
ARG TARGETARCH
ARG TARGETOS
WORKDIR /go/src/github.com/boynux/squid-exporter
COPY . .

# Compile the binary statically, so it can be run without libraries.
RUN CGO_ENABLED=0 GOARCH=${TARGETARCH} GOOS=${TARGETOS} go build -a -ldflags '-extldflags "-s -w -static"' .

FROM scratch
COPY --from=builder /go/src/github.com/boynux/squid-exporter/squid-exporter /usr/local/bin/squid-exporter

# Allow /etc/hosts to be used for DNS
COPY --from=builder /etc/nsswitch.conf /etc/nsswitch.conf

EXPOSE 9301

ENTRYPOINT ["/usr/local/bin/squid-exporter"]

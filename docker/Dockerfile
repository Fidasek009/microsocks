FROM alpine:3.21 AS builder

RUN apk add --no-cache build-base

WORKDIR /usr/src/microsocks

COPY . .

# Compile statically
# We override CFLAGS to optimize for size (-Os) and include necessary flags
# We use LDFLAGS to link statically and strip symbols (-s)
RUN make CFLAGS="-Os -Wall -std=c99" LDFLAGS="-static -s"

# Create a non-root user for the runtime stage
RUN adduser -D -u 1000 -H -h / -s /sbin/nologin microsocks

FROM scratch

COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /etc/group /etc/group
COPY --from=builder /usr/src/microsocks/microsocks /microsocks

USER microsocks

EXPOSE 1080

ENTRYPOINT ["/microsocks"]
CMD []

LABEL org.opencontainers.image.source=https://github.com/fidasek009/microsocks

FROM rust:1.81.0-slim-bookworm@sha256:f9fb6bdb0483de4ade93b262a3f6cf8c2985fca1d34784914bbcabd5a34d3197 AS builder

RUN apt-get update && \
    apt-get install -y build-essential

COPY . /app
WORKDIR /app
RUN cargo build --release

FROM debian:bookworm-slim@sha256:d5d3f9c23164ea16f31852f95bd5959aad1c5e854332fe00f7b3a20fcc9f635c
RUN apt-get update && apt-get install  -o Dpkg::Options::=--force-confdef -yq --no-install-recommends \
    postgresql-client \
    # Clean up layer
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && truncate -s 0 /var/log/*log
COPY --from=builder /app/target/release/pgcat /usr/bin/pgcat
COPY --from=builder /app/pgcat.toml /etc/pgcat/pgcat.toml
WORKDIR /etc/pgcat
ENV RUST_LOG=info
CMD ["pgcat"]
STOPSIGNAL SIGINT

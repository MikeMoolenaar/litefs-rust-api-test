FROM clux/muslrust:stable AS chef
USER root
RUN cargo install cargo-chef
WORKDIR /app

FROM chef AS planner
COPY . .
RUN cargo chef prepare --recipe-path recipe.json

FROM chef AS builder
COPY --from=planner /app/recipe.json recipe.json

# Build dependencies - this is the caching Docker layer!
RUN cargo chef cook --release --target x86_64-unknown-linux-musl --recipe-path recipe.json
RUN cargo install sqlx-cli

# Build application
COPY . .
RUN cargo sqlx database setup # Just for sqlx
RUN cargo build --release --target x86_64-unknown-linux-musl

FROM alpine:3.19 AS runtime

# Add sqlite dependencies
RUN apk add ca-certificates fuse3 sqlite 
COPY --from=flyio/litefs:0.5 /usr/local/bin/litefs /usr/local/bin/litefs

# Add sqlx-cli, unfortunately rust makes the docker image 600mb+ bigger :(
RUN apk add pkgconfig cargo openssl-dev
RUN cargo install sqlx-cli --no-default-features --features native-tls,sqlite
WORKDIR /app

# Setup database
ENV DATABASE_URL="sqlite:///litefs/db"

COPY --from=builder /app/target/x86_64-unknown-linux-musl/release/litefs-rust-api-test /usr/local/bin/litefs-rust-api-test
COPY --from=builder /app/templates /app/templates
COPY --from=builder /app/migrations /app/migrations
COPY --from=builder /app/litefs.yml /app/litefs.yml

ENTRYPOINT litefs mount

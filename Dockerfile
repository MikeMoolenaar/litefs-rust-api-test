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
RUN cargo sqlx database setup
RUN cargo build --release --target x86_64-unknown-linux-musl

FROM alpine:3.19 AS runtime

RUN apk add ca-certificates fuse3 sqlite
COPY --from=flyio/litefs:0.5 /usr/local/bin/litefs /usr/local/bin/litefs

# RUN addgroup -S myuser && adduser -S myuser -G myuser
WORKDIR /app
ENV DATABASE_URL="sqlite://db"

COPY --from=builder /app/target/x86_64-unknown-linux-musl/release/litefs-rust-api-test /usr/local/bin/litefs-rust-api-test
COPY --from=builder /app/sqlite.db /app/sqlite.db
COPY --from=builder /app/templates /app/templates
COPY --from=builder /app/litefs.yml /app/litefs.yml
# RUN chown -R myuser:myuser /app

# USER myuser
EXPOSE 8080
ENTRYPOINT litefs mount

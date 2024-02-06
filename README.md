# litefs-rust-api-test 
Testing out [LiteFS on fly.io](https://fly.io/docs/litefs/).

## Setup
Based on [litefs setup guide](https://fly.io/docs/litefs/getting-started-fly/)
```sh
sudo fly launch --local-only --build-only
fly volumes create litefs --size 1
fly consul attach
sudo fly deploy --local-only
```

Accessing the db:
```sh
fly ssh console
sqlite3 /litefs/db
```

## TODO
- Figure out how to run `sqlx database setup` outside of the build container. Currently, the rust compiler makes the docker package huge (total size is now 1.1GB)

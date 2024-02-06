# litefs-rust-api-test 
Testing out [LiteFS on fly.io](https://fly.io/docs/litefs/).

## Setup
Based on [litefs setup guide](https://fly.io/docs/litefs/getting-started-fly/)
```sh
sudo fly launch --local-only --build-only
fly volumes create litefs --size 1
fly consul attach
sudo fly deploy --local-only

# Just for fun :)
fly m clone --select --region syd
# Now we can serve users from The Netherlands and Australia with great response times :D
```

Accessing the db:
```sh
fly ssh console
sqlite3 /litefs/db
```


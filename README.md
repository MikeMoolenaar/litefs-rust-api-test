# litefs-rust-api-test (WIP)
Doesn't work yet lol 


## Setup
```sh
based on [litefs setup guide](https://fly.io/docs/litefs/getting-started-fly/)
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

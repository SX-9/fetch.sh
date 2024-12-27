# fetch.sh
a simple fetch utility
writen in `/bin/sh` made to be as simple as possible

![image](https://github.com/user-attachments/assets/a75eb3ca-715c-4ecb-a6b0-c9e907b4fc39)

```sh
curl -fsSL https://raw.githubusercontent.com/SX-9/fetch.sh/refs/heads/master/fetch.sh | sh -s -- color
```

## Usage
Just put the script somewhere in your `PATH` and run `fetch.sh`, to display with colors run `fetch.sh color`.
If you want to customize it, edit the environment variables and `printf` lines in `fetch.sh`'s `main` function.

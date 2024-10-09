# fetch.sh
a simple fetch utility
writen in `/bin/sh` made to be as simple as possible

![image](https://github.com/user-attachments/assets/7a68d0ed-328e-4887-a471-4b7146898f66)

```sh
curl -sSL https://raw.githubusercontent.com/SX-9/fetch.sh/refs/heads/master/fetch.sh | sh -s -- color
```

## Usage
Just put the script somewhere in your `PATH` and run `fetch.sh`, to display with colors run `fetch.sh color`.
If you want to customize it, edit the environment variables and `printf` lines in `fetch.sh`'s `main` function.

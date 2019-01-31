## Run the container
```bash
docker build -t jswny/devbox . && docker run -it -h devbox --name devbox jswny/devbox
```

## Stop and remove the container, and remove the associated image
```bash
docker stop devbox && docker rm devbox && docker rmi jswny/devbox
```

## Change `$TERM`
Add the following to your `docker run` command:
```
-e "TERM=xterm-256color"
```
# Description
This Docker image runs Ubuntu 18.04 and includes
1. Xilinx Vivado 2020.2
2. Xilinx Vitis HLS y2k22 patch
3. Xilinx petalinux 2020.2

# Required Files
The following files must be downloaded and placed in this folder before building the docker image
1. [Xilinx_Unified_2020.2_1118_1232.tar.gz](https://www.xilinx.com/member/forms/download/xef.html?filename=Xilinx_Unified_2020.2_1118_1232.tar.gz)
2. [y2k22_patch-1.2.zip](https://support.xilinx.com/s/article/76960?language=en_US)
3. [petalinux-v2020.2-final-installer.run](https://www.xilinx.com/member/forms/download/xef.html?filename=petalinux-v2020.2-final-installer.run)

# Build the Docker Image
```console
docker build -t xilinx:2022.1 .
```

Building the image creates a runt image (an image with no REPOSITORY name). Delete it manually after building the docker image. The following is an example from a recent build (note that the IMAGE ID will vary):
```console
$ docker image ls
REPOSITORY   TAG       IMAGE ID       CREATED          SIZE
xilinx       2022.1    d08b116aa0e8   14 minutes ago   131GB
<none>       <none>    dd3702eb7c24   43 minutes ago   213GB
xilinx       2020.2    736aa596b630   2 weeks ago      89.9GB
ubuntu       18.04     c6ad7e71ba7d   3 months ago     63.2MB
$ docker image rm dd3702eb7c24

```
# Run the Docker Image
```console
docker run -ti -e "TERM=xterm-256color" --network=host -e DISPLAY=$DISPLAY -v $HOME/dev/:/home/xilinx/dev/ -v $HOME/.Xilinx:/home/xilinx/.Xilinx -e XILINXD_LICENSE_FILE=$XILINXD_LICENSE_FILE -v $HOME/.ssh:/home/xilinx/.ssh:ro --name xilinx2022.1 xilinx:2022.1
```

# Connect to an existing Docker Image
```console
docker exec -e "TERM=xterm-256color" -ti xilinx /bin/bash
```

# Export (save) Docker Image to file
```console
docker save xilinx:2022.1 | gzip > xilinx_2022.1.tar.gz
```

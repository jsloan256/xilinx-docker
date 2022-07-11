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
```
docker build -t xilinx:2020.2 .
```

# Run the Docker Image
```
docker run -ti -e "TERM=xterm-256color" --network=host -e DISPLAY=$DISPLAY -v $HOME/dev/:/home/xilinx/dev/ -v $XAUTH:/root/.Xauthority --name xilinx2020.2 xilinx:2020.2
```

# Connect to an existing Docker Image
```
docker exec -e "TERM=xterm-256color" -ti xilinx /bin/bash
```

# Export (save) Docker Image to file
```
docker save xilinx:2020.2 | gzip > xilinx_2020.2.tar.gz
```

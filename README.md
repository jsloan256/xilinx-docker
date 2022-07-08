# Description
This Docker image runs Ubuntu 20.04 and includes
1. Xilinx Vivado 2022.1
2. Xilinx petalinux 2022.1

# Required Files
The following files must be downloaded and placed in this folder before building the docker image
1. [Xilinx_Unified_2022.1_0420_0327.tar.gz](https://www.xilinx.com/member/forms/download/xef.html?filename=Xilinx_Unified_2022.1_0420_0327.tar.gz)
2. [petalinux-v2022.1-04191534-installer.run](https://www.xilinx.com/member/forms/download/xef.html?filename=petalinux-v2022.1-04191534-installer.run)

# Build the Docker Image
```
docker build -t xilinx:2022.1 .
```

# Run the Docker Image
```
docker run -ti -e "TERM=xterm-256color" --network=host -e DISPLAY=$DISPLAY -v /home/john_sloan/dev/:/home/xilinx/dev/ -v $XAUTH:/root/.Xauthority --name xilinx2022.1 xilinx:2022.1
```

# Connect to an existing Docker Image
```
docker exec -e "TERM=xterm-256color" -ti xilinx /bin/bash
```

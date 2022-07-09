ARG UBUNTU_VERSION=18.04
FROM ubuntu:${UBUNTU_VERSION}

ARG VIVADO_FILE="Xilinx_Unified_2022.1_0420_0327.tar.gz"
ARG PETALINUX_FILE="petalinux-v2022.1-04191534-installer.run"
ARG TEMP_PATH=/temp_files/

COPY install_config.txt ${TEMP_PATH}
COPY ${VIVADO_FILE} ${TEMP_PATH}
COPY ${PETALINUX_FILE} ${TEMP_PATH}
COPY install_config.txt ${TEMP_PATH}
COPY accept-eula.sh ${TEMP_PATH} 

RUN apt-get update &&  DEBIAN_FRONTEND=noninteractive apt-get install -y -q sudo x11-apps \
    libgtk2.0-0 dpkg-dev python3-pip libxtst6 default-jre xorg libxrender-dev libxtst-dev \
    twm wget pv vim language-pack-en-base git tig gcc-multilib gzip unzip expect gawk \
    xterm autoconf libtool texinfo libncurses5-dev iproute2 net-tools libssl-dev flex bison \
    libselinux1 screen pax python3-pexpect python3-git python3-jinja2 zlib1g-dev rsync libswt-gtk-4-jni

RUN dpkg --add-architecture i386 &&  apt-get update &&  \
      DEBIAN_FRONTEND=noninteractive apt-get install -y -q \
      zlib1g:i386

RUN adduser --disabled-password --gecos '' xilinx && \
  usermod -aG sudo xilinx && \
  echo "xilinx ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

RUN locale-gen en_US.UTF-8 && update-locale

RUN echo "dash dash/sh boolean false" | debconf-set-selections

# Install Vivado
RUN cat ${TEMP_PATH}${VIVADO_FILE} | tar zx --strip-components=1 -C ${TEMP_PATH} \
    && ${TEMP_PATH}xsetup --agree XilinxEULA,3rdPartyEULA \
       --batch Install --config ${TEMP_PATH}install_config.txt

USER xilinx
ENV HOME /home/xilinx
ENV LANG en_US.UTF-8
WORKDIR /home/xilinx

# Run the petalinux install
RUN sudo chmod a+rx ${TEMP_PATH}${PETALINUX_FILE} \
    && sudo chmod a+rx ${TEMP_PATH}accept-eula.sh \
    && sudo mkdir -p /opt/xilinx \
    && sudo chown xilinx.xilinx /opt/xilinx \
    && sudo chown xilinx.xilinx -R ${TEMP_PATH} \
    && cd ${TEMP_PATH} \
    && sudo -u xilinx -i ${TEMP_PATH}accept-eula.sh ${TEMP_PATH}${PETALINUX_FILE} /opt/xilinx/petalinux \
    && rm -f /home/xilinx/petalinux_installation_log

# Delete temp files
RUN sudo rm -rf ${TEMP_PATH}

# Set console to bash
Run sudo ln -sf /bin/bash /bin/sh

# Add Vivado and Petalinux tools to the path
RUN echo "" >> /home/xilinx/.bashrc \
    && echo "source /opt/Xilinx/Vivado/2022.1/settings64.sh" >> /home/xilinx/.bashrc \
    && echo "source /opt/xilinx/petalinux/settings.sh" >> /home/xilinx/.bashrc \
    && echo "VITIS_SKIP_PRELAUNCH_CHECK=true"

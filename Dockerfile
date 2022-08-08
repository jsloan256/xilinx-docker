ARG UBUNTU_VERSION=18.04
FROM ubuntu:${UBUNTU_VERSION} AS needs-squashing

ARG VIVADO_FILE="Xilinx_Unified_2022.1_0420_0327.tar.gz"
ARG PETALINUX_FILE="petalinux-v2022.1-04191534-installer.run"
ARG TEMP_PATH=/temp_files/

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y -q sudo \
       libgtk2.0-0 dpkg-dev python3-pip libxtst6 default-jre libxrender-dev libxtst-dev \
       twm wget pv vim language-pack-en-base git tig gcc-multilib gzip unzip expect gawk \
       xterm autoconf libtool texinfo libncurses5-dev iproute2 net-tools libssl-dev flex bison \
       libselinux1 screen pax python3-pexpect python3-git python3-jinja2 zlib1g-dev rsync libswt-gtk-4-jni \
       curl gtkterm ocl-icd-libopencl1 opencl-headers g++-multilib zip udev bc\
    && rm -rf /var/lib/apt/lists/*

RUN dpkg --add-architecture i386 &&  apt-get update &&  \
       DEBIAN_FRONTEND=noninteractive apt-get install -y -q \
       zlib1g:i386 \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get autoclean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*

RUN adduser --disabled-password --gecos '' xilinx && \
  usermod -aG sudo xilinx && \
  echo "xilinx ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

RUN locale-gen en_US.UTF-8 && update-locale

RUN echo "dash dash/sh boolean false" | debconf-set-selections

# Install Vivado
WORKDIR /vivado_install_files
COPY install_config.txt ${VIVADO_FILE} ./
RUN cat ${VIVADO_FILE} | tar zx --strip-components=1 \
    && ./xsetup --agree XilinxEULA,3rdPartyEULA --batch Install --config install_config.txt \
    && rm -rf /vivado_install_files

USER xilinx
ENV HOME /home/xilinx
ENV LANG en_US.UTF-8

RUN sudo adduser xilinx dialout
RUN cd /opt/Xilinx/Vivado/2022.1/data/xicom/cable_drivers/lin64/install_script/install_drivers \
    && sudo ./install_drivers

# Install petalinux
WORKDIR /petalinux_install_files
COPY accept-eula.sh ${PETALINUX_FILE} ./
RUN sudo chmod a+rx ./${PETALINUX_FILE} \
    && sudo chmod a+rx ./accept-eula.sh \
    && sudo mkdir -p /opt/xilinx \
    && sudo chown xilinx.xilinx /opt/xilinx \
    && sudo -u xilinx -i /petalinux_install_files/accept-eula.sh /petalinux_install_files/${PETALINUX_FILE} /opt/xilinx/petalinux \
    && rm -f /home/xilinx/petalinux_installation_log \
    && rm -rf /home/petalinux_install_files

# Set console to bash
RUN sudo ln -sf /bin/bash /bin/sh

# Add Vivado and Petalinux tools to the path
RUN echo "" >> /home/xilinx/.bashrc \
    && echo "source /opt/Xilinx/Vivado/2022.1/settings64.sh" >> /home/xilinx/.bashrc \
    && echo "source /opt/xilinx/petalinux/settings.sh" >> /home/xilinx/.bashrc \
    && echo "export VITIS_SKIP_PRELAUNCH_CHECK=true" >> /home/xilinx/.bashrc \
    && echo "cd ~" >> /home/xilinx/.bashrc

FROM scratch
COPY --from=needs-squashing / /
USER xilinx
ENV HOME /home/xilinx
ENV LANG en_US.UTF-8
CMD ["/bin/bash"]

ARG UBUNTU_VERSION=18.04
FROM ubuntu:${UBUNTU_VERSION} AS needs-squashing

ARG VIVADO_FILE="Xilinx_Unified_2020.2_1118_1232.tar.gz"
ARG Y2K22_FILE="y2k22_patch-1.2.zip"
ARG PETALINUX_FILE="petalinux-v2020.2-final-installer.run"

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y -q sudo \
       libgtk2.0-0 dpkg-dev python3-pip libxtst6 default-jre libxrender-dev libxtst-dev \
       twm wget pv vim language-pack-en-base git tig gcc-multilib gzip unzip expect gawk \
       xterm autoconf libtool texinfo libncurses5-dev iproute2 net-tools libssl-dev flex bison \
       libselinux1 screen pax python3-pexpect python3-git python3-jinja2 zlib1g-dev rsync libswt-gtk-4-jni \
       curl gtkterm ocl-icd-libopencl1 opencl-headers libgmp-dev g++-multilib zip \
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
    && ./xsetup --agree 3rdPartyEULA,WebTalkTerms,XilinxEULA --batch Install --config install_config.txt \
    && rm -rf /vivado_install_files

# Install Vitis HLS y2k22 patch
WORKDIR /opt/Xilinx
COPY ${Y2K22_FILE} ./
RUN unzip ./${Y2K22_FILE} \
    && LD_LIBRARY_PATH=/opt/Xilinx/Vivado/2020.2/tps/lnx64/python-3.8.3/lib/ \
       /opt/Xilinx/Vivado/2020.2/tps/lnx64/python-3.8.3/bin/python3 y2k22_patch/patch.py

USER xilinx
ENV HOME /home/xilinx
ENV LANG en_US.UTF-8

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
    && echo "source /opt/Xilinx/Vivado/2020.2/settings64.sh" >> /home/xilinx/.bashrc \
    && echo "source /opt/xilinx/petalinux/settings.sh" >> /home/xilinx/.bashrc \
    && echo "export VITIS_SKIP_PRELAUNCH_CHECK=true" >> /home/xilinx/.bashrc

FROM scratch
COPY --from=needs-squashing / /
USER xilinx
ENV HOME /home/xilinx
ENV LANG en_US.UTF-8
CMD ["/bin/bash"]

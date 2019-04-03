FROM python:2.7.14-jessie

ENV DEBIAN_FRONTEND noninteractive
ENV HASHCAT_VERSION hashcat-5.1.0
ENV HASHCAT_UTILS_VERSION  1.9

# Intall requirements
RUN echo "deb-src http://deb.debian.org/debian jessie main" >> /etc/apt/sources.list
RUN apt-get update && apt-get upgrade -y
RUN apt-get install ca-certificates gcc openssl make kmod nano wget p7zip build-essential libsqlite3-dev libpcap0.8-dev libpcap-dev sqlite3 pkg-config libnl-genl-3-dev libssl-dev net-tools iw ethtool usbutils pciutils wireless-tools git curl wget unzip macchanger pyrit tshark -y
RUN apt-get build-dep aircrack-ng -y
RUN apt-get install hcxdumptool hcxtools -y

# Workdir /
WORKDIR /

#Install Aircrack from Source
RUN apt-get install build-essential autoconf automake libtool pkg-config libnl-3-dev libnl-genl-3-dev libssl-dev ethtool shtool rfkill zlib1g-dev libpcap-dev libsqlite3-dev libpcre3-dev libhwloc-dev libcmocka-dev hostapd wpasupplicant tcpdump screen iw -y
RUN wget https://github.com/aircrack-ng/aircrack-ng/archive/1.5.2.tar.gz aircrack-ng-1.5.2.tar.gz
RUN tar xzvf aircrack-ng-1.5.2.tar.gz
RUN apt-get update && apt-get upgrade -y
WORKDIR /aircrack-ng-1.5.2/
RUN autoreconf -i
RUN ./configure --with-experimental --with-ext-scripts
RUN make
RUN make install
RUN airodump-ng-oui-update

# Workdir /
WORKDIR /

# Install wps-pixie
RUN git clone https://github.com/wiire/pixiewps
WORKDIR /pixiewps/
RUN make
RUN make install

# Workdir /
WORKDIR /

# Install bully
RUN git clone https://github.com/aanarchyy/bully
WORKDIR /bully/src/
RUN make
RUN make install



# Workdir /
WORKDIR /

#Install and configure hashcat
RUN mkdir /hashcat

#Install and configure hashcat: it's either the latest release or in legacy files
RUN cd /hashcat && \
    wget --no-check-certificate https://hashcat.net/files/hashcat-${HASHCAT_VERSION}.7z && \
    7zr x hashcat-${HASHCAT_VERSION}.7z && \
    rm hashcat-${HASHCAT_VERSION}.7z

RUN cd /hashcat && \
    wget https://github.com/hashcat/hashcat-utils/releases/download/v1.9/hashcat-utils-1.9.7z && \
    7zr x hashcat-utils-1.9.7z && \
    rm hashcat-utils-1.9.7z

#Add link for binary
RUN ln -s /hashcat/${HASHCAT_VERSION}/hashcat64.bin /usr/bin/hashcat
RUN ln -s /hashcat/hashcat-utils-${HASHCAT_UTILS_VERSION}/bin/cap2hccapx.bin /usr/bin/cap2hccapx

# Workdir /
WORKDIR /


# Install reaver #Introduced null pin option -p
RUN apt -y install build-essential libpcap-dev aircrack-ng pixiewps
RUN git clone https://github.com/t6x/reaver-wps-fork-t6x.git
WORKDIR reaver-wps-fork-t6x/src/
RUN ./configure
RUN make
RUN make install

# Workdir /
WORKDIR /

# Install cowpatty
RUN git clone https://github.com/roobixx/cowpatty.git
WORKDIR /cowpatty/
RUN make

# Workdir /
WORKDIR /

# Install wifite
RUN git clone https://github.com/nuncan/wifite2mod.git
RUN chmod -R 777 /wifite2mod/
WORKDIR /wifite2mod/
RUN apt-get install rfkill -y
ENTRYPOINT ["/bin/bash"]

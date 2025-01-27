FROM fedora:41

RUN dnf update --refresh -y

RUN dnf install -y  unzip jq git git-lfs make gcc g++ openssl-devel patch m4 bison flex zlib-devel gnat librsvg2-tools qemu-system-x86 vboot-utils

COPY NotoSansThaiUI /usr/local/share/fonts/
RUN dnf install -y google-roboto-fonts google-cousine-fonts google-noto-sans-*-ui-fonts google-noto-sans-cjk-fonts google-noto-sans-hebrew-fonts

COPY cbfstool-0:24.12-1.fc40.x86_64.rpm /tmp/cbfstool-0:24.12-1.fc40.x86_64.rpm
RUN rpm -i /tmp/cbfstool-0:24.12-1.fc40.x86_64.rpm
RUN rm /tmp/cbfstool-0:24.12-1.fc40.x86_64.rpm

RUN useradd -m builder
USER builder
WORKDIR /home/builder

CMD ["/bin/bash"]

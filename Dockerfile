FROM quay.io/ukhomeofficedigital/centos-base:latest
MAINTAINER Mark Olliver <mark@keao.cloud>

ENV ROOT_DIR          '/srv'
ENV TERM              ansi
ENV SYSDIG_REPOSITORY stable
ENV SYSDIG_HOST_ROOT  /host
ENV HOME              /root

LABEL RUN="docker run -i -t -v /var/run/docker.sock:/host/var/run/docker.sock -v /dev:/host/dev -v /proc:/host/proc:ro -v /boot:/host/boot:ro -v /lib/modules:/host/lib/modules:ro -v /usr:/host/usr:ro --privileged --name NAME IMAGE"

RUN rpm --import https://s3.amazonaws.com/download.draios.com/DRAIOS-GPG-KEY.public && \
    curl -s -o /etc/yum.repos.d/draios.repo http://download.draios.com/stable/rpm/draios.repo && \
    yum install -y epel-release && \
    yum install -y \
        curl \
        python-pip \
        syslinux \
        nettools \
        vim \
        tar \
        less \
        tcpdump \
        lsof \
        vmstat \
        iostat \
        sysstat \
        iproute \
        gcc-cpp \
        ngrep \
        httpry \
        pv \
        bash-completion \
        ca-certificates \
        elfutils-libelf \
        elfutils-libelf-devel \
        kernel-devel \
        net-tools \
        jq \
        strace \
        man \
        tree \
        mtr \
        ack \
        wget \
        bind-utils \
        smartmontools \
        htop \
        nmap \
        sysdig && \
    yum clean all

RUN ln -s $SYSDIG_HOST_ROOT/lib/modules /lib/modules

RUN pip install --upgrade \
        pip \
        setuptools \
        yamllint \
        httpie

ENV SYSDIG_MODULE     0.11.0-x86_64-4.5.0-coreos-r1-ecf53d2176b03dc2569dc7548e489f5d
RUN mkdir /root/.sysdig && \
    curl -L# https://s3.amazonaws.com/download.draios.com/stable/sysdig-probe-binaries/sysdig-probe-${SYSDIG_MODULE}.ko -o /root/.sysdig/sysdig-probe-${SYSDIG_MODULE}.ko

COPY ./h.sh /root/h.sh
COPY ./docker-entrypoint.sh /bin/
RUN chmod +x /bin/docker-entrypoint.sh && \
    echo "source /root/h.sh" >> /.bash_profile

ENTRYPOINT ["/bin/docker-entrypoint.sh"]

CMD ["bash"]

FROM quay.io/ukhomeofficedigital/centos-base:latest
MAINTAINER Mark Olliver <mark@keao.cloud>

ENV ROOT_DIR      '/srv'
ENV TERM          ansi
ENV SYSDIG_REPOSITORY stable
ENV SYSDIG_HOST_ROOT /host
ENV HOME /root

LABEL RUN="docker run -i -t -v /var/run/docker.sock:/host/var/run/docker.sock -v /dev:/host/dev -v /proc:/host/proc:ro -v /boot:/host/boot:ro -v /lib/modules:/host/lib/modules:ro -v /usr:/host/usr:ro --name NAME IMAGE"

RUN rpm --import https://s3.amazonaws.com/download.draios.com/DRAIOS-GPG-KEY.public && \
    curl -s -o /etc/yum.repos.d/draios.repo http://download.draios.com/stable/rpm/draios.repo && \
    yum install -y epel-release && \
    yum -y install kernel-devel-$(uname -r) && \
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
        bash-completion \
        ca-certificates \
        libelf1 \
        kernel-devel \
        net-tools \
        sysdig && \
    yum clean all

RUN ln -s $SYSDIG_HOST_ROOT/lib/modules /lib/modules

RUN pip install --upgrade \
        pip \
        setuptools

COPY ./docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["bash"]

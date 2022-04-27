FROM ubuntu:20.04

# Fix for tzdata for docker image build
ENV TZ=UTC
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install necessary for build packages
RUN apt-get update && apt-get install -y \
    apt-utils cpio python python3 python3-pip python3-pexpect xz-utils debianutils iputils-ping \
    python3-jinja2 libegl1-mesa pylint3 xterm \
    vim locales devscripts debhelper \
    gawk wget diffstat texinfo chrpath socat libsdl1.2-dev \
    python-crypto checkpolicy python3-git python3-github \
    bzr pigz m4 lftp openjdk-8-jdk git-core rsync \
    gnupg flex bison gperf build-essential zip curl zlib1g-dev \
    gcc-multilib g++-multilib libc6-dev-i386 lib32ncurses5-dev \
    x11proto-core-dev libx11-dev lib32z1-dev ccache libgl1-mesa-dev \
    libxml2-utils xsltproc unzip bc ninja-build \
    python3-pyelftools python3-crypto libncurses5 libssl-dev -y && \
    apt-get install --reinstall -y ca-certificates && \
    pip3 install pycryptodomex && \
    apt-get clean && rm -rf /tmp/* /var/tmp/*

# Install repo
RUN curl https://storage.googleapis.com/git-repo-downloads/repo > /usr/bin/repo && chmod a+x /usr/bin/repo

# Set the locale for fix this:
# "Please use a locale setting which supports UTF-8 (such as LANG=en_US.UTF-8)."
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Define name for user and uid/gid
ENV USER_NAME=builder
ARG USER_ID=1000
ARG USER_GID=1000

# Creating the user
RUN groupadd --gid "${USER_GID}" "${USER_NAME}" && \
    useradd \
    --uid ${USER_ID} \
    --gid ${USER_GID} \
    --create-home \
    --shell /bin/bash \
    ${USER_NAME}

# Switch the user from root to $USER_NAME (builder)
USER $USER_NAME

# Create workdir for docker and define it as WORKDIR
RUN mkdir -p /home/$USER_NAME/workspace && chown $USER_NAME:$USER_NAME /home/$USER_NAME/workspace
ENV BUILD_DIR /home/$USER_NAME/workspace
WORKDIR $BUILD_DIR
RUN pip3 install --no-warn-script-location --user git+https://github.com/xen-troops/moulin
ENV PATH ~/.local/bin:$PATH

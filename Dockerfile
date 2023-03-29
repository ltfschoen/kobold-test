FROM cimg/rust:1.68

ARG NAME_PROJECT
ARG NODE_ENV
ARG ROOT_PASSWORD
ARG NONROOT_PASSWORD
ARG PORT_TRUNK
ARG PUBLIC_IP_ADDRESS

ENV RUST_BACKTRACE=1
ENV RUSTUP_HOME="/home/circleci/.rustup"
ENV CARGO_HOME="/home/circleci/.cargo"
WORKDIR /${NAME_PROJECT}
COPY . /${NAME_PROJECT}

RUN /bin/sh -c set -eux && \
    sudo apt-get -y update && sudo apt-get -y upgrade && \
    sudo apt-get install -y git vim wget && \
    . ./scripts/get_latest_nightly_version.sh && \
    # already using a docker image has has recenty rust version but we want the latest
    rustup update && \
    # below line not necessary since logs indicate the nightly version used is overridden by rust-toolchain.toml
    rustup toolchain install "nightly-${LATEST_NIGHTLY_VERSION}" \
        --target wasm32-unknown-unknown --profile default \
        --component rustc cargo rustfmt rust-std rust-docs rust-analyzer clippy miri rust-src llvm-tools-preview && \
    # below should already be installed in the docker image and installed automatically when `trunk` is run using Trunk.toml
    rustup target add wasm32-unknown-unknown && \
    rustup target add wasm32-unknown-unknown --toolchain "nightly-${LATEST_NIGHTLY_VERSION}" && \
    cargo install --version 0.2.84 wasm-bindgen-cli && \
    cargo +"nightly-${LATEST_NIGHTLY_VERSION}" install wasm-gc && \
    . ./scripts/get_latest_crate_version.sh trunk && \
    wget -c https://github.com/thedodd/trunk/releases/download/v${LATEST_CRATE_VERSION}/trunk-x86_64-unknown-linux-gnu.tar.gz -O - | sudo tar -xz -C /usr/local/bin && \
    cargo install --locked trunk && \
    sudo groupadd -g 1000 nonroot && \
    sudo useradd -m -u 1000 -g 1000 -s /bin/sh -d /${NAME_PROJECT} nonroot && \
    sudo adduser nonroot sudo && \
    sudo mkdir -p /${NAME_PROJECT}/dist/.stage && \
    sudo mkdir -p /${NAME_PROJECT}/target && \
	sudo chown -R nonroot:nonroot /${NAME_PROJECT} && \
    sudo chown -R root:nonroot ${RUSTUP_HOME} ${CARGO_HOME} && \
    sudo chmod -R g+w ${RUSTUP_HOME} ${CARGO_HOME} && \
	ldd ${CARGO_HOME}/bin/trunk && \
    rustup show && \
    cargo --version && \
	${CARGO_HOME}/bin/trunk --version && \
    # change password for user so they must use sudo for privileged use
    echo "root:${ROOT_PASSWORD}" | sudo chpasswd && \
    echo "nonroot:${NONROOT_PASSWORD}" | sudo chpasswd

USER nonroot
EXPOSE 8080

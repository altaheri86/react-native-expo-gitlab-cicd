# Android builder image for local EAS builds.
# The runner passes its own UID/GID so files written to the mounted repo and caches stay owned by the runner.
FROM node:22-slim

ARG USER_ID=1000
ARG GROUP_ID=1000

ENV NODE_MODULES=/home/appuser/node_modules
ENV NPM_CONFIG_CACHE=/home/appuser/.npm-cache
ENV GRADLE_USER_HOME=/home/appuser/.gradle
ENV ANDROID_SDK_ROOT=/home/appuser/android-sdk
ENV PATH=$PATH:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    bash \
    curl \
    jq \
    openjdk-17-jdk-headless \
    unzip \
    wget \
    rsync \
    gettext \
    ca-certificates \
    aapt \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN groupadd -g ${GROUP_ID} appuser || true \
 && useradd -m -u ${USER_ID} -g ${GROUP_ID} -s /bin/bash appuser

WORKDIR /home/appuser

RUN npm install -g eas-cli@latest --unsafe-perm=true

RUN mkdir -p $ANDROID_SDK_ROOT \
 && chown -R appuser:appuser /home/appuser $ANDROID_SDK_ROOT

USER appuser
ENV HOME=/home/appuser
WORKDIR /home/appuser/app

# package files first so the dependency layer is cached
COPY --chown=appuser:appuser package*.json ./
COPY --chown=appuser:appuser . .

CMD ["/bin/bash"]

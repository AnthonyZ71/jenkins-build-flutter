FROM sentinel:5000/jenkins-build-android:latest

## Configuration for Flutter development
## Check for updates here:
## https://flutter.dev/docs/get-started/install/linux

ARG flutter_ver=1.20.4

ENV PATH="/usr/local/sonar/bin:/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

USER root

RUN \
    echo "Installing sqlite3" && \
    apt-get update && \
    apt-get install -y \
        libsqlite3-dev \
        sqlite3 \
        && \
    rm -fr /var/lib/apt/lists/* && \
    apt-get clean && \
    echo "Making jenkins owner of sonar and flutter directories." && \
    mkdir /usr/local/sonar && \
    chown -R jenkins:jenkins /usr/local/sonar && \
    mkdir /usr/local/flutter && \
    chown -R jenkins:jenkins /usr/local/flutter

USER jenkins

RUN \
    cd /home/jenkins && \
    echo "Downloading sonar-scanner" && \
    mkdir tmp && \
    cd tmp && \
    curl "https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-4.4.0.2170.zip" \
        -o "sonar-scanner-cli.zip" && \
    echo "Unpacking sonar-scanner" && \
    unzip sonar-scanner-cli.zip && \
    mv */* /usr/local/sonar/ && \
    cd .. && \
    rm -fr tmp && \
    echo "Downloading flutter" && \
    curl "https://storage.googleapis.com/flutter_infra/releases/stable/linux/flutter_linux_${flutter_ver}-stable.tar.xz" \
        -o "flutter_linux_${flutter_ver}-stable.tar.xz" && \
    echo "Unpacking flutter" && \
    tar xf "flutter_linux_${flutter_ver}-stable.tar.xz" \
        --no-same-owner -C /usr/local && \
    /bin/rm "flutter_linux_${flutter_ver}-stable.tar.xz" && \
    echo "Preparing flutter" && \
    which flutter && \
    flutter config --no-analytics && \
    flutter precache && \
    flutter --version && \
    flutter doctor -v

USER root

##

ARG BUILD_DATE
ARG IMAGE_NAME
ARG IMAGE_VERSION
LABEL build-date="$BUILD_DATE" \
      description="Image for Flutter development" \
      summary="Fluttertools installed" \
      name="$IMAGE_NAME"  \
      release="$IMAGE_VERSION" \
      version="$IMAGE_VERSION"

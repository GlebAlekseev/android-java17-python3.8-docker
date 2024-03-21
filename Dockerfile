# Use Python 3.8 as base image
FROM python:3.8

# Update package lists and install OpenJDK 17
RUN apt-get update && \
    apt-get install -y openjdk-17-jdk

# Environment variables
ENV ANDROID_SDK_TOOLS=9477386
ENV ANDROID_SDK_URL=https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_SDK_TOOLS}_latest.zip
ENV ANDROID_BUILD_TOOLS_VERSION=34.0.0
ENV ANDROID_HOME=/usr/local/android-sdk-linux
ENV ANDROID_VERSION=34
ENV PATH="${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools:${ANDROID_HOME}/cmdline-tools/bin"

# Change user to root for necessary permissions
USER root

# Install required packages and Android SDK
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        unzip \
        curl \
        bash \
        git && \
    mkdir -p "${ANDROID_HOME}" ~/.android && \
    cd "${ANDROID_HOME}" && \
    curl -o sdk.zip "${ANDROID_SDK_URL}" && \
    unzip sdk.zip && \
    rm sdk.zip && \
    yes | sdkmanager --licenses --sdk_root="${ANDROID_HOME}" && \
    sdkmanager --update --sdk_root="${ANDROID_HOME}" && \
    sdkmanager --sdk_root="${ANDROID_HOME}" \
        "build-tools;${ANDROID_BUILD_TOOLS_VERSION}" \
        "platforms;android-${ANDROID_VERSION}" \
        "platform-tools" \
        "extras;android;m2repository" \
        "extras;google;m2repository" && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    apt-get autoremove -y && \
    apt-get clean

# Install Gradle 8.4
RUN curl -sLO https://services.gradle.org/distributions/gradle-8.4-bin.zip && \
    unzip -d /opt gradle-8.4-bin.zip && \
    ln -s /opt/gradle-8.4/bin/gradle /usr/bin/gradle && \
    rm gradle-8.4-bin.zip
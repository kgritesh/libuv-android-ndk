FROM openjdk:8-jdk
MAINTAINER Ritesh Kadmawala <k.g.ritesh@gmail.com>
LABEL VERSION="0.0.0"
LABEL NAME="malvo/libuv-android-ndk"
LABEL DESCRIPTION="Pre-Build libuv for multiple architeures to be used by an \
                   android ndk project"

WORKDIR /opt/

ENV WORKDIR /opt
ENV ANDROID_HOME ${WORKDIR}/android-sdk-linux
ENV ANDROID_SDK_HOME ${WORKDIR}/android-sdk-linux
ENV ANDROID_SDK_MANAGER ${ANDROID_SDK_HOME}/tools/bin/sdkmanager
ENV ANDROID_NDK_HOME ${ANDROID_SDK_HOME}/ndk-bundle
ENV ANDROID_SDK_VERSION r25.2.3

RUN apt-get update && apt-get install -y --no-install-recommends \
	unzip \
	wget \
  curl \
  libtool \
  m4 \
  automake

RUN cd ${WORKDIR} \
    && wget -q --output-document=android-sdk-linux.zip https://dl.google.com/android/repository/tools_${ANDROID_SDK_VERSION}-linux.zip \
    && unzip android-sdk-linux.zip -d ${ANDROID_HOME} \
    && rm -rf android-sdk-linux.zip


ENV PATH ${ANDROID_NDK_HOME}:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:$ANDROID_HOME/platform-tools:$PATH

# Install Android SDK Components
ENV ANDROID_COMPONENTS "tools" \
                       "platform-tools" \
                       "build-tools;26.0.2" \
                       "platforms;android-25"


ENV GOOGLE_COMPONENTS "extras;android;m2repository" \
                       "extras;google;m2repository" \
                       "extras;google;google_play_services"

ENV CONSTRAINT_LAYOUT "extras;m2repository;com;android;support;constraint;constraint-layout;1.0.2"\
                       "extras;m2repository;com;android;support;constraint;constraint-layout-solver;1.0.2"

ENV ANDROID_NDK_COMPONENTS "ndk-bundle" \
                       "lldb;3.0" \
                       "cmake;3.6.4111459"

RUN mkdir -p ${ANDROID_SDK_HOME}/.android && touch ${ANDROID_SDK_HOME}/.android/repositories.cfg

RUN mkdir -p ${ANDROID_HOME}/licenses/ && \
    echo "8933bad161af4178b1185d1a37fbf41ea5269c55" > ${ANDROID_HOME}/licenses/android-sdk-license && \
    echo "d56f5187479451eabf01fb78af6dfcb131a6481e" > ${ANDROID_HOME}/licenses/android-sdk-license && \
    ${ANDROID_SDK_MANAGER} --verbose ${ANDROID_NDK_COMPONENTS}

COPY cross-compile.sh ${WORKDIR}

CMD ${WORKDIR}/cross-compile.sh

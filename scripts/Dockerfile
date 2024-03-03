FROM debian:sid-slim

# Update and install dependencies
RUN apt-get update -y && \
    apt-get install -y curl unzip git ca-certificates \
    libglu1-mesa lib32stdc++6 rpm yq xz-utils \
    clang cmake ninja-build pkg-config liblzma-dev libgtk-3-dev libblkid1 \
    file fuse appstream gpg

# Download and install appimagetool
RUN curl -L -o appimagetool.AppImage https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage && \
    chmod +x appimagetool.AppImage && \
    mv appimagetool.AppImage /usr/local/bin/appimagetool

# Environment variables for Flutter's installation 
ENV FLUTTER_VERSION=3.19.0
ENV FLUTTER_HOME=/opt/flutter

# Download the Flutter SDK 
RUN curl -L -o flutter.zip https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz && \
    mkdir -p $FLUTTER_HOME && \
    tar -xf flutter.zip -C $FLUTTER_HOME --strip-components=1 && \
    rm flutter.zip 

ENV PATH="$FLUTTER_HOME/bin:$PATH"

RUN chown -R $(whoami):$(whoami) /opt/flutter 

# Run Flutter precache (downloads dependencies)
RUN flutter precache

# For future when we support android. Install Android SDK and accept licenses (If you plan to build Android apps)
# ENV ANDROID_SDK_ROOT=/opt/android-sdk
# RUN mkdir -p $ANDROID_SDK_ROOT && \
#     curl -sSL https://dl.google.com/android/repository/commandlinetools-linux-8512546_latest.zip -o cmdline-tools.zip && \
#     unzip cmdline-tools.zip -d $ANDROID_SDK_ROOT && \
#     rm cmdline-tools.zip && \
#     yes | $ANDROID_SDK_ROOT/cmdline-tools/bin/sdkmanager --install "platforms;android-33" "build-tools;33.0.0" "cmdline-tools;latest" && \
#     yes | $ANDROID_SDK_ROOT/cmdline-tools/bin/sdkmanager --licenses



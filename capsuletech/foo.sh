set -eux; 
arch="$(dpkg --print-architecture)"; 
case "$arch" in 'amd64') 
    downloadUrl='https://github.com/AdoptOpenJDK/openjdk11-upstream-binaries/releases/download/jdk-11.0.11%2B9/OpenJDK11U-jdk_x64_linux_11.0.11_9.tar.gz'; 
    ;; 
    'arm64') 
    downloadUrl='https://github.com/AdoptOpenJDK/openjdk11-upstream-binaries/releases/download/jdk-11.0.11%2B9/OpenJDK11U-jdk_aarch64_linux_11.0.11_9.tar.gz'; 
    ;; 
    *) 
    echo >&2 "error: unsupported architecture: '$arch'"; 
    exit 1 
    ;;
esac;
######################
# MGK
# Changed key server to pgp.mit.edu (ha.pool.sks-keyservers.net -- original keyserver no longer in service)
# Doesn't work on test Ubuntu image. java command not found on line 44
#
# Not tested on GCP GCE image (Centos7 based)
#
######################

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

savedAptMark="$(apt-mark showmanual)"; 
apt-get update; 
apt-get install -y --no-install-recommends dirmngr gnupg wget ; 
rm -rf /var/lib/apt/lists/*; 
wget --progress=dot:giga -O openjdk.tgz "$downloadUrl"; 
wget --progress=dot:giga -O openjdk.tgz.asc "$downloadUrl.sign"; 
export GNUPGHOME="$(mktemp -d)"; 
gpg --batch --keyserver pgp.mit.edu --recv-keys EAC843EBD3EFDB98CC772FADA5CD6035332FA671; 
gpg --batch --keyserver pgp.mit.edu --keyserver-options no-self-sigs-only --recv-keys CA5F11C6CE22644D42C6AC4492EF8D39DC13168F; 
gpg --batch --list-sigs --keyid-format 0xLONG CA5F11C6CE22644D42C6AC4492EF8D39DC13168F | tee /dev/stderr | grep '0xA5CD6035332FA671' | grep 'Andrew Haley'; 
gpg --batch --verify openjdk.tgz.asc openjdk.tgz; 
gpgconf --kill all; rm -rf "$GNUPGHOME"; 

mkdir -p "$JAVA_HOME"; 
tar --extract --file openjdk.tgz --directory "$JAVA_HOME" --strip-components 1 --no-same-owner ; 
rm openjdk.tgz*; apt-mark auto '.*' > /dev/null; 

[ -z "$savedAptMark" ] || apt-mark manual $savedAptMark > /dev/null; 
apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; 
{ echo '#!/usr/bin/env bash'; echo 'set -Eeuo pipefail'; echo 'trust extract --overwrite --format=java-cacerts --filter=ca-anchors --purpose=server-auth "$JAVA_HOME/lib/security/cacerts"'; } > /etc/ca-certificates/update.d/docker-openjdk; 
chmod +x /etc/ca-certificates/update.d/docker-openjdk; 
/etc/ca-certificates/update.d/docker-openjdk; 

find "$JAVA_HOME/lib" -name '*.so' -exec dirname '{}' ';' | sort -u > /etc/ld.so.conf.d/docker-openjdk.conf; 
ldconfig; 
java -Xshare:dump; 
fileEncoding="$(echo 'System.out.println(System.getProperty("file.encoding"))' | jshell -s -)"; [ "$fileEncoding" = 'UTF-8' ]; 

rm -rf ~/.java; javac --version; java --version
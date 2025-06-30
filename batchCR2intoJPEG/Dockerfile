FROM ubuntu

RUN apt update && apt install -y \
    dcraw \
    libjpeg-progs \
    exiftool \
    findutils \
    coreutils \
    bash \
    && rm -rf /var/lib/apt/lists/*

COPY cr2jpeg.sh /usr/local/bin/cr2jpeg.sh
RUN chmod +x /usr/local/bin/cr2jpeg.sh

ENTRYPOINT ["/usr/local/bin/cr2jpeg.sh"]
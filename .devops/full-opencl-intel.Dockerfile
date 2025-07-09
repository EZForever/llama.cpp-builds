FROM ubuntu:24.04

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y libgomp1 openssl curl intel-opencl-icd clinfo python3 python3-pip \
    && apt autoremove -y \
    && apt clean -y \
    && rm -rf /tmp/* /var/tmp/* \
    && find /var/cache/apt/archives /var/lib/apt/lists -not -name lock -type f -delete \
    && find /var/cache -type f -delete

COPY --chown=0:0 . /app

WORKDIR /app

RUN pip install --user --break-system-packages --no-cache-dir --upgrade pip setuptools wheel \
    && pip install --user --break-system-packages --no-cache-dir -r requirements.txt

ENTRYPOINT ["/app/tools.sh"]


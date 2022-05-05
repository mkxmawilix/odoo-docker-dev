FROM ubuntu:20.04

# Generate locale C.UTF-8 for postgres and general locale data
ENV LANG C.UTF-8

# Install System dependencies
ARG DEBIAN_FRONTEND=noninteractive
RUN set -x; \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        dirmngr \
        fonts-noto-cjk \
        gnupg \
        libssl-dev \
        node-less \
        npm \
        postgresql-client \
        build-essential \
        libpq-dev \
        libxml2-dev \
        libxslt1-dev \
        libldap2-dev \
        libssl-dev \
        libsasl2-dev \
        python3-setuptools \
        python3-pip \
        python3-dev \
        python3-num2words \
        python3-pdfminer \
        python3-pip \
        python3-phonenumbers \
        python3-pyldap \
        python3-qrcode \
        python3-renderpm \
        python3-setuptools \
        python3-slugify \
        python3-vobject \
        python3-watchdog \
        python3-xlrd \
        python3-xlwt \
        xz-utils \
        nano \
        git \
        openssh-client \
    && curl -o wkhtmltox.deb -sSL https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6-1/wkhtmltox_0.12.6-1.focal_amd64.deb \
    && apt-get install -y --no-install-recommends ./wkhtmltox.deb \
    && rm -rf /var/lib/apt/lists/* wkhtmltox.deb


# Create odoo user and directories and set permissions
RUN useradd -ms /bin/bash odoo \
    && mkdir /etc/odoo /opt/odoo /opt/odoo/scripts \
    && chown -R odoo:odoo /etc/odoo /opt/odoo

WORKDIR /opt/odoo

# Install Odoo and dependencies from latest source
USER odoo
RUN git clone --branch=14.0 --depth=1 https://github.com/odoo/odoo.git odoo

USER root
RUN pip3 install psycopg2-binary
RUN pip3 install --no-cache-dir -r odoo/requirements.txt

# Install debugpy
RUN pip3 install -U debugpy

# Define runtime configuration
COPY src/entrypoint.sh /opt/odoo
COPY src/odoo.conf /etc/odoo
RUN chown odoo:odoo /etc/odoo/odoo.conf

USER odoo

RUN mkdir /opt/odoo/data /opt/odoo/custom_addons \
    /opt/odoo/.vscode /home/odoo/.vscode-server

ENV ODOO_RC /etc/odoo/odoo.conf
ENV PATH="/opt/odoo/scripts:${PATH}"

EXPOSE 8069 8071 8072 3000
ENTRYPOINT ["/opt/odoo/entrypoint.sh"]
CMD ["odoo"]

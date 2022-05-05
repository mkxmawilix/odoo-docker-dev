FROM ubuntu:18.04

# Generate locale C.UTF-8 for postgres and general locale data
ENV LANG C.UTF-8

# Install System dependencies
RUN set -x; \
    apt-get update \
    && apt-get install -y curl \
    && curl -o wkhtmltox.deb -sSL https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.bionic_amd64.deb \
    && apt-get install -y --no-install-recommends \
    ./wkhtmltox.deb \
    postgresql-client \
    build-essential \
    python-minimal \
    python-setuptools \
    python-pip \
    python-dev \
    python-ldap \
    nano \
    git \
    openssh-client \
    libsasl2-dev \
    python-dev \
    libldap2-dev \
    libssl-dev \
    libpq-dev \
    libxslt1-dev \
    zlib1g-dev \
    python-ldap \
    ghostscript \
    graphviz \
    && apt-get install -y --no-install-recommends \
    nodejs-dev \
    nodejs \
    node-gyp \
    npm \
    && rm -rf /var/lib/apt/lists/* wkhtmltox.deb

# Create odoo user and directories and set permissions
RUN useradd -ms /bin/bash odoo \
    && mkdir /etc/odoo /opt/odoo /opt/odoo/scripts \
    && chown -R odoo:odoo /etc/odoo /opt/odoo

WORKDIR /opt/odoo

# Install Odoo and dependencies from latest source
USER odoo
RUN git clone --branch=10.0 --depth=1 https://github.com/odoo/odoo.git odoo

USER root
RUN pip install --no-cache-dir -r odoo/requirements.txt

# Debugpy
RUN pip install debugpy

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

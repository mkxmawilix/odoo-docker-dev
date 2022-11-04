FROM debian:bullseye-slim

SHELL ["/bin/bash", "-xo", "pipefail", "-c"]

# Generate locale C.UTF-8 for postgres and general locale data
ENV LANG C.UTF-8

# Install some deps, lessc and less-plugin-clean-css, and wkhtmltopdf
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        dirmngr \
        fonts-noto-cjk \
        gnupg \
        libpq-dev \
        libxml2-dev \
        libxslt1-dev \
        libldap2-dev \
        libssl-dev \
        libsasl2-dev \
        node-less \
        npm \
        libpq-dev \
        postgresql-client \
        build-essential \
        python3-setuptools \
        python3-pip \
        python3-dev \
        python3-num2words \
        python3-pdfminer \
        python3-pip \
        python3-phonenumbers \
        python3-openssl \
        python3-pyldap \
        python3-qrcode \
        python3-renderpm \
        python3-slugify \
        python3-vobject \
        python3-watchdog \
        python3-xlrd \
        python3-xlwt \
        xz-utils \
        git \
        nano \
    && curl -o wkhtmltox.deb -sSL https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.buster_amd64.deb \
    && echo 'ea8277df4297afc507c61122f3c349af142f31e5 wkhtmltox.deb' | sha1sum -c - \
    && apt-get install -y --no-install-recommends ./wkhtmltox.deb \
    && rm -rf /var/lib/apt/lists/* wkhtmltox.deb

# Install rtlcss (on Debian buster)
RUN npm install -g rtlcss

# Create odoo user and directories and set permissions
RUN useradd -ms /bin/bash odoo \
    && mkdir /etc/odoo /opt/odoo /opt/odoo/scripts /opt/odoo/profile\
    && chown -R odoo:odoo /etc/odoo /opt/odoo

WORKDIR /opt/odoo

# Install Odoo and dependencies from latest source
USER odoo
RUN git clone --branch=16.0 --depth=1 https://github.com/odoo/odoo.git odoo
USER root
RUN pip3 install psycopg2-binary
RUN pip3 install --no-cache-dir -r odoo/requirements.txt

# Copy entrypoint script and Odoo configuration file
COPY ./src/entrypoint.sh /opt/odoo
COPY ./src/odoo.conf /etc/odoo/
RUN chown odoo:odoo /etc/odoo/odoo.conf

# Copy Odoo shell script and config file
COPY ./src/odoo-shell.sh /opt/odoo
COPY ./src/odoo-shell.conf /etc/odoo
RUN chown odoo:odoo /etc/odoo/odoo-shell.conf

# Used for debug and python profiling
RUN pip3 install debugpy
RUN pip3 install snakeviz
RUN pip3 install pstats_print2list
RUN pip3 install py-spy
# Copy snakeviz script to start of the snakeviz web server and the good Host/Port
COPY ./src/snakeviz.sh /opt/odoo

USER odoo

# Create other directories
RUN mkdir /opt/odoo/data /opt/odoo/custom_addons

# Set the default config file
ENV ODOO_RC /etc/odoo/odoo.conf

# Add directory to the PATH
ENV PATH="/opt/odoo/scripts:/opt/odoo/profile:${PATH}"

# Expose Odoo services
EXPOSE 8069 8071 8072 3000 8088
ENTRYPOINT ["/opt/odoo/entrypoint.sh"]
CMD ["odoo"]

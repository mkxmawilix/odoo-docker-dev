#!/bin/bash
set -e
cd odoo
exec ./odoo-bin shell \
    "--config=/etc/odoo/odoo-shell.conf" \
    "--db_host=$DB_HOST" \
    "--db_port=$DB_PORT" \
    "--db_user=$DB_USER" \
    "--db_password=$DB_PASSWORD" \
    $ODOO_EXTRA_ARGS "$@"
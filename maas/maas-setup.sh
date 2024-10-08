#!/usr/bin/env bash
# vim: set ai et ts=4 sts=4 sw=4 syntax=sh:
# -*- coding: utf-8 -*-

declare -a maas_services=(
    "maas-apiserver"
    "maas-rackd"
    "maas-regiond"
    "maas-temporal"
    "maas-temporal-worker"
)

function log() {
    echo -e "\e[1;32m$@\e[0m"
}

function log_warn() {
    echo -e "\e[1;33m$@\e[0m"
}

function log_warn_callout() {
    log_warn ""
    log_warn " ==========> $@ <========== "
    log_warn ""
}

function log_error() {
    echo -e "\e[1;31m$@\e[0m"
}

function wait_for_maas_version_response() {
    while true
    do
        resp=$(curl -sSL http://localhost:5240/MAAS/api/2.0/version/)
        err=$?
        if [[ "${err}" == "0" ]]; then
            maas_version=$(echo ${resp} | jq .version)
            if [[ "$?" == "0" ]]; then
                log "MAAS version ${maas_version} is ready to go!"
                break
            fi
        fi

        log_warn "Still waiting for MAAS to be ready..."
        sleep 5
    done
}

function restart_maas_services() {
    for service in "${maas_services[@]}"; do
        log "Restarting ${service}..."
        systemctl restart "${service}"
    done
}

function stop_maas_services() {
    for service in "${maas_services[@]}"; do
        log "Stopping ${service}..."
        systemctl stop "${service}"
    done
}

function enable_now_maas_services() {
    for service in "${maas_services[@]}"; do
        log "Enabling and starting ${service}..."
        systemctl enable --now "${service}"
    done
}

function needs_setup() {
    if [ ! -f /var/lib/maas/.maasSetupDone ]; then
        return 0
    fi

    return 1
}

function setup_maas() {
    log "Setting up MAAS for the first time..."
    stop_maas_services

    if test ! -z "${MAAS_SETUP_DISABLE_POSTGRESQL}" ; then
        log "Disabling PostgreSQL..."
        systemctl disable --now postgresql
        systemctl mask postgresql

        log "Configuring MAAS to use external database..."
        maas-region local_config_set \
            --maas-url "${MAAS_SETUP_MAAS_URL:-http://localhost:5240/MAAS}" \
            --database-host "${MAAS_SETUP_EXTERNAL_DATABASE_HOST}" \
            --database-name "${MAAS_SETUP_EXTERNAL_DATABASE_NAME}" \
            --database-user "${MAAS_SETUP_EXTERNAL_DATABASE_USER}" \
            --database-pass "${MAAS_SETUP_EXTERNAL_DATABASE_PASSWORD}" \
            --database-port "${MAAS_SETUP_EXTERNAL_DATABASE_PORT:-5432}"
        maas-region dbupgrade

        log "Initializing MAAS with external database..."
        maas init \
            --skip-admin \
            --rbac-url "${MAAS_SETUP_CANONICAL_RBAC_URL}" \
            --candid-agent-file "${MAAS_SETUP_CANONICAL_CANDID_AGENT_FILE}"
    fi

    if test -z "${MAAS_SETUP_ADMIN_USERNAME}" ; then
        MAAS_SETUP_ADMIN_USERNAME="admin"
        log_warn_callout "MAAS_SETUP_ADMIN_USERNAME not set, using default: ${MAAS_SETUP_ADMIN_USERNAME}"
    fi

    if test -z "${MAAS_SETUP_ADMIN_EMAIL}" ; then
        MAAS_SETUP_ADMIN_EMAIL="admin@misconfigured.lol"
        log_warn "MAAS_SETUP_ADMIN_EMAIL not set, using placeholder: ${MAAS_SETUP_ADMIN_EMAIL}"
    fi

    if test -z "${MAAS_SETUP_ADMIN_PASSWORD}" ; then
        MAAS_SETUP_ADMIN_PASSWORD=$(pwgen -s 32 1)
        log_warn_callout "MAAS_SETUP_ADMIN_PASSWORD not set, generated a random password: ${MAAS_SETUP_ADMIN_PASSWORD}"
    fi

    if test -z "${MAAS_SETUP_ADMIN_SSHKEYS_GITHUB}" ; then
        log_error "MAAS_SETUP_ADMIN_SSHKEYS_GITHUB not set! SSH keys are required for MAAS to function properly."
        exit 1
    fi

    enable_now_maas_services

    log "Creating admin user ${MAAS_SETUP_ADMIN_USERNAME}..."
    maas createadmin --username "${MAAS_SETUP_ADMIN_USERNAME}" \
        --password "${MAAS_SETUP_ADMIN_PASSWORD}" \
        --email "${MAAS_SETUP_ADMIN_EMAIL}" \
        --ssh-import "gh:${MAAS_SETUP_ADMIN_SSHKEYS_GITHUB}"

    log "Waiting for MAAS to be ready..."
    wait_for_maas_version_response

    log "Setting up MAAS CLI profile..."
    maas apikey --username "${MAAS_SETUP_ADMIN_USERNAME}" > /etc/maas/admin-api-key
    maas login default "http://localhost:5240/MAAS" "$(cat /etc/maas/admin-api-key)"

    log "Testing MAAS CLI profile..."
    maas default version read

    log "MAAS setup complete!"
    touch /var/lib/maas/.maasSetupDone
    rm /app/maas-setup.env
}

function main() {
    env

    if needs_setup; then
        setup_maas
    fi
}

main
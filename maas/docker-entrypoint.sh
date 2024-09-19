#!/usr/bin/env bash
# vim: set ai et ts=4 sts=4 sw=4 syntax=sh:
# -*- coding: utf-8 -*-

env | grep MAAS_SETUP_ > /app/maas-setup.env

echo "Handing control to systemd..."

exec /lib/systemd/systemd --system
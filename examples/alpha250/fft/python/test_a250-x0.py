#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os

from koheron import command, connect

class A250_X0_PowerMonitor(object):
    def __init__(self, client):
        self.client = client

    @command()
    def get_shunt_voltage(self):
        return self.client.recv_float()

    @command()
    def get_bus_voltage(self):
        return self.client.recv_float()

host = os.getenv('HOST', '192.168.1.17')
client = connect(host, 'fft', restart=False)
pwr_mon = A250_X0_PowerMonitor(client)

print("Voltage = {} V. Current = {} A".format(pwr_mon.get_bus_voltage(), 100 * pwr_mon.get_shunt_voltage()))
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

class A250_X0_Eeprom(object):
    def __init__(self, client):
        self.client = client
    
    @command()
    def set_serial_number(self, sn):
        return self.client.recv_int32()

    @command()
    def get_serial_number(self):
        return self.client.recv_uint32()

class A250_X0_Trigger(object):
    def __init__(self, client):
        self.client = client

    @command()
    def set_threshold(self, voltage):
        return self.client.recv_int32()

host = os.getenv('HOST', '192.168.1.17')
client = connect(host, 'fft', restart=False)

# Power monitor
pwr_mon = A250_X0_PowerMonitor(client)
print("Voltage = {} V. Current = {} A".format(pwr_mon.get_bus_voltage(), 100 * pwr_mon.get_shunt_voltage()))

# Eeprom
eeprom = A250_X0_Eeprom(client)
sn = 42
eeprom.set_serial_number(sn)
assert eeprom.get_serial_number() == sn

# Trigger
trigger = A250_X0_Trigger(client)
trigger.set_threshold(2.0)
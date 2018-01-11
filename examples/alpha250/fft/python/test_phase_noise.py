#!/usr/bin/env python
# -*- coding: utf-8 -*-

'''
Measure the DAC phase noise
'''

import numpy as np
import matplotlib
matplotlib.use('GTKAgg')
from matplotlib import pyplot as plt

from scipy import signal
import os, time
from koheron import connect
from fft import FFT

host = os.getenv('HOST', '192.168.1.12')
client = connect(host, 'fft')
driver = FFT(client)

driver.set_dds_freq(0, 10e6)


n = 524288/2
fs = 250e6
cic_rate = 500

ffft = np.fft.fftfreq(n) * fs / (cic_rate * 2)

# Dynamic plot
fig = plt.figure()
ax = fig.add_subplot(111)
x = np.arange(n)
y = np.ones(n/2)

li, = ax.semilogx(np.fft.fftshift(ffft[1:n/2+1]), y)
ax.set_ylim((-170, -80))
ax.set_ylabel('Frequency (Hz)')
ax.set_ylabel('dBc/Hz')

fig.canvas.draw()

#window = 0.5 * (1 - np.cos(2*np.pi*np.arange(n)/(n-1)))
window = np.ones(n)
W = np.sum(window ** 2) # Correction factor for window

n_avg = 20
dsp = np.zeros((n_avg, n))
i = 0

while True:
    try:
        i = (i + 1) % n_avg
        print i
        #print driver.get_fifo_length()
        data = driver.get_data(2*n)
        z = data[::2] + 1j*data[1::2]

        dsp[i,:] = 2 * np.abs(np.fft.fft(window * np.unwrap(np.angle(z))))**2
        dsp[i,:] /= (fs / (cic_rate * 2) * W)  # rad^2/Hz
        dsp[i,:] = 10 * np.log10(dsp[i,:] / 2) # dBc/Hz (Factor 1/2 because SSB phase noise)

        mean_dsp = np.mean(dsp, axis=0)

        li.set_ydata(np.fft.fftshift(mean_dsp[1:n/2+1]))

        fig.canvas.draw()
        plt.pause(0.001)

    except KeyboardInterrupt:
        break
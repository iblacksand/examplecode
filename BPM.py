from os import abort
from examples.example import calcspec
import click
import math
import matplotlib
import matplotlib.pyplot as plt
import numpy as np
from matplotlib import style
import pyfirmata
import time
from tkinter.filedialog import asksaveasfile
from scipy.signal import find_peaks

matplotlib.rcParams['font.sans-serif'] = ['Palatino', 'sans-serif']

@click.command()
@click.option('--time', '-t', 't1', default=60, show_default=True, help='Total time to record data in seconds.')
@click.option('--cycle', '-c', 'cycle', default=5, show_default=True, help='How long each cycle takes before calculating BPM')
@click.option('--brightness', '-b', 'b', default=0.85, show_default=True, help='Percent brightness for the LED')
@click.option('--frequency', '-f', 'f', default=20, show_default=True, help='Data acquisition frequency.')
@click.option('--save', '-s', 's', is_flag=True, help='save the data after processing')
@click.option('--show-plot', '-showp', 'showp', is_flag=True, help='Show the results of autocorrelation or FFT')
@click.option('--port', '-p', 'port', default='/dev/cu.usbmodem1301', show_default=True, prompt='Arduino Port', help='The port of the Arduino.')
def start(t1, cycle, b, f, s, showp, port): 
    '''Runs the data collection and calculations
    ''' 
    board = pyfirmata.Arduino(port)
    
    it = pyfirmata.util.Iterator(board)
    it.start()
    click.clear()
    analog_input = board.get_pin('a:0:i')
    led = board.get_pin('d:3:p')
    led.write(b)
    style.use('fivethirtyeight')
    click.echo('The time you selected was: %s' % t1)
    mass_data = []
    bpms = []
    for x in range(0, math.ceil(t1/cycle)):
        data = gather(analog_input, cycle, f)
        mass_data.extend(data)
        bpm = calcspec(data, f, showp)
        bpms.append(bpm)
        avbpm = np.average(bpms)
        click.echo("\nCurrent BPM: " + str(bpm) + "\n" + "Average BPM: "+ str(avbpm))
    t = np.linspace(0, t1, f*t1)
    fig, ax = plt.subplots()
    ax.plot(mass_data)
    ax.set(xlabel='time (s)', ylabel='voltage (V)',
        title='Total Voltages')
    ax.grid()
    print('BPM using all data: ' + str(calcspec(mass_data, f, showp)))
    # plt.show()
    if s:
        save(mass_data)

def gather(analog_input, cycle, f):
    """gathers voltage readings for the specified amount of time

    Args:
        cycle (int): length of time to run the cycle
        f (int): frequency of collection

    Returns:
        double array: array of the voltages collected at the frequency rate
    """    
    tick = 1/f
    data = []
    print()
    for i in range(0, math.ceil(cycle/tick)):
        reading = analog_input.read()
        if reading != None:
            data.append(5*reading)
            print('Measured Voltage: ' + str(data[len(data)-1]), end = "\r")
        time.sleep(tick)
    return data

def calcauto(data, f, showa):
    """calculates the beats per minute of a provided signal

    Args:
        data (double array): array of voltages to calculate bpm from
        f (frequency): frequency used to collect the data
        showa (boolean): whether or not to show the graph of the autocorrelation

    Returns:
        double: the beats per minute of the signal
    """    
    x = autocorr(data)
    peaks,_ = find_peaks(x, prominence=1)
    # bpms = []
    # for i in range(0, len(peaks[0])-1):
    #     bpms.append(1/(peaks[0][i+1] - peaks[0][i])*f*60)
    # bpm = np.average(bpms)
    bpm = 1/(peaks[len(peaks) - 1] - peaks[len(peaks) - 2])*f*60
    if showa:
        fig, (ax, bx) = plt.subplots(1, 2)
        ax.plot(peaks, x[peaks], "ob"); ax.plot(x); ax.legend(['prominence'])
        bx.plot(data)
        plt.show()
    return bpm

def save(data):
    """saves the given data into a csv file

    Args:
        data (double array): array to save into a csv file
    """    
    files = [ ('Comma-separated values', '*.csv')]
    # file = asksaveasfile(filetypes = files, defaultextension = files)
    a = np.asarray(data)
    a.tofile("test.csv",sep=',',format='%10.5f')

def autocorr(x):
    """runs autocorrelation on the provided array

    Args:
        x (double array): array to run autocorrelation on

    Returns:
        double array: results of the autocorrelation
    """
    result = np.correlate(x, x, mode='full')
    return result[math.floor(result.size/2):]


def calcfft(data, f, showf):
    """calculates bpm using FFT

    Args:
        data (double array): data to calculate BPM from
        f (double): frequency of signal
        showf (boolean): controls whether graph of fft is shown
    
    Returns:
        double: beats per minute found in the signal
    """
    data = normalize(data)
    data = data - np.average(data)
    Y = np.fft.fft(data)
    Y = np.abs(Y)
    freq = np.fft.fftfreq(len(data), 1/f)
    Y = Y[:int(len(Y)/2)]
    freq = freq[:int(len(freq)/2)]
    K = 240/60
    idx = (np.abs(freq - K)).argmin()
    K2 = 50/60
    idx2 = (np.abs(freq - K2)).argmin()
    Y = Y[idx2:idx]
    freq = freq[idx2:idx]
    peaks,_ = find_peaks(Y, prominence=1)
    locY = np.argmax(Y) # Find max peak
    maxf = freq[locY]
    print("max frequency: " + str(maxf))
    print("Converted to bpm: " + str(maxf*60))
    if showf:
        fig, (ax, bx) = plt.subplots(1, 2)
        ax.plot(Y); ax.plot(peaks, Y[peaks], "ob");  ax.legend(['prominence'])
        bx.plot(data)
        plt.show()
    return maxf*60

def normalize(x):
    norm = np.linalg.norm(x)
    return x/norm

if __name__ == '__main__':
    start()
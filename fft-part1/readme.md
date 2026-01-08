# FFT Low-Frequency Spectrum Visualizer (1-256 Hz)

this project is a real-time low-frequency spectrum analyzer built with löve (love2d). it focuses on the frequency range from 1 to 256 hz with a resolution of 1 hz. the program performs downsampling, windowing, fft analysis, peak detection, and visualization of the resulting spectrum.

## what this program does

the application captures one second of audio, resamples it to 512 hz, applies a hann window, and computes a 512-point fft. it then displays the magnitude spectrum for frequencies from 1 to 256 hz. the program also detects the strongest frequency peaks using parabolic interpolation for improved accuracy.

a synthetic audio generator is included for demonstration, but you can replace it with your own audio source.

## why it is useful

this tool is designed for analyzing low-frequency components of audio signals. it is useful for:

- studying harmonic structures and subharmonics
- visualizing low-frequency content in real time
- testing dsp algorithms
- educational purposes related to fft, windowing, and peak detection
- debugging or analyzing audio signals in the sub-256 hz range

because the fft size and sampling rate are aligned, each fft bin corresponds exactly to 1 hz, making interpretation straightforward.

## how to use

1. install löve (love2d) from the official website.
2. place the project files in a directory.
3. run the project using:

```
love .
```

the program will start playing a synthetic looping audio signal and display its spectrum.

the spectrum updates once per second.

use the following controls:

- space: pause or resume playback
- escape: quit the application

if you want to analyze your own audio file, replace the synthetic sound generation block in `love.load()` with loading your own `sounddata` and creating a `source` from it.

## key features

- downsampling from 44100 hz to 512 hz
- hann windowing
- recursive cooley-tukey fft implementation
- real-time visualization of 1-256 hz spectrum
- peak detection with parabolic interpolation
- configurable synthetic audio generator
- spectra spread even for integer frequencies to show rea
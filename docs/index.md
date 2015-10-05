 
# Introduction

``BDF.jl`` is a julia module to read BIOSEMI 24-bit [BDF files](http://www.biosemi.com/faq/file_format.htm).


## Download and Installation

The source code of ``BDF.jl`` is hosted on
github: [https://github.com/sam81/BDF.jl](https://github.com/sam81/BDF.jl)

It can be installed in Julia using

```julia
Pkg.add("BDF")
```

## Usage

Load the module

```julia
using BDF
```

To read an entire BDF recording

```julia
dats, evtTab, trigChan, sysCodeChan = readBDF("res1.bdf")
```

`dats` is the nChannelXnSamples matrix containing the data. Note that the 
triggers are not contained in the `dats` matrix. The triggers can be retrieved 
either trough the event table (`evtTab`), or the raw trigger channel (`trigChan`). 
The eventTable is a dictionary containing the trigger codes `evtTab["code"]`, 
the trigger indexes `evtTab["idx"]` (i.e. the sample numbers at which triggers 
occurred in the recording), and the trigger durations `evtTab["dur"]` (in seconds). 
The raw trigger channel returned in `trigChan` contains the trigger code for each recording sample. 
Additional Biosemi status codes (like CM in/out-of range, battery low/OK) are returned in `sysCodeChan`.

You can also read only part of a recording, the following code will read the first 10 seconds of the recording:

```julia
dats, evtTab, trigChan, statChan = readBDF("res1.bdf", from=0, to=10) 
```    

The `readBDFHeader` function can be used to get information on the BDF recording:

```julia
bdfInfo = readBDFHeader("res1.bdf")
```

Get the duration of the recording:

```julia
bdfInfo["duration"]
```
Get the sampling rate of each channel:

```julia
    bdfInfo["sampRate"]
```

Get the channel labels:

```julia
bdfInfo["chanLabels"]
```


Beware that `BDF.jl` does not check that you have sufficient RAM to 
read all the data in a BDF file. If you try to read a file that is
too big for your hardware, your system may become slow or unresponsive.
Initially try reading only a small amount of data, and check how much
RAM that uses. 

### Bugs

Please, report any bugs on the project [issues page](https://github.com/sam81/BDF.jl/issues)

#### Known Issues

No particular attention has been given to decoding the information stored in the
`sysCodeChan` (like CM in/out-of range, battery low/OK), suggestions on how to 
handle this are welcome.



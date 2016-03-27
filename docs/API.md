Read the data from a BDF file

##### Args:

* `fName`: Name of the BDF file to read.
* `from`: Start time of data chunk to read (seconds).
* `to`: End time of data chunk to read (seconds).
* `channels`: Channels to read (indices or channel names).
* `transposeData`: If `true`, return transposed version of the `dats` array. Default is `false`.

##### Returns:

* `dats::Array{Float32, 2}`: The matrix containing the data, this will be a nChannels X nDataPoints matrix if `transposeData` is `false` (default).
                             If `transposeData` is `true`, however, it will be a nDataPoints X nChannels matrix.
* eventTable: dictionary with three fields
    * code: trigger codes
    * idx: trigger indexes
    * dur: trigger durations
* trigChannel: the raw trigger channel
* syscodeChannel: the raw system codes channel


##### Examples:

```julia
dats, evtTab, trigChan, sysChan = readBDF("res1.bdf")
dats, evtTab, trigChan, sysChan = readBDF("res1.bdf", channels=[1,3]) #read only channels 1 and 3
dats, evtTab, trigChan, sysChan = readBDF("res1.bdf", channels=["Fz","RM"]) #read only channels Fz and RM
dats, evtTab, trigChan, sysChan = readBDF("res1.bdf", transposeData=true) #return transposed data matrix (i.e. nDataPoints X nChannels)
```

Read the header of a BDF file

##### Args:

* fName: Name of the BDF file to read.

##### Returns:

* `bdfInfo::Dict{ASCIIString,Any}`: dictionary with the following fields:
    * `idCode::ASCIIString`: Identification code
    * `subjID::`ASCIIString`: Local subject identification
    * `recID::ASCIIString`: Local recording identification
    * `startDate::ASCIIString`: Recording start date
    * `startTime::ASCIIString`: Recording start time
    * `nBytes::Int`: Number of bytes occupied by the BDF header
    * `versionDataFormat::ASCIIString`: Version of data format
    * `nDataRecords::Int`: Number of data records "-1" if unknown
    * `recordDuration::FloatingPoint`: Duration of a data record, in seconds
    * `nChannels::Int`: Number of channels in data record
    * `chanLabels::Array{ASCIIString,1}`: Channel labels
    * `transducer::Array{ASCIIString,1}`: Transducer type
    * `physDim::ASCIIString`: Physical dimension of channels
    * `physMin::Array{Int64,1}`: Physical minimum in units of physical dimension
    * `physMax::Array{Int64,1}`: Physical maximum in units of physical dimension
    * `digMin::Array{Int64,1}`: Digital minimum
    * `digMax::Array{Int64,1}`: Digital maximum
    * `prefilt::Array{ASCIIString,1}`: Prefiltering
    * `nSampRec::Array{Int64,1}`: Number of samples in each data record
    * `reserved::Array{ASCIIString,1}`: Reserved
    * `scaleFactor::Array{Float32,1}`: Scaling factor for digital to physical dimension
    * `sampRate::Array{Int64,1}`: Recording sampling rate

##### Examples

```julia
bdfInfo = readBDFHeader("res1.bdf")
sampRate = bdfInfo["sampRate"][1]
```

Write a BDF file

##### Args:
* `fName`: Name of the BDF file to write.
* `data`: The nChannelsXnDataPoints array to be written to the BDF file
* `trigChan`: The triggers to be written to the BDF file (1XnDataPoints)
* `statusChan`: The status channel codes to be written to the BDF file (1XnDataPoints)
* `sampRate`: The sampling rate of the recording
* `subjID`: Subject identifier (80 characters max)
* `recID`: Recording identifier (80 characters max)
* `startDate`: Start date in "dd.mm.yy" format
* `startTime`: Start time in "hh.mm.ss" format
* `versionDataFormat`: Version of data format
* `chanLabels`: Array of channel labels (1 for each channel)
* `transducer`: Array of transducer type (1 for each channel)
* `physDim`: Array of physical dimension of channels (1 for each channel)
* `physMin`: Array of physical minimum in units of physical dimension (1 for each channel)
* `physMax`: Array of physical maximum in units of physical dimension (1 for each channel)
* `prefilt`: Array of prefilter settings (1 for each channel)

#####  Notes:

Only the first five arguments are required. The other arguments are optional and
the corresponding BDF fields will be left empty or filled with defaults arguments.

Data records are written in 1-second units. If the number of data points passed to
`writeBDF` is not an integer multiple of the sampling rate the data array, as well
as the trigger and status channel arrays will be padded with zeros to fill the last
data record before it is written to disk.

##### Examples:

```julia
sampRate = 2048
dats = rand(2, sampRate*10)
trigs = rand(1:255, sampRate*10)
statChan = rand(1:255, sampRate*10)
writeBDF("bdfRec.bdf", dats, trigs, statChan, sampRate)

#add date and time info
writeBDF("bdfRec.bdf", dats, trigs, statChan, sampRate, startDate="23.06.14",
startTime="10.18.19")
```

Split a BDF file at points marked by a trigger into multiple files

##### Args:

* `fName`: Name of the BDF file to split.
* `trigger`: The trigger marking the split points.
* `from`: Start time of data chunk to read (seconds).
* `to`: End time of data chunk to read (seconds).

##### Examples:

```julia
splitBDFAtTrigger("res1.bdf", 202)
```

Split a BDF file at one or more time points into multiple files

##### Args:

* `fName`: Name of the BDF file to split.
* `timeSeconds`: array listing the time(s) at which the BDF file should be split, in seconds.
  This can be either a single number or an array of time points.
* `from`: Start time of data chunk to read (seconds).
* `to`: End time of data chunk to read (seconds).

##### Examples:

```julia
splitBDFAtTime("res1.bdf", 50)
splitBDFAtTime("res2.bdf", [50, 100, 150])
```


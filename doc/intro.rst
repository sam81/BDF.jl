 
************
Introduction
************
:Author: Samuele Carcagno

JBDF is a julia module to read BIOSEMI 24-bit BDF files.


*************************
Download and Installation
*************************

Download
========

The source code of JBDF is hosted on
github: https://github.com/sam81/JBDF

It can be installed through Julia using::

    Pkg.clone("git://github.com/sam81/JBDF.jl.git")

******
Usage
******
Load the module::

    using JBDF

To read an entire BDF recording::

    dats, evtTab, trigChan, sysCodeChan = readBdf("res1.bdf")

``dats`` is the nChannelXnSamples matrix containing the data. Note that the 
triggers are not contained in the ``dats`` matrix. The triggers can be retrieved 
either trough the event table (``evtTab``), or the raw trigger channel (``trigChan``). 
The eventTable is a dictionary containing the trigger codes ``evtTab["code"]``, 
the trigger indexes ``evtTab["idx"]`` (i.e. the sample numbers at which triggers 
occurred in the recording), and the trigger durations ``evtTab["dur"]`` (in seconds). 
The raw trigger channel returned in ``trigChan`` contains the trigger code for each recording sample. 
Additional Biosemi status codes (like cm in/out-of range, battery low/OK) are returned in ``sysCodeChan``.

You can also read only part of a recording, the following code will read the first 10 seconds of the recording::

    dats, evtTab, trigChan, statChan = readBdf("res1.bdf", from=0, to=10) 
    

The ``readBdfHeader`` function can be used to get information on the BDF recording::

    bdfInfo = readBdfHeader("res1.bdf")


Get the duration of the recording::

    bdfInfo["duration"]

Get the sampling rate of each channel::

    bdfInfo["sampRate"]

Get the channel labels::

    bdfInfo["chanLabels"]


Beware that JBDF does not check that you have sufficient RAM to 
read all the data in a BDF file. If you try to read a file that is
too big for your hardware, your system may become slow or unresponsive.
Initially try reading only a small amount of data, and check how much
RAM that uses. 

******
Bugs
******

Please, report any bugs on github https://github.com/sam81/JBDF/issues

Known Issues
============

None

*********
Functions
*********

.. function:: readBdf(fname::String; from::Real=0, to::Real=-1)
   
   Read the data from a BDF file
   
   Args:
       fname: 
          Name of the BDF file to read.
       from: 
          Start time of data chunk to read (seconds)
       to: 
          End time of data chunk to read (seconds).

   Returns:
      dats: Array{Float32, 2}
          nChannels X nDataPoints matrix containing the data
      eventTable: dictionary with three fields
          - code:
            trigger codes
          - idx:
            trigger indexes
          - dur:
            trigger durations
      trigChannel : 
          the raw trigger channel  
      syscodeChannel : 
          the raw system codes channel     
      
   Examples::

          dats, evtTab, trigChan, sysChan = readBdf("res1.bdf")

.. function:: readBdfHeader(fname::String)
   
   Read the headerof a BDF file
   
   Args:
       fname: Name of the BDF file to read.

   Returns:
       bdfInfo: dictionary with the following fields
	   idCode : String
	       Identification code
	   subjId : String
	       Local subject identification
	   recId : String
	       Local recording identification
	   startDate : String
	       Recording start date
	   startTime : String
	       Recording start time
	   nBytes : Int
	       Number of bytes occupied by the BDF header
	   versionDataFormat : String
	       Version of data format
	   nDataRecords : Int
	       Number of data records "-1" if unknown
	   recordDuration : FloatingPoint
	       Duration of a data record, in seconds
	   nChannels : Int
	       Number of channels in data record
	   chanLabels : Array{String,1}
	       Channel labels
	   transducer : Array{String,1}
	       Transducer type
	   physDim : String
	       Physical dimension of channels
	   physMin : Array{Int64,1}
	       Physical minimum in units of physical dimension
	   physMax : Array{Int64,1}
	       Physical maximum in units of physical dimension
	   digMin : Array{Int64,1}
	       Digital minimum
	   digMax : Array{Int64,1}
	       Digital maximum
	   prefilt : Array{String,1}
	       Prefiltering
	   nSampRec : Array{Int64,1}
	       Number of samples in each data record
	   reserved : Array{String,1}
	       Reserved
	   scaleFactor : list of floats
	       Scaling factor for digital to physical dimension
	   sampRate : Array{Int64,1}
	       Recording sampling rate
	   statusChanIdx : Int
	       Index of the status channel
	   nDataChannels : Int
	       Number of data channels containing data (rather than trigger codes)
	   dataChanLabels : Array{String,1}
	       Labels of the channels containing data (rather than trigger codes)

   Examples::
       
     bdfInfo = readBdfHeader("res1.bdf")
     sampRate = bdfInfo["sampRate"][1]

.. function:: writeBdf(fname::String, data, trigChan, statusChan, sampRate; subjID="", recID="", startDate="",  startTime="", versionDataFormat="24BIT", chanLabels=["" for i=1:size(data)[1]], transducer=["" for i=1:size(data)[1]], physDim=["" for i=1:size(data)[1]], physMin=[-262144 for i=1:size(data)[1]], physMax=[262144 for i=1:size(data)[1]], prefilt=["" for i=1:size(data)[1]])
             

   Write a BDF file
   
   Args:
       fname: 
          Name of the BDF file to write.
       data: 
          The nChannelsXnDataPoints array to be written to the BDF file
       trigChan: 
          The triggers to be written to the BDF file (1XnDataPoints)
       statusChan:
          The status channel codes to be written to the BDF file (1XnDataPoints)
       sampRate:
          The sampling rate of the recording
       subjId:
          Subject identifier (80 characters max)
       recId:
          Recording identifier (80 characters max)
       startDate:
          Start date in "dd.mm.yy" format
       startTime:
          Start time in "hh.mm.ss" format
       versionDataFormat:
          Version of data format
       chanLabels:
          Array of channel labels (1 for each channel)
       transducer:
          Array of transducer type (1 for each channel)
       physDim:
          Array of physical dimension of channels (1 for each channel)
       physMin:
          Array of physical minimum in units of physical dimension (1 for each channel)
       physMax:
          Array of physical maximum in units of physical dimension (1 for each channel)
       prefilt:
          Array of prefilter settings (1 for each channel)

   Notes:
      Only the first five arguments are required. The other arguments are optional and
      the corresponding BDF fields will be left empty or filled with defaults arguments.
      
      Data records are written in 1-second units. If the number of data points passed to 
      `writeBdf` is not an integer multiple of the sampling rate the data array, as well 
      as the trigger and status channel arrays will be padded with zeros to fill the last 
      data record before it is written to disk.
      
   Examples::
          
    sampRate = 2048
    dats = rand(2, sampRate*10)
    trigs = rand(1:255, sampRate*10)
    statChan = rand(1:255, sampRate*10)
    writeBdf("bdfRec.bdf", dats, trigs, statChan, sampRate)

    #add date and time info
    writeBdf("bdfRec.bdf", dats, trigs, statChan, sampRate, startDate="23.06.14",
             startTime="10.18.19")


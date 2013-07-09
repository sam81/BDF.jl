 
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

******
Usage
******
Load the module::

    using JBDF

To read an entire BDF recording::

    dats, evtTab, trigChan, sysCodeChan = ("res1.bdf") 

``dats`` is the nChannelXnSamples matrix containing the data. Note that the 
triggers are not contained in the ``dats`` matrix. The triggers can be retrieved 
either trough the event table (``evtTab``), or the raw trigger channel (``trigChan``). 
The eventTable is a dictionary containing the trigger codes ``evtTab["code"]``, 
the trigger indexes ``evtTab["idx"]`` (i.e. the sample numbers at which triggers 
occurred in the recording), and the trigger durations ``evtTab["dur"]`` (in seconds). 
The raw trigger channel returned in ``trigChan`` contains the trigger code for each recording sample. 
Additional Biosemi status codes (like cm in/out-of range, battery low/OK) are returned in ``sysCodeChan``.

You can also read only part of a recording, the following code will read the first 10 seconds of the recording::

    dats, evtTab, trigChan, statChan = ("res1.bdf", from=0, to=10) 
    

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


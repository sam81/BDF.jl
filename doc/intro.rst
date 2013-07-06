 
************
Introduction
************
:Author: Samuele Carcagno

jbdf is a julia module to read BIOSEMI 24-bit BDF files.


*************************
Download and Installation
*************************

Download
========

The source code of jbdf is hosted on
github:

https://github.com/sam81/jbdf


*****
Usage
*****
Load the module::

    using jbdf

To read an entire bdf recording::

    dats, evtTab, trigChan, statusChan = ("res1.bdf") 

``dats`` is the nChannelXnSamples matrix containing the data.``evtTab`` is the eventTable, a dictionary containing the trigger codes ``evtTab["code"]``, the trigger indexes ``evtTab["idx"]``, and the trigger durations ``evtTab["dur"]``. The raw trigger channel is also returned in ``trigChan``. Additional Biosemi status codes (like cm in/out-of range, battery low/OK) are returned in ``statChan``.

You can also read only part of a recording, the following code will read the first 10 seconds of the recording::

    dats, evtTab, trigChan, statChan = ("res1.bdf", from=0, to=10) 
    

The ``readBdfHeader`` function can be used to get information on the bdf recording::

    bdfInfo = readBdfHeader("res1.bdf")


Get the duration of the recording::

    bdfInfo["duration"]

Get the sampling rate of each channel::

    bdfInfo["sampRate"]

Get the channel labels::

    bdfInfo["chanLabels"]


Beware that jybdf does not check that you have sufficient RAM to 
read all the data in a bdf file. If you try to read a file that is
too big for your hardware, you system may become slow or unresponsive.
Initially try reading only a small amount of data, and check how much
RAM that uses. 

*****
Bugs
*****

Please, report any bugs on github https://github.com/sam81/jbdf/issues

Known issues
-------------

None

*********
Functions
*********

.. function:: readBdf(fname::String; from::Real=0, to::Real=-1)
   
   Read the data from a bdf file
   
   Args:
       fname: Name of the bdf file to read.
       
       from: Start time of data chunk to read (seconds)

       to: End time of data chunk to read (seconds)

   Returns:
       dats: Array{Float32, 2}: 
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
          
        
      Examples:

          > dats, evtTab, trigChan, sysChan = readBdf("res1.bdf")

.. function:: readBdfHeader(fname::String)
   
   Read the headerof a bdf file
   
   Args:
       fname: Name of the bdf file to read.

   Returns:
       bdfInfo: dictionary with the following fields
  
	   idCode : str
	       Identification code
	   subjId : str
	       Local subject identification
	   recId : str
	       Local recording identification
	   startDate : str
	       Recording start date
	   startTime : str
	       Recording start time
	   nBytes : int
	       Number of bytes occupied by the bdf header
	   versionDataFormat : str
	       Version of data format
	   nDataRecords : int
	       Number of data records "-1" if unknown
	   recordDuration : float
	       Duration of a data record, in seconds
	   nChannels : int
	       Number of channels in data record
	   chanLabels : list of str
	       Channel labels
	   transducer : list of str
	       Transducer type
	   physDim : str
	       Physical dimension of channels
	   physMin : list of int
	       Physical minimum in units of physical dimension
	   physMax : list of int
	       Physical maximum in units of physical dimension
	   digMin : list of int
	       Digital minimum
	   digMax : list of int
	       Digital maximum
	   prefilt : list of str
	       Prefiltering
	   nSampRec : list of int
	       Number of samples in each data record
	   reserved : list of str
	       Reserved
	   scaleFactor : list of floats
	       Scaling factor for digital to physical dimension
	   sampRate : list of int
	       Recording sampling rate
	   statusChanIdx : int
	       Index of the status channel
	   nDataChannels : int
	       Number of data channels containing data (rather than trigger codes)
	   dataChanLabels : list of str
	       Labels of the channels containing data (rather than trigger codes)


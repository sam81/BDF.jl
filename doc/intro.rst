 
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



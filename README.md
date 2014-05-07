JBDF is a julia module to read BIOSEMI 24-bit BDF files (used for storing electroencephalographic recordings)

Usage:

    bdfHeader = readBdfHeader("res1.bdf") #read the bdf header
    sampRate = bdfHeader["sampRate"][1] #get the sampling rate
    #read the data, the event table, the trigger channel and the status channel
    dats, evtTab, trigs, statusChan = readBdf("res1.bdf")

Documentation is available here:

https://jbdf.readthedocs.org/en/latest/
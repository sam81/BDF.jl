`BDF.jl` is a Julia module to read/write BIOSEMI 24-bit [BDF](http://www.biosemi.com/faq/file_format.htm) files (used for storing electroencephalographic recordings)

Usage:

    bdfHeader = readBDFHeader("res1.bdf") #read the bdf header
    sampRate = bdfHeader["sampRate"][1] #get the sampling rate
    #read the data, the event table, the trigger channel and the status channel
    dats, evtTab, trigs, statusChan = readBDF("res1.bdf")

Documentation is available here:

http://bdfjl.readthedocs.org/en/latest/
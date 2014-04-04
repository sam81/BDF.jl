module JBDF

export readBdf, readBdfHeader

function readBdf(fname::String; from::Real=0, to::Real=-1)
    #fname: file path
    #from: start time in seconds, default is 0
    #to: end time, default is the full duration
    #returns data, trigChan, sysCodeChan, evtTab
 
    fid = open(fname, "r")
    idCodeNonASCII = read(fid, Uint8, 1)
    idCode = ascii(read(fid, Uint8, 7))
    subjID = ascii(read(fid, Uint8, 80))
    recID = ascii(read(fid, Uint8, 80))
    startDate = ascii(read(fid, Uint8, 8))
    startTime = ascii(read(fid, Uint8, 8))
    nBytes = int(ascii(read(fid, Uint8, 8)))
    versionDataFormat = ascii(read(fid, Uint8, 44))
    nDataRecords = int(ascii(read(fid, Uint8, 8)))
    recordDuration = float(ascii(read(fid, Uint8, 8)))
    nChannels = int(ascii(read(fid, Uint8, 4)))
    chanLabels = Array(String, nChannels)
    transducer = Array(String, nChannels)
    physDim = Array(String, nChannels)
    physMin = Array(Int32, nChannels)
    physMax = Array(Int32, nChannels)
    digMin = Array(Int32, nChannels)
    digMax = Array(Int32, nChannels)
    prefilt = Array(String, nChannels)
    nSampRec = Array(Int, nChannels)
    reserved = Array(String, nChannels)
    scaleFactor = Array(Float32, nChannels)
    sampRate = Array(Int, nChannels)

    duration = recordDuration*nDataRecords

    for i=1:nChannels
        chanLabels[i] = strip(ascii(read(fid, Uint8, 16)))
    end

    for i=1:nChannels
        transducer[i] = strip(ascii(read(fid, Uint8, 80)))
    end

    for i=1:nChannels
        physDim[i] = strip(ascii(read(fid, Uint8, 8)))
    end

    for i=1:nChannels
        physMin[i] = int(ascii(read(fid, Uint8, 8)))
    end

    for i=1:nChannels
        physMax[i] = int(ascii(read(fid, Uint8, 8)))
    end

    for i=1:nChannels
        digMin[i] = int(ascii(read(fid, Uint8, 8)))
    end

    for i=1:nChannels
        digMax[i] = int(ascii(read(fid, Uint8, 8)))
    end

    for i=1:nChannels
        prefilt[i] = strip(ascii(read(fid, Uint8, 80)))
    end

    for i=1:nChannels
        nSampRec[i] = int(ascii(read(fid, Uint8, 8)))
    end

    for i=1:nChannels
        reserved[i] = strip(ascii(read(fid, Uint8, 32)))
    end

    for i=1:nChannels
        scaleFactor[i] = float32(physMax[i]-physMin[i])/(digMax[i]-digMin[i])
        sampRate[i] = nSampRec[i]/recordDuration
    end
  
    if to < 1
        to = nDataRecords
    end
    recordsToRead = to - from
    
    data = Array(Int32, ((nChannels-1), (recordsToRead*nSampRec[1])))
    trigChan = Array(Int16, recordsToRead*nSampRec[1])
    sysCodeChan = Array(Int16,  recordsToRead*nSampRec[1])

    startPos = 3*from*nChannels*nSampRec[1]
    skip(fid, startPos)
    x = read(fid, Uint8, 3*recordsToRead*nChannels*nSampRec[1])
    pos = 1
    for n=1:recordsToRead
        for c=1:nChannels
            if chanLabels[c] != "Status"
                for s=1:nSampRec[1]
                    data[c,(n-1)*nSampRec[1]+s] = ((int32(x[pos]) << 8) | (int32(x[pos+1]) << 16) | (int32(x[pos+2]) << 24) )>> 8
                    pos = pos+3
                end
            else
                for s=1:nSampRec[1]
                    trigChan[(n-1)*nSampRec[1]+s] = ((uint16(x[pos])) | (uint16(x[pos+1]) << 8)) & 255
                    sysCodeChan[(n-1)*nSampRec[1]+s] = int16(x[pos+2])
                    pos = pos+3
                end
            end
        end
    end
    data = data*scaleFactor[1]
    close(fid)


    startPoints = vcat(1, find(diff(trigChan) .!= 0).+1)
    stopPoints = vcat(find(diff(trigChan) .!= 0), length(trigChan))
    trigDurs = (stopPoints - startPoints)/sampRate[1]

    evt = trigChan[startPoints]
    evtTab = (String=>Any)["code" => evt,
                           "idx" => startPoints,
                           "dur" => trigDurs
                           ]

    return data, evtTab, trigChan, sysCodeChan

end



function readBdfHeader(fileName::String)
    fid = open(fileName, "r")
    idCodeNonASCII = read(fid, Uint8, 1)
    idCode = ascii(read(fid, Uint8, 7))
    subjID = ascii(read(fid, Uint8, 80))
    recID = ascii(read(fid, Uint8, 80))
    startDate = ascii(read(fid, Uint8, 8))
    startTime = ascii(read(fid, Uint8, 8))
    nBytes = int(ascii(read(fid, Uint8, 8)))
    versionDataFormat = ascii(read(fid, Uint8, 44))
    nDataRecords = int(ascii(read(fid, Uint8, 8)))
    recordDuration = float(ascii(read(fid, Uint8, 8)))
    nChannels = int(ascii(read(fid, Uint8, 4)))
    chanLabels = Array(String, nChannels)
    transducer = Array(String, nChannels)
    physDim = Array(String, nChannels)
    physMin = Array(Int32, nChannels)
    physMax = Array(Int32, nChannels)
    digMin = Array(Int32, nChannels)
    digMax = Array(Int32, nChannels)
    prefilt = Array(String, nChannels)
    nSampRec = Array(Int, nChannels)
    reserved = Array(String, nChannels)
    scaleFactor = Array(Float32, nChannels)
    sampRate = Array(Int, nChannels)

    duration = recordDuration*nDataRecords

    for i=1:nChannels
        chanLabels[i] = strip(ascii(read(fid, Uint8, 16)))
    end

    for i=1:nChannels
        transducer[i] = strip(ascii(read(fid, Uint8, 80)))
    end

    for i=1:nChannels
        physDim[i] = strip(ascii(read(fid, Uint8, 8)))
    end

    for i=1:nChannels
        physMin[i] = int(ascii(read(fid, Uint8, 8)))
    end

    for i=1:nChannels
        physMax[i] = int(ascii(read(fid, Uint8, 8)))
    end

    for i=1:nChannels
        digMin[i] = int(ascii(read(fid, Uint8, 8)))
    end

    for i=1:nChannels
        digMax[i] = int(ascii(read(fid, Uint8, 8)))
    end

    for i=1:nChannels
        prefilt[i] = strip(ascii(read(fid, Uint8, 80)))
    end

    for i=1:nChannels
        nSampRec[i] = int(ascii(read(fid, Uint8, 8)))
    end

    for i=1:nChannels
        reserved[i] = strip(ascii(read(fid, Uint8, 32)))
    end

    for i=1:nChannels
        scaleFactor[i] = float32(physMax[i]-physMin[i])/(digMax[i]-digMin[i])
        sampRate[i] = nSampRec[i]/recordDuration
    end

    close(fid)

    d = (String => Any)["fileName" => fileName,
         "idCodeNonASCII" => idCodeNonASCII,
         "idCode" => idCode,
         "subjID" => subjID,
         "recID"  => recID,
         "startDate" => startDate,
         "startTime" => startTime,
         "nBytes" => nBytes,
         "versionDataFormat" => versionDataFormat,
         "nDataRecords"  => nDataRecords,
         "recordDuration" => recordDuration,
         "nChannels"  => nChannels,
         "chanLabels"  => chanLabels,
         "transducer"  => transducer,
         "physDim"=> physDim,
         "physMin" => physMin,
         "physMax" => physMax,
         "digMin" => digMin,
         "digMax" => digMax,
         "prefilt" => prefilt,
         "nSampRec" => nSampRec,
         "reserved" => reserved,
         "scaleFactor" => scaleFactor,
         "sampRate" => sampRate,
         "duration" => duration,
         ]
    return(d)
    
end

end # module


using Compat
import DSP

@doc doc"""
Read the data from a EDF file. EDF support is experimental (and limited). Currently, only EDF files in which all channels
have the same sampling rate are supported. EDF annotations are not currently supported.

##### Args:

* `fName`: Name of the EDF file to read.
* `from`: Start time of data chunk to read (seconds).
* `to`: End time of data chunk to read (seconds).
* `channels`: Channels to read (indices or channel names).
* `trigChanLabel`: The label of the channel containing triggers (if any). Default is "Status"
* `transposeData`: If `true`, return transposed version of the `dats` array. Default is `false`.

##### Returns:

* `dats::Array{Float32, 2}`: The matrix containing the data, this will be a nChannels X nDataPoints matrix if `transposeData` is `false` (default).
                             If `transposeData` is `true`, however, it will be a nDataPoints X nChannels matrix.
* eventTable: dictionary with three fields
    * code: trigger codes
    * idx: trigger indexes
    * dur: trigger durations
* trigChannel: the raw trigger channel


##### Examples:

```julia
dats, evtTab, trigChan, sysChan = readEDF("res1.edf")
dats, evtTab, trigChan, sysChan = readEDF("res1.edf", channels=[1,3]) #read only channels 1 and 3
dats, evtTab, trigChan, sysChan = readEDF("res1.edf", channels=["Fz","RM"]) #read only channels Fz and RM
dats, evtTab, trigChan, sysChan = readEDF("res1.edf", transposeData=true) #return transposed data matrix (i.e. nDataPoints X nChannels)
```
"""->
function readEDF(fName::AbstractString; from::Real=0, to::Real=-1, channels::AbstractVector=[-1], trigChanLabel="Status", transposeData::Bool=false)

    channels = unique(channels)
    if isa(channels, AbstractVector{ASCIIString})
        edfHeader = readEDFHeader(fName)
        channels = [findfirst(channels, c) for c in edfHeader["chanLabels"]]
        channels = channels[channels .!= 0]
    end

    readEDF(open(fName, "r"), from=from, to=to, channels=channels, trigChanLabel=trigChanLabel, transposeData=transposeData)
end

function readEDF(fid::IO; from::Real=0, to::Real=-1, channels::AbstractVector{Int}=[-1], trigChanLabel="Status", transposeData::Bool=false)

    if isa(fid, IOBuffer)
        fid.ptr = 1
    end

    #idCodeNonASCII = read(fid, UInt8, 1)
    idCode = ascii(read(fid, UInt8, 8))
    subjID = ascii(read(fid, UInt8, 80))
    recID = ascii(read(fid, UInt8, 80))
    startDate = ascii(read(fid, UInt8, 8))
    startTime = ascii(read(fid, UInt8, 8))
    nBytes = parse(Int, ascii(read(fid, UInt8, 8)))
    versionDataFormat = ascii(read(fid, UInt8, 44))
    nDataRecords = parse(Int, ascii(read(fid, UInt8, 8)))
    recordDuration = float(ascii(read(fid, UInt8, 8)))
    nChannels = parse(Int, ascii(read(fid, UInt8, 4)))
    chanLabels = Array(ASCIIString, nChannels)
    transducer = Array(ASCIIString, nChannels)
    physDim = Array(ASCIIString, nChannels)
    physMin = Array(Int32, nChannels)
    physMax = Array(Int32, nChannels)
    digMin = Array(Int32, nChannels)
    digMax = Array(Int32, nChannels)
    prefilt = Array(ASCIIString, nChannels)
    nSampRec = Array(Int, nChannels)
    reserved = Array(ASCIIString, nChannels)
    scaleFactor = Array(Float32, nChannels)
    sampRate = Array(Int, nChannels)

    duration = recordDuration*nDataRecords

    channels = unique(channels)
    if channels == [-1]
        channels = 1:(nChannels-1)
    end
    nKeepChannels = length(channels)

    for i=1:nChannels
        chanLabels[i] = strip(ascii(read(fid, UInt8, 16)))
    end

    for i=1:nChannels
        transducer[i] = strip(ascii(read(fid, UInt8, 80)))
    end

    for i=1:nChannels
        physDim[i] = strip(ascii(read(fid, UInt8, 8)))
    end

    for i=1:nChannels
        physMin[i] = parse(Int, ascii(read(fid, UInt8, 8)))
    end

    for i=1:nChannels
        physMax[i] = parse(Int, ascii(read(fid, UInt8, 8)))
    end

    for i=1:nChannels
        digMin[i] = parse(Int, ascii(read(fid, UInt8, 8)))
    end

    for i=1:nChannels
        digMax[i] = parse(Int, ascii(read(fid, UInt8, 8)))
    end

    for i=1:nChannels
        prefilt[i] = strip(ascii(read(fid, UInt8, 80)))
    end

    for i=1:nChannels
        nSampRec[i] = parse(Int, ascii(read(fid, UInt8, 8)))
    end

    for i=1:nChannels
        reserved[i] = strip(ascii(read(fid, UInt8, 32)))
    end

    for i=1:nChannels
        scaleFactor[i] = Float32(physMax[i]-physMin[i])/(digMax[i]-digMin[i])
        sampRate[i] = nSampRec[i]/recordDuration
    end

    if to < 1
        to = nDataRecords
    end
    recordsToRead = to - from
    if transposeData
        data = Array(Int16, ((recordsToRead*maximum(nSampRec)), (nKeepChannels)))
    else
        data = Array(Int16, ((nKeepChannels), (recordsToRead*maximum(nSampRec))))
    end

    if in(trigChanLabel, chanLabels)
        trigChan = Array(Int16, recordsToRead*nSampRec[1])
    end

    if length(unique(nSampRec)) == 1 #all channels have the same sampling rate
        startPos = 2*from*nChannels*nSampRec[1]
        skip(fid, startPos)
        x = read(fid, Int16, recordsToRead*nChannels*nSampRec[1])
        close(fid)
        pos = 1
        if transposeData
            for n=1:recordsToRead
                for c=1:nChannels
                    cIdx = findfirst(channels, c)
                    if (chanLabels[c] != trigChanLabel) & (cIdx != 0)
                        for s=1:nSampRec[1]
                            data[(n-1)*nSampRec[1]+s,cIdx] = x[pos] 
                            pos = pos+1
                        end
                    elseif chanLabels[c] == trigChanLabel
                        for s=1:nSampRec[1]
                            trigChan[(n-1)*nSampRec[1]+s] = x[pos] & 255 
                            pos = pos+1
                        end
                    else
                        # Channel not selected
                        for s=1:nSampRec[1]
                            pos = pos+1
                        end
                    end
                end
            end
        else
            for n=1:recordsToRead
                for c=1:nChannels
                    cIdx = findfirst(channels, c)
                    if (chanLabels[c] != trigChanLabel) & (cIdx != 0)
                        for s=1:nSampRec[1]
                            data[cIdx,(n-1)*nSampRec[1]+s] = x[pos]
                            pos = pos+1
                        end
                    elseif chanLabels[c] == trigChanLabel
                        for s=1:nSampRec[1]
                            trigChan[(n-1)*nSampRec[1]+s] = x[pos] & 255 
                            pos = pos+1
                        end
                    else
                        # Channel not selected
                        for s=1:nSampRec[1]
                            pos = pos+1
                        end
                    end
                end
            end

        end
    else #channels have different sampling rates
        error("EDF files with channels having different sampling rates are not currently supported")
        startPos = 2*from*sum(nSampRec)
        skip(fid, startPos)
        x = read(fid, Int16, recordsToRead*sum(nSampRec))
        close(fid)
        pos = 1

        chanData = Dict{ASCIIString, AbstractVector{Int16}}()
        for c=1:nChannels
            cIdx = findfirst(channels, c)
            if (chanLabels[c] != trigChanLabel) & (cIdx != 0)
                chanData[chanLabels[c]] = zeros(Int16, recordsToRead*nSampRec[c])
            elseif chanLabels[c] == trigChanLabel
                chanData[trigChanLabel] = zeros(Int16, recordsToRead*nSampRec[c])
            end
        end
            
        if transposeData
            for n=1:recordsToRead
                for c=1:nChannels
                    cIdx = findfirst(channels, c)
                    if (chanLabels[c] != trigChanLabel) & (cIdx != 0)
                        for s=1:nSampRec[c]
                            data[(n-1)*nSampRec[c]+s,cIdx] = x[pos] 
                            pos = pos+1
                        end
                    elseif chanLabels[c] == trigChanLabel
                        for s=1:nSampRec[c]
                            trigChan[(n-1)*nSampRec[c]+s] = x[pos] & 255 
                            pos = pos+1
                        end
                    else
                        # Channel not selected
                        for s=1:nSampRec[c]
                            pos = pos+1
                        end
                    end
                end
            end
        else
            for n=1:recordsToRead
                for c=1:nChannels
                    cIdx = findfirst(channels, c)
                    if (chanLabels[c] != trigChanLabel) & (cIdx != 0)
                        for s=1:nSampRec[c]
                            chanData[chanLabels[c]][(n-1)*nSampRec[c]+s] = x[pos] #data[cIdx,(n-1)*nSampRec[c]+s] = x[pos]
                            pos = pos+1
                        end
                    elseif chanLabels[c] == trigChanLabel
                        for s=1:nSampRec[c]
                            chanData[trigChanLabel][(n-1)*nSampRec[c]+s] = x[pos] & 255 #trigChan[(n-1)*nSampRec[c]+s] = x[pos] & 255 
                            pos = pos+1
                        end
                    else
                        # Channel not selected
                        for s=1:nSampRec[c]
                            pos = pos+1
                        end
                    end
                end
            end
        end

        if transposeData
            for c=1:nChannels
                cIdx = findfirst(channels, c)
                if (chanLabels[c] != trigChanLabel) & (cIdx != 0)
                    if sampRate[c] != maximum(sampRate)
                        data[:,cIdx] = DSP.resample(chanData[chanLabels[c]], maximum(sampRate)/sampRate[c])
                    else
                        data[:,cIdx] = chanData[chanLabels[c]]
                    end
                elseif chanLabels[c] == trigChanLabel
                    if sampRate[c] != maximum(sampRate)
                        trigChan = DSP.resample(chanData[chanLabels[c]], maximum(sampRate)/sampRate[c])
                    else
                        trigChan = chanData[chanLabels[c]]
                    end
                end
            end
        else
            for c=1:nChannels
                cIdx = findfirst(channels, c)
                if (chanLabels[c] != trigChanLabel) & (cIdx != 0)
                    if sampRate[c] != maximum(sampRate)
                        data[cIdx,:] = DSP.resample(chanData[chanLabels[c]], maximum(sampRate)/sampRate[c])
                    else
                        data[cIdx,:] = chanData[chanLabels[c]]
                    end
                elseif chanLabels[c] == trigChanLabel
                    if sampRate[c] != maximum(sampRate)
                        trigChan = DSP.resample(chanData[chanLabels[c]], maximum(sampRate)/sampRate[c])
                    else
                        trigChan = chanData[chanLabels[c]]
                    end
                end
            end
        end
    end

    data = map(Float32, data)
    if transposeData
        for ch=1:size(data, 2)
            data[:,ch] = data[:,ch]*scaleFactor[ch]
        end
    else
        for ch=1:size(data, 1)
            data[ch,:] = data[ch,:]*scaleFactor[ch]
        end
    end
        
    if in(trigChanLabel, chanLabels) #EDF includes a triggers channel
        startPoints = vcat(1, find(diff(trigChan) .!= 0).+1)
        stopPoints = vcat(find(diff(trigChan) .!= 0), length(trigChan))
        trigDurs = (stopPoints - startPoints)/sampRate[1]

        evt = trigChan[startPoints]
        evtTab = @compat Dict{ASCIIString,Any}("code" => evt,
                                               "idx" => startPoints,
                                               "dur" => trigDurs
                                               )
    else #triggers channel not in EDF file, initialize empty data structures so that return types are always the same
        trigChan = (Int16)[]
        evtTab = @compat Dict{ASCIIString,Any}("code" => (Int)[],
                                               "idx" => (Int)[],
                                               "dur" => (Float64)[]
                                               )
    end
             

    return data, evtTab, trigChan

end

@doc doc"""
Read the header of an EDF file.

##### Args:

* fName: Name of the EDF file to read.

##### Returns:

* `edfInfo::Dict{ASCIIString,Any}`: dictionary with the following fields:
    * `idCode::ASCIIString`: Identification code
    * `subjID::`ASCIIString`: Local subject identification
    * `recID::ASCIIString`: Local recording identification
    * `startDate::ASCIIString`: Recording start date
    * `startTime::ASCIIString`: Recording start time
    * `nBytes::Int`: Number of bytes occupied by the EDF header
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
edfInfo = readEDFHeader("res1.edf")
sampRate = edfInfo["sampRate"][1]
```
"""->

function readEDFHeader(fName::AbstractString)

    readEDFHeader(open(fName, "r"), fName=fName)
end


function readEDFHeader(fid::IO; fName::AbstractString="")

    if isa(fid, IOBuffer)
        fid.ptr = 1
    end

    #idCodeNonASCII = read(fid, UInt8, 1)
    idCode = ascii(read(fid, UInt8, 8))
    subjID = ascii(read(fid, UInt8, 80))
    recID = ascii(read(fid, UInt8, 80))
    startDate = ascii(read(fid, UInt8, 8))
    startTime = ascii(read(fid, UInt8, 8))
    nBytes = parse(Int, ascii(read(fid, UInt8, 8)))
    versionDataFormat = ascii(read(fid, UInt8, 44))
    nDataRecords = parse(Int, ascii(read(fid, UInt8, 8)))
    recordDuration = float(ascii(read(fid, UInt8, 8)))
    nChannels = parse(Int, ascii(read(fid, UInt8, 4)))
    chanLabels = Array(ASCIIString, nChannels)
    transducer = Array(ASCIIString, nChannels)
    physDim = Array(ASCIIString, nChannels)
    physMin = Array(Int32, nChannels)
    physMax = Array(Int32, nChannels)
    digMin = Array(Int32, nChannels)
    digMax = Array(Int32, nChannels)
    prefilt = Array(ASCIIString, nChannels)
    nSampRec = Array(Int, nChannels)
    reserved = Array(ASCIIString, nChannels)
    scaleFactor = Array(Float32, nChannels)
    sampRate = Array(Int, nChannels)

    duration = recordDuration*nDataRecords

    for i=1:nChannels
        chanLabels[i] = strip(ascii(read(fid, UInt8, 16)))
    end

    for i=1:nChannels
        transducer[i] = strip(ascii(read(fid, UInt8, 80)))
    end

    for i=1:nChannels
        physDim[i] = strip(ascii(read(fid, UInt8, 8)))
    end

    for i=1:nChannels
        physMin[i] = parse(Int, ascii(read(fid, UInt8, 8)))
    end

    for i=1:nChannels
        physMax[i] = parse(Int, ascii(read(fid, UInt8, 8)))
    end

    for i=1:nChannels
        digMin[i] = parse(Int, ascii(read(fid, UInt8, 8)))
    end

    for i=1:nChannels
        digMax[i] = parse(Int, ascii(read(fid, UInt8, 8)))
    end

    for i=1:nChannels
        prefilt[i] = strip(ascii(read(fid, UInt8, 80)))
    end

    for i=1:nChannels
        nSampRec[i] = parse(Int, ascii(read(fid, UInt8, 8)))
    end

    for i=1:nChannels
        reserved[i] = strip(ascii(read(fid, UInt8, 32)))
    end

    for i=1:nChannels
        scaleFactor[i] = Float32(physMax[i]-physMin[i])/(digMax[i]-digMin[i])
        sampRate[i] = nSampRec[i]/recordDuration
    end

    close(fid)

    d = @compat Dict{ASCIIString,Any}("fileName" => fName,
                                 #"idCodeNonASCII" => idCodeNonASCII,
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
                                 )
    return(d)

end




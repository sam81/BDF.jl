using BDF, Base.Test, HDF5
#using JLD

origFilePath = "Newtest17-256.bdf"
bdfHeader = readBDFHeader(origFilePath)
dats, evtTab, trigs, statusChan = readBDF(origFilePath)

## testData=load("test_data.jld")

## @test isequal(testData["bdfHeader"], bdfHeader)
## @test isequal(testData["EEG"], dats)
## @test isequal(testData["evtTab"], evtTab)
## @test isequal(testData["trigs"], trigs)

testData = h5read("Newtest17-256_data.h5", "data")
@test isequal(testData["EEG"], dats)
@test isequal(testData["trigs"], trigs)
@test isequal(testData["idx"], evtTab["idx"])
@test isequal(testData["dur"], evtTab["dur"])
@test isequal(testData["code"], evtTab["code"])

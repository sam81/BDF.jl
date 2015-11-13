using BDF, Base.Test

origFilePath = joinpath(dirname(@__FILE__), "Newtest17-256.bdf")
tmpFilePath1 = joinpath(dirname(@__FILE__), "Newtest17-256_1.bdf")
tmpFilePath2 = joinpath(dirname(@__FILE__), "Newtest17-256_2.bdf")
tmpFilePath3 = joinpath(dirname(@__FILE__), "Newtest17-256_3.bdf")

splitBDFAtTime(origFilePath, 30, newDateTime = false)

splitBDFAtTime(origFilePath, [10, 30], newDateTime = false)

splitBDFAtTrigger(origFilePath, 200, newDateTime = false)

rm(tmpFilePath1)
rm(tmpFilePath2)
rm(tmpFilePath3)

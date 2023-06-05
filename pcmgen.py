import wave
import sys
import struct
import numpy as np
import math

def writeBin(inData, banks):
    for i in range(banks):
        with open(f"bank{i+1}.bin", "wb") as f:
            print(f"writing from {i * 16384} to {(i+1) * 16384} to bank{i+1}.bin")
            f.write(bytearray(inData[i * 16384:(i + 1) * 16384]))

def writeWav(inData, inSampFreq, inFileName):
    data = struct.pack("h" * len(inData), *inData)
    wf = wave.open(inFileName, "w")
    wf.setnchannels(1)
    wf.setsampwidth(2)
    wf.setframerate(inSampFreq)
    wf.writeframes(data)
    wf.close()

def readWav(inFileName):

    wr = wave.open(inFileName, "rb")

    if wr.getsampwidth() != 2:
        print(" error : size per one sample must be 2.")
        wr.close()
        usage()
        quit()

    if wr.getcomptype() != "NONE":
        print (" error : input file must be uncompresed format.")
        wr.close()
        usage()
        quit()

    channels = wr.getnchannels()
    if channels != 1  and channels != 2 :
        print (" error : channel number must be 1 or 2.")
        wr.close()
        usage()
        quit()


    sampFreq = wr.getframerate()
    data = wr.readframes(wr.getnframes())
    numData = np.frombuffer(data, dtype=np.int16)
    wr.close()


    i=0
    out = []
    while i<len(numData):
        out.append(int(np.float64(numData[i]).item()))

        i += channels

    return [out, sampFreq]

def convPcm(inData, inSampFreq, inRegId):

    dpcmFreq = 8192
    print(" PCM-converting sampling frequency[Hz]:", dpcmFreq)

    totalTime = float(len(inData)) / inSampFreq
    
    t = 0.0

    prev = 0.0

    odd = False

    out = []

    while t < totalTime:

        sample = inData[int(math.floor(t * inSampFreq))]

        val = sample >> 10

        # 圧縮後サンプル値が範囲を出ていれば、範囲内に収める
        # 範囲は、-8〜7 (4 bitの符号付き整数)
        # -16~15
        if val > 7:
            val = 7
        elif val < -8:
            val = -8
        
        val += 8

        if (odd):
            out.append((prev << 4) + (val))
            odd = False
        else:
            prev = val
            odd = True

        t += 1.0 / dpcmFreq

    wav = []

    for s in out:
        wav.append((s // 16 - 8) << 12)
        wav.append((s % 16 - 8) << 12)

    return [out, wav, dpcmFreq]

# usage
def usage():
    print("?")

if __name__ == "__main__" :

    if len(sys.argv) < 3:
        print (" error : less args.")
        usage()
        quit()
    
    inFileName = sys.argv[1]
    outFileName = sys.argv[2]

    dpcmFlag = 15
    i=3
    while i<len(sys.argv):
        if sys.argv[i] == '-ds':
            i+=1
            if i>=len(sys.argv):
                print (" error : invalid args.")
                usage()
                quit()
            if not sys.argv[i].isdigit():
                print (" error : invalid args.")
                usage()
                quit()
            dpcmFlag = int(sys.argv[i])
        else:
            print(" error : invalid args.")
            usage()
            quit()
        i+=1
        
    [data, sampFreq] = readWav(inFileName)

    print (" input file:", inFileName)
    print (" output file:", outFileName)
    print (" input sampling frequency [Hz]:", sampFreq)
    print (" speech length [s]:", float(len(data)) / sampFreq)

    [out, wav, dpcmFreq] = convPcm(data, sampFreq, dpcmFlag)

    print(f"out size is {hex(len(out))}")
    bank = math.ceil(len(out) / 16384)
    print(f"{bank} banks are required")

    outSampFreq = round(dpcmFreq)
    print (" output sampling frequency[Hz]:", outSampFreq)

    writeBin(out, bank)

    writeWav(wav, outSampFreq, "sample.wav")

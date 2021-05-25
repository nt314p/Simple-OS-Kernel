filename = "font8x13.txt"

with open(filename) as f:
    content = f.read().splitlines()

data = []

for line in content:
    charBytes = line.split(',')
    charData = []
    for charByte in charBytes:
        charData.insert(0, bytes.fromhex(charByte))
    data += charData

with open('font8x13.bin', 'wb') as f:
    for charByte in data:
        f.write(charByte)

    f.close()


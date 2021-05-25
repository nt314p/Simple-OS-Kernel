filename = "palette.txt"

palette = []

with open(filename) as f:
    content = f.read().splitlines()

for line in content: # generate palette
    line = line.replace("\"", "")
    line = line.replace("#", "")
    if (len(line) == 3):
        line = line[0] * 2 + line[1] * 2 + line[2] * 2  # convert to 6 char hex value

    rgb = []
    for i in range(3):
        rgb.append(int(line[i*2:i*2+2], 16))

    palette.append(rgb)

from PIL import Image
im = Image.open('sub.jpg', 'r')
width, height = im.size
pixel_values = list(im.getdata())

converted = []
n = 0
for (r, g, b) in pixel_values:
    bestIndex = -1
    bestError = 10000000000000000
    for i in range(len(palette)):
        color = palette[i]
        dr = abs(r - color[0])
        dg = abs(g - color[1])
        db = abs(b - color[2])
        error = dr + dg + db
        if (error < bestError):
            bestIndex = i
            bestError = error

    hexVal = hex(bestIndex)
    hexVal = hexVal[2:].rjust(2, '0')
    #print(hexVal, end="")
    converted.append(hexVal)

with open('sub.bin', 'wb') as f:
    for val in converted:
        f.write(bytearray.fromhex(val))
    f.close()
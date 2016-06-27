from mapnik import *

import sys

mapfile = sys.argv[1]
output = sys.argv[2]

width = 3307
height = 4724

m = Map(width, height)
load_map(m, mapfile)

im = Image(width,height)

m.zoom_all()
render(m, im, 3)

im.save(output)

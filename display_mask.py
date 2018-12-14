from mpl_toolkits.basemap import Basemap
import matplotlib.pyplot as plt
import matplotlib.image as mpimg
from read_gsfc_mask import read_gsfc_mask
import numpy as np


def display_mask(file):
    # On the Mac terminal you may need to use the TkAgg framework
    # or run pythonw to avoid crashes with matplotlib windows.
    # import matplotlib
    # matplotlib.use("TkAgg")


    plt.figure(figsize=(10, 10))

    # setup north polar stereographic basemap.
    # The longitude lon_0 is at 6-o'clock, and the
    # latitude circle boundinglat is tangent to the edge
    # of the map at lon_0. Default value of lat_ts
    # (latitude of true scale) is pole.
    m = Basemap(projection='npstere', boundinglat=10, lon_0=-45,
                rsphere=[6378273, 6356889.449],
                lat_ts=70, resolution='l')
    print(m.llcrnrx)
    print(m.proj4string)
    m.drawcoastlines(linewidth=0.5)
    # m.fillcontinents(color='coral', lake_color='aqua')
    # draw parallels and meridians.
    m.drawparallels(np.arange(-80., 81., 20.))
    m.drawmeridians(np.arange(-180., 181., 20.))
    m.drawmapboundary()

    data, extent = read_gsfc_mask(file)
    im = plt.imshow(data, extent=extent)

    plt.show()

if __name__ == "__main__":
    display_mask("masks/gsfc_12n.msk")

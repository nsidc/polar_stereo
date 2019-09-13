import cartopy.crs as ccrs
import matplotlib.pyplot as plt
import matplotlib.path as mpath
from read_mask import read_mask
from read_mask_hdf import read_mask_hdf
import numpy as np


def display_mask(file):
    """Read in and display a Polar Stereographic mask file.

    Args:
        file (string): full path to a Polar Stereographic mask file

    Examples:
        display_mask("masks/pole_n.msk")
    """

    # On the Mac terminal you may need to use the TkAgg framework
    # or run pythonw to avoid crashes with matplotlib windows.
    # import matplotlib
    # matplotlib.use("TkAgg")

    if file.endswith('hdf'):
        data, extent, hemisphere = read_mask_hdf(file)
    else:
        data, extent, hemisphere = read_mask(file)

    print(file + " shape=" + str(data.shape) + ", min=" + \
        str(np.min(data)) + ", max=" + str(np.max(data)))

    if hemisphere == 1:
        clat = 90
        clon = -45
        ts_lat = 70
        ext = [30, 90]
    else:
        clat = -90
        clon = 0
        ts_lat = -70
        ext = [-90, -30]

    plt.figure(figsize=(10, 10))

    proj = ccrs.Stereographic(central_longitude=clon, central_latitude=clat,
        globe=ccrs.Globe(semimajor_axis=6378273, semiminor_axis=6356889.449),
        true_scale_latitude=ts_lat)
    ax = plt.axes(projection=proj)
    ax.coastlines()
    grid = ax.gridlines()
    grid.n_steps = 360
    ax.set_extent([-180, 180 + clon, ext[0], ext[1]], ccrs.PlateCarree())
    theta = np.linspace(0, 2 * np.pi, 100)
    center, radius = [0.5, 0.5], 0.5
    verts = np.vstack([np.sin(theta), np.cos(theta)]).T
    circle = mpath.Path(verts * radius + center)
    ax.set_boundary(circle, transform=ax.transAxes)

    plt.imshow(data, extent=extent)
    # plt.colorbar(im, orientation='horizontal', fraction=.1)
    plt.title(file)
    plt.show()


if __name__ == "__main__":
    if True:
        display_mask("masks/amsr_nic_6s.hdf")
        display_mask("masks/amsr_nic_12s.hdf")
        display_mask("masks/amsr_nic_25s.hdf")
        display_mask("masks/amsr_gsfc_6n.hdf")
        display_mask("masks/amsr_gsfc_6s.hdf")
        display_mask("masks/amsr_gsfc_12n.hdf")
        display_mask("masks/amsr_gsfc_12s.hdf")
        display_mask("masks/amsr_gsfc_25n.hdf")
        display_mask("masks/amsr_gsfc_25s.hdf")
    if False:
        display_mask("masks/amsr_gsfc_6n.hdf")
        display_mask("masks/amsr_gsfc_6s.hdf")
        display_mask("masks/amsr_gsfc_12n.hdf")
        display_mask("masks/amsr_gsfc_12s.hdf")
        display_mask("masks/amsr_gsfc_25n.hdf")
        display_mask("masks/amsr_gsfc_25s.hdf")
        display_mask("masks/landmask.ntb")
        display_mask("masks/landmask.stb")
        display_mask("masks/gsfc_12n.msk")
        display_mask("masks/gsfc_12s.msk")
        display_mask("masks/gsfc_25n.msk")
        display_mask("masks/gsfc_25s.msk")
        display_mask("masks/gsfc_pole_hole.N17")
        display_mask("masks/coast_12n.msk")
        display_mask("masks/coast_12s.msk")
        display_mask("masks/ltln_12n.msk")
        display_mask("masks/ltln_12s.msk")
        display_mask("masks/ltln_25n.msk")
        display_mask("masks/ltln_25s.msk")
        display_mask("masks/pole_n.msk")
        display_mask("masks/region_n.msk")
        display_mask("masks/region_s.msk")

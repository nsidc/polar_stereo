import numpy as np


def read_mask(file):
    """Read in a Polar Stereographic mask file.

    Args:
        file (string): full path to a Polar Stereographic mask file

    Returns:
        A tuple containing data, extent, hemisphere
        data: a two-dimensional numpy array, nrows x ncolumns
        extent: A tuple containing (lonmin, lonmax, latmin, latmax) in km
        hemisphere: 1 for Northern, -1 for Southern

    Examples:
        data, extent, hemisphere = read_mask("masks/pole_n.msk")
    """

    dtype = np.uint8

    # Python is in row-major order so the vertical dimension comes first
    if "12n" in file:
        hemisphere = 1
        dims = 896, 608
        extent = (-3850000, 3750000,
                  -5350000, 5850000)
    if "12s" in file:
        hemisphere = -1
        dims = 664, 632
        extent = (-3950000, 3950000,
                  -3950000, 4350000)
    if "25n" in file or "pole_n" in file or \
            "region_n" in file or "N17" in file:
        hemisphere = 1
        dims = 448, 304
        extent = (-3850000, 3750000,
                  -5350000, 5850000)
    if "25s" in file or "region_s" in file:
        hemisphere = -1
        dims = 332, 316
        extent = (-3950000, 3950000,
                  -3950000, 4350000)
    if "ntb" in file:
        hemisphere = 1
        dtype = np.uint16
        dims = 448, 304
        extent = (-3850000, 3750000,
                  -5350000, 5850000)
    if "stb" in file:
        hemisphere = -1
        dtype = np.uint16
        dims = 332, 316
        extent = (-3950000, 3950000,
                  -3950000, 4350000)

    if "region" in file:
        # the "region" files have a 300-byte header that we need to skip over
        dt_header = ('header', np.uint8, 300)
        dt_data = ('data', np.uint8, dims[0] * dims[1])
        dt = np.dtype([dt_header, dt_data])
        data = np.fromfile(file, dtype=dt)
        data = np.reshape(data['data'], dims)
    else:
        data = np.fromfile(file, dtype=dtype, count=dims[0] * dims[1])
        data = np.reshape(data, dims)
    return data, extent, hemisphere

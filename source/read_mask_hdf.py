from pyhdf.SD import SD


def read_mask_hdf(file):
    """Read in a Polar Stereographic mask from an HDF4 file.

    Args:
        file (string): full path to an HDF4 Polar Stereographic mask file

    Returns:
        A tuple containing data, extent, hemisphere
        data: a two-dimensional numpy array, nrows x ncolumns
        extent: A tuple containing (lonmin, lonmax, latmin, latmax) in km
        hemisphere: 1 for Northern, -1 for Southern

    Examples:
        data, extent, hemisphere = read_mask_hdf("masks/amsr_gsfc_25n.hdf")
    """

    # Python is in row-major order so the vertical dimension comes first
    if "6n" in file or "12n" in file or "25n" in file:
        hemisphere = 1
        extent = (-3850000, 3750000,
                  -5350000, 5850000)
    if "6s" in file or "12s" in file or "25s" in file:
        hemisphere = -1
        extent = (-3950000, 3950000,
                  -3950000, 4350000)

    hdfFile = SD(file)

    if "_nic_" in file:
        if "6s" in file:
            datasetName = 'amsr_nic_6s_6250_band1'
        if "12s" in file:
            datasetName = 'amsr_nic_12s_12500_band1'
        if "25s" in file:
            datasetName = 'amsr_nic_25s_25000_band1'
    else:
        datasetName = 'landmask'

    dataset = hdfFile.select(datasetName)
    data = dataset.get()

    return data, extent, hemisphere

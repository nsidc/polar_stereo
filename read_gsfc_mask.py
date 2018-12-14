import numpy as np


def read_gsfc_mask(file):
    # Python is in row-major order so the vertical dimension comes first
    if file.endswith('gsfc_12n.msk'):
        dims = 896, 608
        extent = (-3850000 + 3850000, 3750000 + 3850000,
                  -5350000 + 5350000, 5850000 + 5350000)

    data = np.fromfile(file, dtype=np.uint8, count=dims[0]*dims[1])
    data = np.reshape(data, dims)
    return data, extent

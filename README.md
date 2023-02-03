# tform-calib-grid.m

Octave script to create and transform an idealised grid that matches the actual (distorted) calibration records. The transformation is calculated using manually selected calibration points (markers) on the actual calibration records. The transformed idealised grid is written to disk and can be used to apply automatic marker detection algorithms (e.g. if the actual recordings are of too low quality for automatic detection). 

Tested with Octave 7.3.0 (x86_64, 6.1.7-arch1-1).

## License

BSD 3-clause, see [LICENSE](LICENSE.md) for more information.

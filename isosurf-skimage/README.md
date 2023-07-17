# `isosurf-skimage`

Isosurface calculation with scikit-image example.

## About

The isosurfaces are computed using `skimage.measure.marching_cubes`
and are visualized using three different ways:

- `matplotlib.pyplot.plot_trisurf`
- `mpl_toolkits.mplot3d.art3d.Poly3DCollection`
- `plotly.graph_objects.Figure`

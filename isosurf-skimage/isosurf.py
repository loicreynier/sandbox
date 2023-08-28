"""Plot isosurfaces calculated with marching cubes algorithm."""

import numpy as np
import skimage
import matplotlib.pyplot as plt

CMAP_NAME = "inferno"
N = 16

x, y, z = (
    np.pi * np.mgrid[-1 : 1 : N * 1.0j, -1 : 1 : N * 1.0j, -1 : 1 : N * 1.0j]
)
f = np.cos(x) + np.cos(y) + np.cos(z)
verts, faces, normals, values = skimage.measure.marching_cubes(f)

# Plotting with Matplotlib's `plot_trisurf`
fig, ax = plt.subplots(subplot_kw={"projection": "3d"})
ax.set_axis_off()
ax.plot_trisurf(
    verts[:, 0],
    verts[:, 1],
    verts[:, 2],
    triangles=faces,
    cmap=CMAP_NAME,
)

# -- editorconfig-checker-disable
# Plotting with Matplolib `Poly3DCollection` API
# Source (scikit-image doc):
# https://scikit-image.org/docs/stable/auto_examples/edges/plot_marching_cubes.html
# from mpl_toolkits.mplot3d.art3d import Poly3DCollection
# cmap = mpl.cm.get_cmap(CMAP_NAME)
# mesh = Poly3DCollection(verts[faces])
# mesh.set_facecolor(cmap(values))
# ax.add_collection3d(mesh)
# ax.set_xlim(0, N)
# ax.set_ylim(0, N)
# ax.set_zlim(0, N)

# Saving the plot with tikzplotlib
# import tikzplotlib
# fig.draw_without_rendering()
# Source:
# https://github.com/matplotlib/matplotlib/issues/4067#issuecomment-1172998772
# tikzplotlib.save("fig.tex")

plt.show()

# Plotting with Plotly
# Sources:
# https://plotly.com/python/3d-mesh/#intensity-values-defined-on-vertices-or-cells
# https://stackoverflow.com/questions/61822942
# https://chart-studio.plotly.com/~empet/14613.embed
# -- editorconfig-checker-enable
# import plotly.graph_objects as go
# x, y, z = verts.T
# i, j, k = faces.T
# fig = go.Figure(
#     data=(
#         go.Mesh3d(
#             x=x,
#             y=y,
#             z=z,
#             i=i,
#             j=j,
#             k=k,
#             colorscale=CMAP_NAME,
#             intensity=z,
#         )
#     )
# )
# fig.show()

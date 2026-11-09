# Renders the app icon art from the logo in assets/icon/icon.png.
# Run: ./tools/blender/app/blender.exe -b --factory-startup --python tools/icon/render_icon_art.py
# Colors follow the theme of p2g-it.de. The logo stays untouched.
import math
from pathlib import Path

import addon_utils
import bpy
import numpy as np
from mathutils import Vector

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / 'assets' / 'icon' / 'icon.png'
OUTPUT = ROOT / 'assets' / 'icon' / 'app_icon.png'

PRIMARY = '#5B84C3'  # Brand color of p2g-it, from icon.png
# The light darkens the field; this base color renders as PRIMARY.
FIELD = '#669AE7'
PALE_BLUE = '#9DAFCC'
DEEP_BLUE = '#43608F'
NIGHT_BLUE = '#262D38'
LIGHT = '#F7F9FA'

FRAME = 2.0
COLUMNS = 6
HALF = 20.0
POINT_WIDTH = 2 * HALF / COLUMNS
# Five checkers fill a point. Smaller checkers make shorter points and leave
# more of the brand color in the middle.
CHECKER_SCALE = 0.9
POINT_LENGTH = (HALF - 1.5) * CHECKER_SCALE
STACK = 5
PITCH = POINT_LENGTH / STACK
CHECKER_RADIUS = PITCH / 2 - 0.05
CHECKER_HEIGHT = 0.7 * CHECKER_SCALE
# 8 % smaller than in version 1.0, so that the logo leaves more board around it.
LOGO_WIDTH = 27.6
LOGO_LIFT = 1.0
SHADOW_OFFSET = (0.9, -1.0)
SHADOW_BLUR = 14
SHADOW_STRENGTH = 0.75


def rgba(hex_color):
    value = hex_color.lstrip('#')
    channels = [int(value[i:i + 2], 16) / 255 for i in (0, 2, 4)]
    linear = [c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4
              for c in channels]
    return (*linear, 1)


def material(name, color, roughness):
    result = bpy.data.materials.new(name)
    result.use_nodes = True
    node = result.node_tree.nodes['Principled BSDF']
    node.inputs['Base Color'].default_value = rgba(color)
    node.inputs['Roughness'].default_value = roughness
    return result


def link(mesh, name, mat):
    mesh.materials.append(mat)
    obj = bpy.data.objects.new(name, mesh)
    bpy.context.scene.collection.objects.link(obj)
    return obj


def flat(name, vertices, mat):
    mesh = bpy.data.meshes.new(name)
    mesh.from_pydata(vertices, [], [tuple(range(len(vertices)))])
    if mesh.polygons[0].normal.z < 0:
        mesh.polygons[0].flip()
    return link(mesh, name, mat)


def checker(x, y, mat):
    r = CHECKER_RADIUS
    h = CHECKER_HEIGHT
    profile = [(0.001, 0), (r - 0.08, 0), (r, 0.08), (r, h - 0.12),
               (r - 0.05, h - 0.03), (r - 0.14, h), (r - 0.3, h),
               (r - 0.38, h - 0.08), (0.001, h - 0.08)]
    segments = 128
    vertices = []
    for step in range(segments):
        angle = 2 * math.pi * step / segments
        vertices += [(a * math.cos(angle), a * math.sin(angle), b)
                     for a, b in profile]
    rows = len(profile)
    faces = []
    for step in range(segments):
        following = (step + 1) % segments
        for row in range(rows - 1):
            faces.append((step * rows + row, following * rows + row,
                          following * rows + row + 1, step * rows + row + 1))
    mesh = bpy.data.meshes.new('checker')
    mesh.from_pydata(vertices, [], faces)
    for polygon in mesh.polygons:
        polygon.use_smooth = True
    link(mesh, 'checker', mat).location = (x, y, 0)


def logo_mask():
    source = bpy.data.images.load(str(SOURCE))
    width, height = source.size
    pixels = np.array(source.pixels[:], dtype=np.float32).reshape(height, width, 4)
    blue = pixels[int(height * 0.9), width // 2, 0]
    y, x = np.mgrid[0:height, 0:width]
    radius = np.hypot(x - width / 2, y - height / 2)
    mask = np.clip((pixels[..., 0] - blue) / (1 - blue), 0, 1)
    mask = mask * (radius < width * 0.48) * pixels[..., 3]
    rows = np.where(mask.max(axis=1) > 0.5)[0]
    columns = np.where(mask.max(axis=0) > 0.5)[0]
    cropped = mask[rows[0]:rows[-1] + 1, columns[0]:columns[-1] + 1]
    side = max(cropped.shape)
    top = (side - cropped.shape[0]) // 2
    left = (side - cropped.shape[1]) // 2
    square = np.zeros((side, side), dtype=np.float32)
    square[top:top + cropped.shape[0], left:left + cropped.shape[1]] = cropped
    return square


def blurred(mask):
    """Soft copy of the mask made from three box blurs."""
    result = mask
    for _ in range(3):
        for axis in (0, 1):
            total = np.cumsum(result, axis=axis)
            size = 2 * SHADOW_BLUR + 1
            result = (np.roll(total, -SHADOW_BLUR, axis=axis)
                      - np.roll(total, SHADOW_BLUR + 1, axis=axis)) / size
            result = np.clip(result, 0, 1)
    return result


def image_from_mask(name, mask):
    side = mask.shape[0]
    rgba_pixels = np.ones((side, side, 4), dtype=np.float32)
    rgba_pixels[..., 3] = mask
    image = bpy.data.images.new(name, side, side, alpha=True)
    image.pixels.foreach_set(rgba_pixels.ravel())
    image.pack()
    return image


def logo_plane(name, image, z, offset, surface, strength=1.0):
    size = LOGO_WIDTH / 2
    x, y = offset
    mesh = bpy.data.meshes.new(name)
    mesh.from_pydata([(x - size, y - size, z), (x + size, y - size, z),
                      (x + size, y + size, z), (x - size, y + size, z)], [],
                     [(0, 1, 2, 3)])
    uv = mesh.uv_layers.new(name='uv')
    for index, value in enumerate([(0, 0), (1, 0), (1, 1), (0, 1)]):
        uv.data[index].uv = value

    mat = bpy.data.materials.new(name)
    mat.use_nodes = True
    tree = mat.node_tree
    tree.nodes.clear()
    output = tree.nodes.new('ShaderNodeOutputMaterial')
    mix = tree.nodes.new('ShaderNodeMixShader')
    clear = tree.nodes.new('ShaderNodeBsdfTransparent')
    paint = surface(tree)
    texture = tree.nodes.new('ShaderNodeTexImage')
    texture.image = image
    factor = tree.nodes.new('ShaderNodeMath')
    factor.operation = 'MULTIPLY'
    factor.inputs[1].default_value = strength
    tree.links.new(texture.outputs['Alpha'], factor.inputs[0])
    tree.links.new(factor.outputs[0], mix.inputs[0])
    tree.links.new(clear.outputs[0], mix.inputs[1])
    tree.links.new(paint.outputs[0], mix.inputs[2])
    tree.links.new(mix.outputs[0], output.inputs['Surface'])
    obj = link(mesh, name, mat)
    obj.visible_shadow = False
    return obj


def white_surface(tree):
    paint = tree.nodes.new('ShaderNodeBsdfPrincipled')
    paint.inputs['Base Color'].default_value = (1, 1, 1, 1)
    paint.inputs['Roughness'].default_value = 0.6
    paint.inputs['Emission Color'].default_value = (1, 1, 1, 1)
    paint.inputs['Emission Strength'].default_value = 0.22
    return paint


def shadow_surface(tree):
    paint = tree.nodes.new('ShaderNodeBsdfDiffuse')
    paint.inputs['Color'].default_value = (0.004, 0.006, 0.012, 1)
    return paint


def logo():
    mask = logo_mask()
    logo_plane('logo_shadow', image_from_mask('shadow', blurred(mask)), 0.85,
               SHADOW_OFFSET, shadow_surface, SHADOW_STRENGTH)
    logo_plane('logo', image_from_mask('logo', mask), LOGO_LIFT, (0, 0),
               white_surface)


def stack(column, top_row, count, mat):
    x = -HALF + (column + 0.5) * POINT_WIDTH
    for slot in range(count):
        offset = CHECKER_RADIUS + 0.05 + slot * PITCH
        checker(x, HALF - offset if top_row else -HALF + offset, mat)


def build():
    # The brand color fills the large background, the darker blue the points.
    field = material('field', FIELD, 0.85)
    colors = [material('point_a', DEEP_BLUE, 0.7), material('point_b', PALE_BLUE, 0.7)]
    white = material('white', LIGHT, 0.45)
    dark = material('dark', NIGHT_BLUE, 0.45)

    flat('field', [(-90, -90, 0), (90, -90, 0), (90, 90, 0), (-90, 90, 0)], field)
    for row, (base_y, direction) in enumerate(((-HALF, 1), (HALF, -1))):
        for column in range(COLUMNS):
            left = -HALF + column * POINT_WIDTH
            right = left + POINT_WIDTH
            flat(f'point_{row}_{column}',
                 [(left, base_y, 0.01), (right, base_y, 0.01),
                  ((left + right) / 2, base_y + direction * POINT_LENGTH, 0.01)],
                 colors[(column + row) % 2])

    # Short stacks along the edges keep the logo free.
    stack(0, True, 3, dark)
    stack(2, True, 2, white)
    stack(5, True, 2, dark)
    stack(0, False, 3, white)
    stack(3, False, 2, dark)
    stack(5, False, 3, white)
    logo()


def setup():
    addon_utils.enable('cycles')
    scene = bpy.context.scene
    for obj in list(bpy.data.objects):
        bpy.data.objects.remove(obj)
    scene.render.engine = 'CYCLES'
    scene.render.resolution_x = 1024
    scene.render.resolution_y = 1024
    scene.render.image_settings.file_format = 'PNG'
    scene.render.image_settings.color_mode = 'RGB'
    scene.view_settings.view_transform = 'Standard'
    scene.cycles.samples = 384
    scene.cycles.use_denoising = True
    preferences = bpy.context.preferences.addons['cycles'].preferences
    preferences.compute_device_type = 'OPTIX'
    preferences.refresh_devices()
    for device in preferences.devices:
        device.use = device.type == 'OPTIX'
    scene.cycles.device = 'GPU'

    world = bpy.data.worlds.new('world')
    world.use_nodes = True
    world.node_tree.nodes['Background'].inputs['Strength'].default_value = 0.85
    scene.world = world

    # Straight down without perspective: points at the top and the bottom have
    # the same size and reach the edges of the icon, without a border.
    data = bpy.data.cameras.new('camera')
    data.type = 'ORTHO'
    data.ortho_scale = FRAME * HALF
    camera = bpy.data.objects.new('camera', data)
    scene.collection.objects.link(camera)
    camera.location = (0, 0, 100)
    camera.rotation_euler = (0, 0, 0)
    scene.camera = camera

    light = bpy.data.lights.new('key', 'AREA')
    light.size = 80
    light.energy = 30000
    key = bpy.data.objects.new('key', light)
    scene.collection.objects.link(key)
    key.location = (-5, 5, 48)
    key.rotation_euler = (math.radians(-6), math.radians(-6), 0)


def main():
    setup()
    build()
    scene = bpy.context.scene
    scene.render.filepath = str(OUTPUT)
    bpy.ops.render.render(write_still=True)


main()

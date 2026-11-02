# Renders all board assets from board_config.json. Started by render.ps1.
#
# Point 1 sits in the bottom right corner of the white view, point 24 in the
# top right. Sprites are rendered once: lights follow the camera, so they look
# the same from both sides.
import json
import math
import os
import sys
from pathlib import Path

import addon_utils
import bmesh
import bpy
from bpy_extras.object_utils import world_to_camera_view
from mathutils import Euler, Vector

ROOT = Path(__file__).resolve().parents[2]
CONFIG = json.loads((Path(__file__).parent / 'board_config.json').read_text())
ASSET_DIR = ROOT / 'assets' / 'board'
PREVIEW_DIR = Path(__file__).parent / 'preview'

COLORS = CONFIG['colors']
MATERIALS = CONFIG['materials']
BOARD = CONFIG['board']
PIECES = CONFIG['pieces']

POINT_WIDTH = BOARD['point_width']
POINT_LENGTH = BOARD['point_length']
BAR_WIDTH = BOARD['bar_width']
RAIL_WIDTH = BOARD['rail_width']
RAIL_HEIGHT = BOARD['rail_height']
BOARD_BOTTOM = BOARD['board_bottom']
TRAY_DIVIDER = BOARD['tray_divider']
HALF_FIELD_X = 6 * POINT_WIDTH + BAR_WIDTH / 2
HALF_FIELD_Y = POINT_LENGTH + BOARD['middle_gap'] / 2
STACK_LAYER = 5
MAX_STACK = 15
# The tray has three equal compartments, and 15 checkers on edge fill one of
# them exactly. That fixes the checker thickness.
TRAY_COMPARTMENT = (2 * HALF_FIELD_Y - 2 * TRAY_DIVIDER) / 3
CHECKER_HEIGHT = (TRAY_COMPARTMENT - 2 * PIECES['rail_gap']) / MAX_STACK
# Checkers lie right at the rail, and five of them fill one point. The near rail
# is rendered as its own layer so that it covers them as a real rail would.
RAIL_CLEARANCE = PIECES['rail_gap']
CHECKER_PITCH = (POINT_LENGTH - RAIL_CLEARANCE) / STACK_LAYER
CHECKER_RADIUS = (CHECKER_PITCH - PIECES['checker_gap']) / 2
# The tray follows from the checkers: one wide, deep enough to hold them on edge.
TRAY_WIDTH = 2 * (CHECKER_RADIUS + BOARD['tray_gap'])
TRAY_X = HALF_FIELD_X + RAIL_WIDTH + TRAY_WIDTH / 2
TRAY_FLOOR = RAIL_HEIGHT - 2 * CHECKER_RADIUS * BOARD['tray_depth_ratio']
OUTER_LEFT = -HALF_FIELD_X - RAIL_WIDTH
OUTER_RIGHT = HALF_FIELD_X + 2 * RAIL_WIDTH + TRAY_WIDTH
OUTER_Y = HALF_FIELD_Y + RAIL_WIDTH
CENTER_X = (OUTER_LEFT + OUTER_RIGHT) / 2
SPRITE_REFERENCE = Vector((CENTER_X, 0, 0))

START_POSITION = {
    'white': {24: 2, 13: 5, 8: 3, 6: 5},
    'black': {1: 2, 12: 5, 17: 3, 19: 5},
}

PIP_LAYOUT = {
    1: [(0, 0)],
    2: [(-1, -1), (1, 1)],
    3: [(-1, -1), (0, 0), (1, 1)],
    4: [(-1, -1), (-1, 1), (1, -1), (1, 1)],
    5: [(-1, -1), (-1, 1), (0, 0), (1, -1), (1, 1)],
    6: [(-1, -1), (-1, 0), (-1, 1), (1, -1), (1, 0), (1, 1)],
}
# Rotations that turn the given face to the top of the die.
TOP_FACE_ROTATION = {
    1: (0, 0, 0),
    2: (0, -math.pi / 2, 0),
    3: (math.pi / 2, 0, 0),
    4: (-math.pi / 2, 0, 0),
    5: (0, math.pi / 2, 0),
    6: (math.pi, 0, 0),
}


def linear(channel):
    if channel <= 0.04045:
        return channel / 12.92
    return ((channel + 0.055) / 1.055) ** 2.4


def rgba(hex_color):
    value = hex_color.lstrip('#')
    channels = [int(value[i:i + 2], 16) / 255 for i in (0, 2, 4)]
    return (*[linear(channel) for channel in channels], 1)


def principled(name, color, roughness, coat=0.0):
    material = bpy.data.materials.new(name)
    material.use_nodes = True
    node = material.node_tree.nodes['Principled BSDF']
    node.inputs['Base Color'].default_value = rgba(color)
    node.inputs['Roughness'].default_value = roughness
    node.inputs['Coat Weight'].default_value = coat
    return material


def wood_material():
    material = principled('wood', COLORS['frame_wood_light'],
                          MATERIALS['wood_roughness'], 0.3)
    tree = material.node_tree
    coordinates = tree.nodes.new('ShaderNodeTexCoord')
    mapping = tree.nodes.new('ShaderNodeMapping')
    mapping.inputs['Scale'].default_value = (0.25, 3.0, 1.0)
    noise = tree.nodes.new('ShaderNodeTexNoise')
    noise.inputs['Scale'].default_value = 4.0
    noise.inputs['Detail'].default_value = 8.0
    noise.inputs['Distortion'].default_value = 1.5
    ramp = tree.nodes.new('ShaderNodeValToRGB')
    ramp.color_ramp.elements[0].position = 0.35
    ramp.color_ramp.elements[0].color = rgba(COLORS['frame_wood_dark'])
    ramp.color_ramp.elements[1].position = 0.7
    ramp.color_ramp.elements[1].color = rgba(COLORS['frame_wood_light'])
    tree.links.new(coordinates.outputs['Object'], mapping.inputs['Vector'])
    tree.links.new(mapping.outputs['Vector'], noise.inputs['Vector'])
    tree.links.new(noise.outputs['Fac'], ramp.inputs['Fac'])
    tree.links.new(ramp.outputs['Color'],
                   tree.nodes['Principled BSDF'].inputs['Base Color'])
    return material


def felt_material():
    material = principled('felt', COLORS['felt'], MATERIALS['felt_roughness'])
    tree = material.node_tree
    noise = tree.nodes.new('ShaderNodeTexNoise')
    noise.inputs['Scale'].default_value = 90.0
    noise.inputs['Detail'].default_value = 6.0
    bump = tree.nodes.new('ShaderNodeBump')
    bump.inputs['Strength'].default_value = 0.25
    tree.links.new(noise.outputs['Fac'], bump.inputs['Height'])
    tree.links.new(bump.outputs['Normal'],
                   tree.nodes['Principled BSDF'].inputs['Normal'])
    return material


def link(mesh, name, material):
    mesh.materials.append(material)
    obj = bpy.data.objects.new(name, mesh)
    bpy.context.scene.collection.objects.link(obj)
    return obj


def box(name, x0, x1, y0, y1, z0, z1, material, bevel=0.0):
    mesh = bpy.data.meshes.new(name)
    source = bmesh.new()
    bmesh.ops.create_cube(source, size=1.0)
    source.to_mesh(mesh)
    source.free()
    obj = link(mesh, name, material)
    obj.scale = (x1 - x0, y1 - y0, z1 - z0)
    obj.location = ((x0 + x1) / 2, (y0 + y1) / 2, (z0 + z1) / 2)
    bpy.context.view_layer.update()
    bpy.ops.object.select_all(action='DESELECT')
    obj.select_set(True)
    bpy.context.view_layer.objects.active = obj
    bpy.ops.object.transform_apply(scale=True, location=False, rotation=False)
    if bevel:
        modifier = obj.modifiers.new('bevel', 'BEVEL')
        modifier.width = bevel
        modifier.segments = 3
    return obj


def triangle(name, base_left, base_right, base_y, tip_y, material):
    mesh = bpy.data.meshes.new(name)
    z = 0.015
    tip = (base_left + base_right) / 2
    faces = [(0, 1, 2)] if tip_y > base_y else [(0, 2, 1)]
    mesh.from_pydata([(base_left, base_y, z), (base_right, base_y, z),
                      (tip, tip_y, z)], [], faces)
    return link(mesh, name, material)


def lathe(name, profile, material):
    """Revolves (radius, height) pairs around the Z axis."""
    segments = 96
    vertices = []
    for step in range(segments):
        angle = 2 * math.pi * step / segments
        vertices += [(radius * math.cos(angle), radius * math.sin(angle),
                      height) for radius, height in profile]
    rows = len(profile)
    faces = []
    for step in range(segments):
        following = (step + 1) % segments
        for row in range(rows - 1):
            faces.append((step * rows + row, following * rows + row,
                          following * rows + row + 1, step * rows + row + 1))
    mesh = bpy.data.meshes.new(name)
    mesh.from_pydata(vertices, [], faces)
    for polygon in mesh.polygons:
        polygon.use_smooth = True
    return link(mesh, name, material)


def checker(color, location):
    r = CHECKER_RADIUS
    h = CHECKER_HEIGHT
    profile = [(0.001, 0), (r - 0.06, 0), (r, 0.06), (r, h - 0.08),
               (r - 0.04, h - 0.02), (r - 0.1, h), (r - 0.2, h),
               (r - 0.26, h - 0.06), (r - 0.34, h - 0.06), (r - 0.38, h - 0.03),
               (r - 0.42, h - 0.06), (0.001, h - 0.06)]
    obj = lathe(f'checker_{color}', profile, MATERIAL_SET[f'checker_{color}'])
    obj.location = location
    return obj


def marked_checker(color, location):
    """A checker with a ring on top, which shows it is selected."""
    r = CHECKER_RADIUS
    h = CHECKER_HEIGHT
    profile = [(r - 0.42, h - 0.02), (r - 0.4, h + 0.03), (r - 0.12, h + 0.03),
               (r - 0.08, h - 0.02)]
    ring = lathe('marker', profile, MATERIAL_SET['selection_marker'])
    ring.location = location
    return [checker(color, location), ring]


def edge_checker(color, location):
    """A borne-off checker standing on its rim with its face to the camera."""
    obj = checker(color, location + Vector(
        (0, CHECKER_HEIGHT / 2, CHECKER_RADIUS)))
    obj.rotation_euler = (math.pi / 2, 0, 0)
    return obj


def die(color, top, location):
    size = PIECES['die_size']
    half = size / 2
    body = box(f'die_{color}', -half, half, -half, half, 0, size,
               MATERIAL_SET[f'checker_{color}'], bevel=size * 0.11)
    pips = MATERIAL_SET[f'pip_on_{color}']
    offset = size * 0.25
    radius = size * 0.085
    faces = {
        1: lambda u, v: (u, v, half + half),
        6: lambda u, v: (u, v, 0),
        2: lambda u, v: (half, u, half + v),
        5: lambda u, v: (-half, u, half + v),
        3: lambda u, v: (u, half, half + v),
        4: lambda u, v: (u, -half, half + v),
    }
    parts = [body]
    for face, position in faces.items():
        for u, v in PIP_LAYOUT[face]:
            mesh = bpy.data.meshes.new('pip')
            source = bmesh.new()
            bmesh.ops.create_uvsphere(source, u_segments=24, v_segments=12,
                                      radius=radius)
            source.to_mesh(mesh)
            source.free()
            for polygon in mesh.polygons:
                polygon.use_smooth = True
            pip = link(mesh, 'pip', pips)
            pip.location = position(u * offset, v * offset)
            pip.scale = (1, 1, 1)
            parts.append(pip)
    pivot = bpy.data.objects.new('die_pivot', None)
    bpy.context.scene.collection.objects.link(pivot)
    pivot.location = (0, 0, half)
    for part in parts:
        part.parent = pivot
        part.location = part.location - Vector((0, 0, half))
    pivot.rotation_euler = TOP_FACE_ROTATION[top]
    holder = bpy.data.objects.new('die', None)
    bpy.context.scene.collection.objects.link(holder)
    holder.location = location
    holder.rotation_euler = (0, 0, math.radians(12))
    pivot.parent = holder
    return [holder, pivot, *parts]


def doubling_cube(value, location):
    size = PIECES['cube_size']
    half = size / 2
    body = box('cube', -half, half, -half, half, 0, size,
               MATERIAL_SET['doubling_cube'], bevel=size * 0.08)
    curve = bpy.data.curves.new('cube_text', 'FONT')
    curve.body = str(value)
    curve.size = size * (0.62 if value < 10 else 0.5)
    curve.align_x = 'CENTER'
    curve.align_y = 'CENTER'
    curve.extrude = 0.01
    curve.materials.append(MATERIAL_SET['doubling_cube_text'])
    text = bpy.data.objects.new('cube_text', curve)
    bpy.context.scene.collection.objects.link(text)
    text.location = (0, 0, half + 0.005)
    body.location = location + Vector((0, 0, half))
    text.parent = body
    return [body, text]


def build_board():
    wood = MATERIAL_SET['wood']
    felt = MATERIAL_SET['felt']
    tray_left = HALF_FIELD_X + RAIL_WIDTH
    tray_right = OUTER_RIGHT - RAIL_WIDTH
    parts = [
        box('field', -HALF_FIELD_X, HALF_FIELD_X, -HALF_FIELD_Y, HALF_FIELD_Y,
            -0.4, 0, felt),
        box('tray_floor_white', tray_left, tray_right, -HALF_FIELD_Y,
            -TRAY_COMPARTMENT / 2, BOARD_BOTTOM, TRAY_FLOOR,
            MATERIAL_SET['tray_felt_white']),
        box('tray_floor', tray_left, tray_right, -TRAY_COMPARTMENT / 2,
            TRAY_COMPARTMENT / 2, BOARD_BOTTOM, TRAY_FLOOR, felt),
        box('tray_floor_black', tray_left, tray_right, TRAY_COMPARTMENT / 2,
            HALF_FIELD_Y, BOARD_BOTTOM, TRAY_FLOOR,
            MATERIAL_SET['tray_felt_black']),
        box('rail_bottom', OUTER_LEFT, OUTER_RIGHT, -OUTER_Y, -HALF_FIELD_Y,
            BOARD_BOTTOM, RAIL_HEIGHT, wood, 0.12),
        box('rail_top', OUTER_LEFT, OUTER_RIGHT, HALF_FIELD_Y, OUTER_Y,
            BOARD_BOTTOM, RAIL_HEIGHT, wood, 0.12),
        box('rail_left', OUTER_LEFT, -HALF_FIELD_X, -HALF_FIELD_Y,
            HALF_FIELD_Y, BOARD_BOTTOM, RAIL_HEIGHT, wood, 0.12),
        box('rail_right', HALF_FIELD_X, HALF_FIELD_X + RAIL_WIDTH,
            -HALF_FIELD_Y, HALF_FIELD_Y, BOARD_BOTTOM, RAIL_HEIGHT, wood, 0.12),
        box('tray_divider_bottom', HALF_FIELD_X + RAIL_WIDTH,
            OUTER_RIGHT - RAIL_WIDTH, -TRAY_COMPARTMENT / 2 - TRAY_DIVIDER,
            -TRAY_COMPARTMENT / 2, TRAY_FLOOR, RAIL_HEIGHT, wood, 0.05),
        box('tray_divider_top', HALF_FIELD_X + RAIL_WIDTH,
            OUTER_RIGHT - RAIL_WIDTH, TRAY_COMPARTMENT / 2,
            TRAY_COMPARTMENT / 2 + TRAY_DIVIDER, TRAY_FLOOR, RAIL_HEIGHT,
            wood, 0.05),
        box('rail_tray', OUTER_RIGHT - RAIL_WIDTH, OUTER_RIGHT, -HALF_FIELD_Y,
            HALF_FIELD_Y, BOARD_BOTTOM, RAIL_HEIGHT, wood, 0.12),
        box('bar', -BAR_WIDTH / 2, BAR_WIDTH / 2, -HALF_FIELD_Y, HALF_FIELD_Y,
            BOARD_BOTTOM, RAIL_HEIGHT, wood, 0.12),
    ]
    for point in range(1, 25):
        center = point_center_x(point)
        bottom = point <= 12
        base_y = -HALF_FIELD_Y if bottom else HALF_FIELD_Y
        tip_y = base_y + POINT_LENGTH if bottom else base_y - POINT_LENGTH
        color = 'point_dark' if point % 2 else 'point_light'
        parts.append(triangle(f'point_{point}', center - POINT_WIDTH / 2,
                              center + POINT_WIDTH / 2, base_y, tip_y,
                              MATERIAL_SET[color]))
    return parts


def point_center_x(point):
    """Point 1 is the bottom right corner, point 13 the top left corner."""
    index = point - 1 if point <= 12 else 24 - point
    offset = (index + 0.5) * POINT_WIDTH + (BAR_WIDTH if index >= 6 else 0)
    return HALF_FIELD_X - offset


def stack_position(center_x, edge_y, direction, slot):
    """Stacks five checkers in a row, further checkers lie on top of them."""
    layer = slot // STACK_LAYER
    row = slot % STACK_LAYER
    y = edge_y + direction * (RAIL_CLEARANCE + CHECKER_RADIUS
                              + row * CHECKER_PITCH)
    return Vector((center_x, y, layer * CHECKER_HEIGHT))


def point_slots(point):
    bottom = point <= 12
    edge = -HALF_FIELD_Y if bottom else HALF_FIELD_Y
    return [stack_position(point_center_x(point), edge, 1 if bottom else -1,
                           slot) for slot in range(MAX_STACK)]


def bar_slots(color):
    direction = -1 if color == 'white' else 1
    return [Vector((0, direction * (CHECKER_RADIUS + 1.2 + (slot % 3) * CHECKER_PITCH),
                    RAIL_HEIGHT + (slot // 3) * CHECKER_HEIGHT))
            for slot in range(MAX_STACK)]


def off_slots(color):
    """Checkers stand on edge in a row, starting at the rail of their side."""
    edge = HALF_FIELD_Y if color == 'black' else -HALF_FIELD_Y
    direction = -1 if color == 'black' else 1
    return [Vector((TRAY_X, edge + direction * (
        PIECES['rail_gap'] + (slot + 0.5) * CHECKER_HEIGHT), TRAY_FLOOR))
        for slot in range(MAX_STACK)]


def dice_slots(color):
    side = 1 if color == 'white' else -1
    center = side * (BAR_WIDTH / 2 + 3 * POINT_WIDTH)
    return [Vector((center - 2.2, 0, 0)), Vector((center + 2.2, 0, 0))]


def cube_slots():
    return {
        'white': Vector((0, -HALF_FIELD_Y + 3, RAIL_HEIGHT)),
        'black': Vector((0, HALF_FIELD_Y - 3, RAIL_HEIGHT)),
    }


def set_view(view):
    side = -1 if view == 'white' else 1
    tilt = math.radians(CONFIG['camera']['tilt_degrees'])
    width = (OUTER_RIGHT - OUTER_LEFT) * CONFIG['camera']['frame_margin']
    aspect_fov = 2 * math.atan(18 / CONFIG['camera']['lens_mm'])
    distance = (width / 2) / math.tan(aspect_fov / 2)
    target = Vector((CENTER_X, 0, 0))
    CAMERA.location = target + Vector(
        (0, side * math.sin(tilt), math.cos(tilt))) * distance
    direction = target - CAMERA.location
    CAMERA.rotation_euler = direction.to_track_quat('-Z', 'Y').to_euler()
    RIG.rotation_euler = (0, 0, 0 if view == 'white' else math.pi)
    bpy.context.view_layer.update()


def project(location):
    scene = bpy.context.scene
    point = world_to_camera_view(scene, CAMERA, location)
    return Vector((point.x, 1 - point.y))


def scale_at(location):
    """Size of a checker here relative to the sprite reference point."""
    def width(center):
        left = project(center + Vector((-CHECKER_RADIUS, 0, 0)))
        right = project(center + Vector((CHECKER_RADIUS, 0, 0)))
        return (right - left).length
    return width(location) / width(SPRITE_REFERENCE)


def entry(location):
    position = project(location)
    return [round(position.x, 5), round(position.y, 5),
            round(scale_at(location), 4)]


def board_bounds():
    """Image rectangle (left, top, width, height) around the outer board."""
    corners = [project(Vector((x, y, z)))
               for x in (OUTER_LEFT, OUTER_RIGHT) for y in (-OUTER_Y, OUTER_Y)
               for z in (BOARD_BOTTOM, RAIL_HEIGHT)]
    left = min(c.x for c in corners)
    top = min(c.y for c in corners)
    return [round(left, 5), round(top, 5),
            round(max(c.x for c in corners) - left, 5),
            round(max(c.y for c in corners) - top, 5)]


def export_layout(view, sprites, trays, cube_home):
    layout = {
        'image': f'board_{view}.png',
        'frontRail': f'rail_{view}.png',
        'aspect': CONFIG['render']['width'] / CONFIG['render']['height'],
        'sprites': sprites,
        'points': {str(p): [entry(s) for s in point_slots(p)]
                   for p in range(1, 25)},
        'bar': {c: [entry(s) for s in bar_slots(c)] for c in PLAYER_COLORS},
        'off': trays,
        'cubeHome': cube_home,
        'bounds': board_bounds(),
        'dice': {c: [entry(s) for s in dice_slots(c)] for c in PLAYER_COLORS},
        'cube': {k: entry(v) for k, v in cube_slots().items()},
    }
    (ASSET_DIR / f'layout_{view}.json').write_text(json.dumps(layout))


def render(path, samples, film_transparent=False):
    scene = bpy.context.scene
    scene.cycles.samples = samples
    scene.render.film_transparent = film_transparent
    scene.render.filepath = str(path)
    bpy.ops.render.render(write_still=True)


def render_front_rail(view, board_parts, table):
    """Renders the parts that cover checkers behind them, cuts out the rest.

    Besides the near rail this is the divider in front of the far compartment.
    """
    covering = (('rail_bottom', 'tray_divider_top') if view == 'white'
                else ('rail_top', 'tray_divider_bottom'))
    others = [part for part in (*board_parts, table)
              if part.name not in covering]
    for part in others:
        part.is_holdout = True
    render(ASSET_DIR / f'rail_{view}.png', CONFIG['render']['board_samples'],
           True)
    for part in others:
        part.is_holdout = False


def tray_region(y_from, y_to):
    """Image rectangle (left, top, right, bottom) around a tray section."""
    left = TRAY_X - TRAY_WIDTH / 2
    right = TRAY_X + TRAY_WIDTH / 2
    corners = [project(Vector((x, y, z)))
               for x in (left, right) for y in (y_from, y_to)
               for z in (TRAY_FLOOR, TRAY_FLOOR + 2 * CHECKER_RADIUS)]
    margin = 0.004
    return (max(min(c.x for c in corners) - margin, 0),
            max(min(c.y for c in corners) - margin, 0),
            min(max(c.x for c in corners) + margin, 1),
            min(max(c.y for c in corners) + margin, 1))


def render_region(name, region):
    """Renders one rectangle of the current view and returns its position."""
    left, top, right, bottom = region
    settings = bpy.context.scene.render
    settings.use_border = True
    settings.use_crop_to_border = True
    settings.border_min_x = left
    settings.border_max_x = right
    settings.border_min_y = 1 - bottom
    settings.border_max_y = 1 - top
    render(ASSET_DIR / f'{name}.png', CONFIG['render']['sprite_samples'], True)
    settings.use_border = False
    settings.use_crop_to_border = False
    return [round(left, 5), round(top, 5), round(right - left, 5),
            round(bottom - top, 5)]


def render_tray_contents(view, board_parts, table):
    """Renders tray stacks in their real place, including walls and shadows.

    The tray floor catches the shadows; all other parts only cover the pieces.
    Their own shadows are already part of the board image.
    """
    floors = [p for p in board_parts if p.name.startswith('tray_floor')]
    for floor in floors:
        floor.is_shadow_catcher = True
    others = [p for p in (*board_parts, table) if p not in floors]
    for part in others:
        part.is_holdout = True
        part.visible_shadow = False

    set_view(view)
    trays = {}
    end = HALF_FIELD_Y
    start = TRAY_COMPARTMENT / 2 + TRAY_DIVIDER
    for color in PLAYER_COLORS:
        slots = off_slots(color)
        region = tray_region(*((start, end) if color == 'black'
                               else (-end, -start)))
        trays[color] = []
        for count in range(1, MAX_STACK + 1):
            stack = [edge_checker(color, slot) for slot in slots[:count]]
            trays[color].append(render_region(
                f'off_{view}_{color}_{count}', region))
            for obj in stack:
                bpy.data.objects.remove(obj)

    cube = doubling_cube(64, Vector((TRAY_X, 0, TRAY_FLOOR)))
    cube[0].rotation_euler = (0, 0, 0 if view == 'white' else math.pi)
    cube_home = render_region(f'cube_home_{view}', tray_region(
        -TRAY_COMPARTMENT / 2, TRAY_COMPARTMENT / 2))
    for obj in cube:
        bpy.data.objects.remove(obj)

    for floor in floors:
        floor.is_shadow_catcher = False
    for part in others:
        part.is_holdout = False
        part.visible_shadow = True
    return trays, cube_home


def render_sprite(name, objects, radius, height):
    """Renders the objects with their shadow, cropped to their surroundings."""
    corners = []
    for x in (-radius, radius):
        for y in (-radius, radius):
            for z in (0, height):
                corners.append(project(SPRITE_REFERENCE + Vector((x, y, z))))
    margin = 0.012
    left = min(c.x for c in corners) - margin
    right = max(c.x for c in corners) + margin
    top = min(c.y for c in corners) - margin * 1.8
    bottom = max(c.y for c in corners) + margin * 1.8
    render_settings = bpy.context.scene.render
    render_settings.use_border = True
    render_settings.use_crop_to_border = True
    render_settings.border_min_x = left
    render_settings.border_max_x = right
    render_settings.border_min_y = 1 - bottom
    render_settings.border_max_y = 1 - top
    render(ASSET_DIR / f'{name}.png', CONFIG['render']['sprite_samples'], True)
    render_settings.use_border = False
    render_settings.use_crop_to_border = False
    anchor = project(SPRITE_REFERENCE)
    for obj in objects:
        bpy.data.objects.remove(obj)
    return {'left': round(left - anchor.x, 5), 'top': round(top - anchor.y, 5),
            'width': round(right - left, 5), 'height': round(bottom - top, 5)}


def render_sprites():
    catcher = box('catcher', -80, 80, -80, 80, -0.05, 0,
                  MATERIAL_SET['felt'])
    catcher.is_shadow_catcher = True
    sprites = {}
    die_height = PIECES['die_size']
    cube_height = PIECES['cube_size']
    for color in PLAYER_COLORS:
        name = f'checker_{color}'
        sprites[name] = render_sprite(
            name, [checker(color, SPRITE_REFERENCE)], CHECKER_RADIUS,
            CHECKER_HEIGHT)
        name = f'checker_{color}_selected'
        sprites[name] = render_sprite(
            name, marked_checker(color, SPRITE_REFERENCE), CHECKER_RADIUS,
            CHECKER_HEIGHT)
        for top in range(1, 7):
            name = f'die_{color}_{top}'
            sprites[name] = render_sprite(
                name, die(color, top, SPRITE_REFERENCE), die_height,
                die_height)
    for value in (2, 4, 8, 16, 32, 64):
        name = f'cube_{value}'
        sprites[name] = render_sprite(
            name, doubling_cube(value, SPRITE_REFERENCE), cube_height,
            cube_height)
    bpy.data.objects.remove(catcher)
    return sprites


def place_start_position():
    placed = []
    for color, points in START_POSITION.items():
        for point, count in points.items():
            for slot in point_slots(point)[:count]:
                placed.append(checker(color, slot))
    placed += die('white', 6, dice_slots('white')[0])
    placed += die('white', 3, dice_slots('white')[1])
    placed += doubling_cube(64, Vector((TRAY_X, 0, TRAY_FLOOR)))
    return placed


def setup_scene():
    addon_utils.enable('cycles')
    scene = bpy.context.scene
    for obj in list(bpy.data.objects):
        bpy.data.objects.remove(obj)
    scene.render.engine = 'CYCLES'
    scene.render.resolution_x = CONFIG['render']['width']
    scene.render.resolution_y = CONFIG['render']['height']
    scene.render.image_settings.file_format = 'PNG'
    scene.render.image_settings.color_mode = 'RGBA'
    scene.view_settings.view_transform = 'Standard'
    scene.cycles.use_denoising = True
    preferences = bpy.context.preferences.addons['cycles'].preferences
    try:
        preferences.compute_device_type = 'OPTIX'
        preferences.refresh_devices()
        for device in preferences.devices:
            device.use = device.type == 'OPTIX'
        scene.cycles.device = 'GPU'
    except TypeError:
        scene.cycles.device = 'CPU'
    world = bpy.data.worlds.new('world')
    world.use_nodes = True
    background = world.node_tree.nodes['Background']
    background.inputs['Strength'].default_value = \
        CONFIG['lighting']['world_strength']
    background.inputs['Color'].default_value = (1, 1, 1, 1)
    scene.world = world


def setup_camera_and_lights():
    global CAMERA, RIG
    data = bpy.data.cameras.new('camera')
    data.lens = CONFIG['camera']['lens_mm']
    CAMERA = bpy.data.objects.new('camera', data)
    scene = bpy.context.scene
    scene.collection.objects.link(CAMERA)
    scene.camera = CAMERA
    RIG = bpy.data.objects.new('light_rig', None)
    scene.collection.objects.link(RIG)
    RIG.location = (CENTER_X, 0, 0)

    key = bpy.data.lights.new('key', 'AREA')
    key.size = 60
    key.energy = CONFIG['lighting']['key_energy']
    key_object = bpy.data.objects.new('key', key)
    scene.collection.objects.link(key_object)
    key_object.parent = RIG
    key_object.location = (-30, -25, 70)
    key_object.rotation_euler = Euler((math.radians(20), math.radians(-22), 0))

    fill = bpy.data.lights.new('fill', 'SUN')
    fill.energy = CONFIG['lighting']['fill_energy']
    fill.angle = math.radians(25)
    fill_object = bpy.data.objects.new('fill', fill)
    scene.collection.objects.link(fill_object)
    fill_object.parent = RIG
    fill_object.rotation_euler = Euler((math.radians(35), math.radians(30), 0))


def main():
    global MATERIAL_SET, PLAYER_COLORS
    arguments = sys.argv[sys.argv.index('--') + 1:] if '--' in sys.argv else []
    preview_only = 'preview' in arguments
    PLAYER_COLORS = ('white', 'black')
    ASSET_DIR.mkdir(parents=True, exist_ok=True)
    PREVIEW_DIR.mkdir(exist_ok=True)
    setup_scene()
    MATERIAL_SET = {
        'wood': wood_material(),
        'felt': felt_material(),
        'tray_felt_white': principled('tray_felt_white',
                                      COLORS['tray_felt_white'],
                                      MATERIALS['felt_roughness']),
        'tray_felt_black': principled('tray_felt_black',
                                      COLORS['tray_felt_black'],
                                      MATERIALS['felt_roughness']),
        'table': principled('table', COLORS['table'], 0.6),
        'point_light': principled('point_light', COLORS['point_light'],
                                  MATERIALS['point_roughness']),
        'point_dark': principled('point_dark', COLORS['point_dark'],
                                 MATERIALS['point_roughness']),
        'checker_white': principled('checker_white', COLORS['checker_white'],
                                    MATERIALS['checker_roughness'],
                                    MATERIALS['checker_coat']),
        'checker_black': principled('checker_black', COLORS['checker_black'],
                                    MATERIALS['checker_roughness'],
                                    MATERIALS['checker_coat']),
        'pip_on_white': principled('pip_on_white', COLORS['pip_on_white'], 0.4),
        'pip_on_black': principled('pip_on_black', COLORS['pip_on_black'], 0.4),
        'selection_marker': principled('selection_marker',
                                       COLORS['selection_marker'], 0.35),
        'doubling_cube': principled('doubling_cube', COLORS['doubling_cube'],
                                    0.3, 0.5),
        'doubling_cube_text': principled('doubling_cube_text',
                                         COLORS['doubling_cube_text'], 0.4),
    }
    setup_camera_and_lights()
    board_parts = build_board()
    table = box('table', -300, 300, -300, 300, BOARD_BOTTOM - 0.8, BOARD_BOTTOM,
                MATERIAL_SET['table'])
    samples = CONFIG['render']['board_samples']

    placed = place_start_position()
    for view in PLAYER_COLORS:
        set_view(view)
        render(PREVIEW_DIR / f'preview_{view}.png',
               samples // 4 if preview_only else samples)
    for obj in placed:
        bpy.data.objects.remove(obj)
    if preview_only:
        return

    for view in PLAYER_COLORS:
        set_view(view)
        # The table only catches the shadow, so the app's background shows.
        table.is_shadow_catcher = True
        render(ASSET_DIR / f'board_{view}.png', samples, True)
        table.is_shadow_catcher = False
        render_front_rail(view, board_parts, table)

    tray_contents = {view: render_tray_contents(view, board_parts, table)
                     for view in PLAYER_COLORS}

    set_view('white')
    for part in (*board_parts, table):
        part.hide_render = True
    sprites = render_sprites()
    for part in (*board_parts, table):
        part.hide_render = False
    for view in PLAYER_COLORS:
        set_view(view)
        export_layout(view, sprites, *tray_contents[view])


main()

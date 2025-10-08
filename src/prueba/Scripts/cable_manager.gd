extends Node2D
class_name CableManager

# -------------------------
# 📡 SEÑALES
# -------------------------
signal cable_placed(start_pos: Vector2, end_pos: Vector2)
signal cable_removed(start_pos: Vector2, end_pos: Vector2)
signal cable_preview_updated(current_pos: Vector2)

# -------------------------
# ⚙️ CONFIGURACIÓN
# -------------------------
@export var cable_color: Color = Color.YELLOW
@export var cable_width: float = 4.0

# Grid isométrico "Diamond Down"
const TILE_WIDTH: int = 128
const TILE_HEIGHT: int = 73
const HALF_TILE_WIDTH: float = TILE_WIDTH / 2.0
const HALF_TILE_HEIGHT: float = TILE_HEIGHT / 2.0

# -------------------------
# 🧱 ESTADO INTERNO
# -------------------------
var cables: Array[Line2D] = []
var is_placing_cable := false
var is_removing_cable := false

var start_position: Vector2 = Vector2.ZERO
var current_line: Line2D = null
var tilemap_container: Node2D = null

# -------------------------
# 🟢 INICIO
# -------------------------
func _ready():
	# Intentar obtener el tilemap si existe
	if has_node("../Tilemap"):
		tilemap_container = get_node("../Tilemap")
	else:
		print("⚠️ Advertencia: No se encontró Tilemap en el parent")

	print("CableManager iniciado - Grid Diamond Down: %dx%d px" % [TILE_WIDTH, TILE_HEIGHT])

# -------------------------
# 🎮 INPUT PRINCIPAL
# -------------------------
func _input(event: InputEvent) -> void:
	if not (is_placing_cable or is_removing_cable):
		return

	# Evitar que clics de UI lleguen aquí
	if get_viewport().gui_get_hovered_control():
		return

	# Movimiento del mouse (preview)
	if event is InputEventMouseMotion and is_placing_cable and current_line:
		update_cable_preview(get_global_mouse_position())

	# Clics del mouse
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if is_placing_cable:
				start_cable_placement(get_global_mouse_position())
			elif is_removing_cable:
				remove_cable_at_position(get_global_mouse_position())
		else:
			if is_placing_cable and current_line:
				finish_cable_placement(get_global_mouse_position())

# -------------------------
# 🧮 CONVERSIONES DE GRID
# -------------------------
func world_to_diamond_grid(world_pos: Vector2) -> Vector2i:
	var x = (world_pos.x / HALF_TILE_WIDTH + world_pos.y / HALF_TILE_HEIGHT) / 2.0
	var y = (world_pos.y / HALF_TILE_HEIGHT - world_pos.x / HALF_TILE_WIDTH) / 2.0
	return Vector2i(round(x), round(y))

func diamond_grid_to_world(grid_pos: Vector2i) -> Vector2:
	var world_x = (grid_pos.x - grid_pos.y) * HALF_TILE_WIDTH
	var world_y = (grid_pos.x + grid_pos.y) * HALF_TILE_HEIGHT
	return Vector2(world_x, world_y)

func snap_to_diamond_grid(world_pos: Vector2) -> Vector2:
	var grid_pos = world_to_diamond_grid(world_pos)
	return diamond_grid_to_world(grid_pos)

# -------------------------
# 🔧 LÓGICA DE COLOCACIÓN
# -------------------------
func start_cable_placement(mouse_pos: Vector2):
	start_position = snap_to_diamond_grid(mouse_pos)
	
	# Si ya había una línea previa mal cerrada, limpiarla
	if current_line:
		current_line.queue_free()
		current_line = null
	
	current_line = Line2D.new()
	current_line.default_color = cable_color
	current_line.width = cable_width
	current_line.add_point(start_position)
	current_line.add_point(start_position)
	add_child(current_line)
	
	cable_preview_updated.emit(start_position)

func update_cable_preview(mouse_pos: Vector2):
	if not current_line:
		return
	
	var end_pos = snap_to_diamond_grid(mouse_pos)
	if end_pos != current_line.get_point_position(1):
		current_line.set_point_position(1, end_pos)
		cable_preview_updated.emit(end_pos)

func finish_cable_placement(mouse_pos: Vector2):
	if not current_line:
		return
	
	var end_pos = snap_to_diamond_grid(mouse_pos)
	current_line.set_point_position(1, end_pos)
	
	var distance = start_position.distance_to(end_pos)
	if distance > 10.0:
		cables.append(current_line)
		cable_placed.emit(start_position, end_pos)
	else:
		current_line.queue_free()
	
	current_line = null

# -------------------------
# ❌ LÓGICA DE REMOCIÓN
# -------------------------
func remove_cable_at_position(mouse_pos: Vector2):
	var grid_pos = snap_to_diamond_grid(mouse_pos)
	
	for i in range(cables.size() - 1, -1, -1):
		var cable = cables[i]
		if cable_contains_point(cable, grid_pos):
			var start = cable.get_point_position(0)
			var end = cable.get_point_position(1)
			cable.queue_free()
			cables.remove_at(i)
			
			if start.distance_to(end) > 10.0:
				cable_removed.emit(start, end)
			break

func cable_contains_point(cable: Line2D, point: Vector2) -> bool:
	if not cable or cable.get_point_count() < 2:
		return false
	
	var start = cable.get_point_position(0)
	var end = cable.get_point_position(1)
	
	var tolerance = float(min(HALF_TILE_WIDTH, HALF_TILE_HEIGHT))
	return point_to_line_distance(point, start, end) <= tolerance

func point_to_line_distance(point: Vector2, line_start: Vector2, line_end: Vector2) -> float:
	var line_vec = line_end - line_start
	var point_vec = point - line_start
	
	if line_vec.length_squared() == 0:
		return point_vec.length()
	
	var t = clamp(point_vec.dot(line_vec) / line_vec.length_squared(), 0.0, 1.0)
	var projection = line_start + t * line_vec
	return point.distance_to(projection)

# -------------------------
# 🔄 MODO DE OPERACIÓN
# -------------------------
func set_placing_mode(enabled: bool):
	is_placing_cable = enabled
	is_removing_cable = false
	if not enabled and current_line:
		current_line.queue_free()
		current_line = null

func set_removing_mode(enabled: bool):
	is_removing_cable = enabled
	is_placing_cable = false
	if current_line:
		current_line.queue_free()
		current_line = null

# -------------------------
# 🧠 DEBUG Y UTILIDAD
# -------------------------
func get_grid_info_at_mouse() -> Dictionary:
	var mouse_pos = get_global_mouse_position()
	var grid_pos = world_to_diamond_grid(mouse_pos)
	var snapped_world = diamond_grid_to_world(grid_pos)
	
	return {
		"mouse_world": mouse_pos,
		"grid_coord": grid_pos,
		"snapped_world": snapped_world,
		"tile_size": "%dx%d px" % [TILE_WIDTH, TILE_HEIGHT],
		"grid_type": "Diamond Down"
	}

func clear_all_cables():
	for cable in cables:
		cable.queue_free()
	cables.clear()
	print("🧹 Todos los cables eliminados")

func get_cable_count() -> int:
	return cables.size()

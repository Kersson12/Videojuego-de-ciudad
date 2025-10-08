extends Camera2D

# Configuración de zoom
@export var zoom_min: float = 0.5
@export var zoom_max: float = 2.0
@export var zoom_speed: float = 0.1

# Configuración de movimiento
@export var pan_speed: float = 1.5

# Variables internas - optimizadas
var is_dragging: bool = false
var drag_start_position: Vector2
var camera_start_position: Vector2

# Variables para touch móvil - optimizadas
var touch_points: Array[Vector2] = []
var touch_indices: Array[int] = []
var last_touch_distance: float = 0.0
var is_pinching: bool = false

# Cache para evitar cálculos repetitivos
var cached_zoom_vector: Vector2
var zoom_changed: bool = false

func _ready():
	# Si ya tienes un zoom en el editor, úsalo como valor inicial
	cached_zoom_vector = zoom.clamp(Vector2(zoom_min, zoom_min), Vector2(zoom_max, zoom_max))
	zoom = cached_zoom_vector


func _input(event):
	# Solo procesar eventos relevantes
	match event.get_class():
		"InputEventMouseButton":
			handle_mouse_button(event)
		"InputEventMouseMotion":
			if is_dragging:  # Solo procesar si estamos arrastrando
				handle_mouse_motion(event)
		"InputEventScreenTouch":
			handle_screen_touch(event)
		"InputEventScreenDrag":
			handle_screen_drag(event)

func handle_mouse_button(event: InputEventMouseButton):
	match event.button_index:
		MOUSE_BUTTON_WHEEL_UP:
			zoom_camera_fast(zoom_speed)
		MOUSE_BUTTON_WHEEL_DOWN:
			zoom_camera_fast(-zoom_speed)
		MOUSE_BUTTON_LEFT:
			if event.pressed:
				start_drag(event.position)
			else:
				stop_drag()

func handle_mouse_motion(event: InputEventMouseMotion):
	drag_camera_fast(event.position)

func handle_screen_touch(event: InputEventScreenTouch):
	if event.pressed:
		# Añadir toque de forma eficiente
		touch_points.push_back(event.position)
		touch_indices.push_back(event.index)
		
		match touch_points.size():
			1:
				start_drag(event.position)
			2:
				stop_drag()
				start_pinch_fast()
	else:
		# Remover toque específico
		var idx = touch_indices.find(event.index)
		if idx != -1:
			touch_points.remove_at(idx)
			touch_indices.remove_at(idx)
		
		match touch_points.size():
			0:
				stop_drag()
				stop_pinch()
			1:
				stop_pinch()
				start_drag(touch_points[0])

func handle_screen_drag(event: InputEventScreenDrag):
	# Actualizar posición del toque específico
	var idx = touch_indices.find(event.index)
	if idx != -1:
		touch_points[idx] = event.position
		
		if touch_points.size() == 1 and is_dragging:
			drag_camera_fast(event.position)
		elif touch_points.size() == 2 and is_pinching:
			handle_pinch_zoom_fast()

# Versiones optimizadas de las funciones principales
func start_drag(start_pos: Vector2):
	is_dragging = true
	drag_start_position = start_pos
	camera_start_position = global_position  # Capturar posición actual

func stop_drag():
	is_dragging = false

func drag_camera_fast(current_pos: Vector2):
	# Sensación de arrastre: mueves el mundo, no la cámara
	var mouse_delta = current_pos - drag_start_position
	var world_delta = mouse_delta * pan_speed / cached_zoom_vector.x
	# Debug temporal (eliminar después de probar)
	#print("Mouse delta: ", mouse_delta, " World delta: ", world_delta)
	global_position = camera_start_position - world_delta

func start_pinch_fast():
	is_pinching = true
	# Pre-calcular distancia inicial
	last_touch_distance = touch_points[0].distance_to(touch_points[1])

func stop_pinch():
	is_pinching = false
	last_touch_distance = 0.0

func handle_pinch_zoom_fast():
	var current_distance = touch_points[0].distance_to(touch_points[1])
	
	if last_touch_distance > 0:
		# Cálculo optimizado del zoom
		var zoom_factor = current_distance / last_touch_distance
		var new_zoom_value = cached_zoom_vector.x * zoom_factor
		
		# Aplicar límites de forma eficiente
		new_zoom_value = clampf(new_zoom_value, zoom_min, zoom_max)
		
		# Solo actualizar si cambió significativamente (evita micro-actualizaciones)
		if abs(new_zoom_value - cached_zoom_vector.x) > 0.01:
			cached_zoom_vector = Vector2(new_zoom_value, new_zoom_value)
			zoom = cached_zoom_vector
	
	last_touch_distance = current_distance

func zoom_camera_fast(zoom_delta: float):
	var zoom_factor = 1.0 + zoom_delta
	var new_zoom_value = cached_zoom_vector.x * zoom_factor
	
	# Aplicar límites
	new_zoom_value = clampf(new_zoom_value, zoom_min, zoom_max)
	
	# Solo actualizar si está dentro de los límites y cambió
	if new_zoom_value != cached_zoom_vector.x:
		cached_zoom_vector = Vector2(new_zoom_value, new_zoom_value)
		zoom = cached_zoom_vector

# Función opcional para resetear la cámara
func reset_camera():
	global_position = Vector2.ZERO
	cached_zoom_vector = Vector2.ONE
	zoom = cached_zoom_vector

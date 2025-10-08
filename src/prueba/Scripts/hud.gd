extends Control

# -----------------------------
# 🎛️ NODOS UI
# -----------------------------
@onready var cable_button: TextureButton = $CableButton
@onready var place_button: TextureButton = $CablePanel/PlaceButton
@onready var remove_button: TextureButton = $CablePanel/RemoveButton
@onready var cable_panel: Control = $CablePanel
@onready var debug_label: Label = $DebugLabel # Opcional

# -----------------------------
# 🎥 REFERENCIAS DE CÁMARA Y MANAGER
# -----------------------------
@onready var camera_2d: Camera2D = get_node("../../Ciudad/Camera2D")
@onready var cable_manager: CableManager = get_node("../../Ciudad/CableManager")
@onready var cable_camera: Camera2D = get_node("../../Ciudad/CableManager/CableCamera")

# -----------------------------
# ⚙️ ESTADO
# -----------------------------
var cable_mode_active := false
var camera_tween: Tween = null

# -----------------------------
# 🟢 INICIO
# -----------------------------
func _ready():
	# Evitar que clics en botones pasen al mundo
# Solo los botones deben detener el clic
	cable_button.mouse_filter = Control.MOUSE_FILTER_STOP
	place_button.mouse_filter = Control.MOUSE_FILTER_STOP
	remove_button.mouse_filter = Control.MOUSE_FILTER_STOP

	# El panel general debe dejar pasar los clics al mundo
	cable_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# Y el HUD principal (este Control) también
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	# Conexiones UI
	cable_button.pressed.connect(_on_cable_button_pressed)
	place_button.pressed.connect(_on_place_button_pressed)
	remove_button.pressed.connect(_on_remove_button_pressed)

	# Conexión con señales del manager
	cable_manager.cable_placed.connect(_on_cable_placed)
	cable_manager.cable_removed.connect(_on_cable_removed)
	cable_manager.cable_preview_updated.connect(_on_cable_preview_updated)

	# Estado inicial
	cable_panel.visible = false
	setup_ui()

# -----------------------------
# 🎨 CONFIGURACIÓN UI
# -----------------------------
func setup_ui():
	if cable_panel:
		cable_panel.position = Vector2(10, 50)
	
	if place_button:
		place_button.tooltip_text = "Colocar cables (+)"
	
	if remove_button:
		remove_button.tooltip_text = "Remover cables (-)"

# -----------------------------
# 🔄 CICLO PRINCIPAL
# -----------------------------
func _process(_delta):
	if debug_label and cable_mode_active:
		var info = cable_manager.get_grid_info_at_mouse()
		debug_label.text = "Grid: %s\nWorld: %s\nTile: %s\nType: %s" % [
			info.grid_coord,
			info.snapped_world,
			info.tile_size,
			info.grid_type
		]

# -----------------------------
# 🧩 MODO CABLE
# -----------------------------
func _on_cable_button_pressed():
	cable_mode_active = !cable_mode_active
	cable_panel.visible = cable_mode_active

	if cable_mode_active:
		print("Modo cable activado - Diamond Down 128x73px")

		# Verificación de cámaras
		if camera_2d == null:
			push_warning("Camera2D principal no encontrada.")
			return
		if cable_camera == null:
			push_warning("CableCamera no encontrada.")
			return

		# Desactivar la cámara principal
		camera_2d.enabled = false

		# Sincronizar posición y zoom desde la cámara principal
		cable_camera.global_position = camera_2d.global_position
		cable_camera.zoom = camera_2d.zoom
		cable_camera.enabled = true

		print("CableCamera activada en posición:", cable_camera.global_position)

		# Por defecto, activar el modo colocación
		cable_manager.set_placing_mode(true)
		place_button.modulate = Color.GREEN
		remove_button.modulate = Color.WHITE

	else:
		print("Modo cable desactivado")

		# Verificación de cámaras
		if camera_2d == null:
			push_warning("Camera2D principal no encontrada.")
			return
		if cable_camera == null:
			push_warning("CableCamera no encontrada.")
			return

		# Sincronizar posición y zoom actuales de la cámara de cables
		camera_2d.global_position = cable_camera.global_position
		camera_2d.zoom = cable_camera.zoom

		# Desactivar la cámara de cables
		cable_camera.enabled = false

		# Reactivar la cámara principal
		camera_2d.enabled = true

		print("Cámara principal restaurada en posición:", camera_2d.global_position)

		# Desactivar modos de cable
		cable_manager.set_placing_mode(false)
		cable_manager.set_removing_mode(false)
		reset_button_colors()



func enter_cable_mode():
	# Desactivar cámara normal
	if camera_2d:
		camera_2d.enabled = false

	# Activar cámara de cables sincronizada
	activate_cable_camera()

	# Activar modo colocación por defecto
	cable_manager.set_placing_mode(true)
	place_button.modulate = Color.GREEN
	remove_button.modulate = Color.WHITE

func exit_cable_mode():
	# Reactivar cámara normal
	if camera_2d:
		camera_2d.enabled = true
	
	deactivate_cable_camera()

	# Desactivar modos
	cable_manager.set_placing_mode(false)
	cable_manager.set_removing_mode(false)

	reset_button_colors()

# -----------------------------
# 🎥 CONTROL DE CÁMARA
# -----------------------------
func activate_cable_camera():
	if not cable_camera:
		return

	# Copiar posición y zoom actuales
	if camera_2d:
		cable_camera.global_position = camera_2d.global_position
		cable_camera.zoom = camera_2d.zoom

	cable_camera.enabled = true
	cable_camera.make_current() # ✅ Garantiza control del render
	print("🎥 CableCamera activada")

func deactivate_cable_camera():
	if cable_camera:
		cable_camera.enabled = false
	if camera_2d:
		camera_2d.make_current()
	print("🎥 CableCamera desactivada")

func update_cable_camera_position(position: Vector2):
	if not (cable_camera and cable_camera.enabled):
		return

	# Cancelar tween previo para evitar solapamiento
	if camera_tween and camera_tween.is_running():
		camera_tween.kill()
	
	camera_tween = get_tree().create_tween()
	camera_tween.tween_property(cable_camera, "global_position", position, 1.1)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)

# -----------------------------
# 🧭 BOTONES DE MODO
# -----------------------------
func _on_place_button_pressed():
	print("🟩 Modo colocación activado")
	cable_manager.set_placing_mode(true)
	place_button.modulate = Color.GREEN
	remove_button.modulate = Color.WHITE
	get_viewport().set_input_as_handled() # Evita clic fantasma

func _on_remove_button_pressed():
	print("🟥 Modo remoción activado")
	cable_manager.set_removing_mode(true)
	remove_button.modulate = Color.RED
	place_button.modulate = Color.WHITE
	get_viewport().set_input_as_handled() # 🔒 Evita click en mundo

func reset_button_colors():
	place_button.modulate = Color.WHITE
	remove_button.modulate = Color.WHITE

# -----------------------------
# 🔔 RESPUESTA A EVENTOS DE CABLES
# -----------------------------
func _on_cable_placed(start_pos: Vector2, end_pos: Vector2):
	print("Cable colocado desde %s hasta %s" % [start_pos, end_pos])
	update_cable_camera_position(end_pos)

func _on_cable_removed(start_pos: Vector2, end_pos: Vector2):
	print("Cable removido desde %s hasta %s" % [start_pos, end_pos])
	# Mueve cámara solo si era un cable real
	if start_pos.distance_to(end_pos) > 10.0:
		update_cable_camera_position(start_pos)

func _on_cable_preview_updated(current_pos: Vector2):
	update_cable_camera_position(current_pos)

# -----------------------------
# ⌨️ ATAJOS DE TECLADO
# -----------------------------
func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE and cable_mode_active:
			_on_cable_button_pressed() # Salir modo cable

# -----------------------------
# 📊 STATS Y UTILIDAD
# -----------------------------
func toggle_cable_mode():
	_on_cable_button_pressed()

func get_cable_stats() -> Dictionary:
	return {
		"total_cables": cable_manager.get_cable_count(),
		"mode_active": cable_mode_active,
		"placing_mode": cable_manager.is_placing_cable,
		"removing_mode": cable_manager.is_removing_cable,
		"cable_camera_active": cable_camera.enabled if cable_camera else false
	}

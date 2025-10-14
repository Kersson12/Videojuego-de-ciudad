extends Control
signal minigame_completed(success: bool, reward: float)

# ==================================================
# 📘 Clase Complex
# ==================================================
class Complex:
	var real: float
	var imag: float

	func _init(r: float = 0.0, i: float = 0.0):
		real = r
		imag = i

	func add(other):
		return Complex.new(real + other.real, imag + other.imag)

	func sub(other):
		return Complex.new(real - other.real, imag - other.imag)

	func div(other):
		var denom = other.real * other.real + other.imag * other.imag
		if denom == 0.0:
			return Complex.new(0.0, 0.0)
		return Complex.new(
			(real * other.real + imag * other.imag) / denom,
			(imag * other.real - real * other.imag) / denom
		)

	func abs():
		return sqrt(real * real + imag * imag)


# ==================================================
# 🎯 Parámetros generales
# ==================================================
@export var tolerance: float = 0.05

# ==================================================
# 🧩 Nodos
# ==================================================
@onready var sliderR = $Panel/SliderR
@onready var sliderX = $Panel/SliderX
@onready var btnCheck = $Panel/BtnCheck
@onready var btnExit = $Panel/BtnExit
@onready var btnShowTarget = $Panel/BtnShowTarget
@onready var labelR = $Panel/SliderR/ValueLabel
@onready var labelX = $Panel/SliderX/ValueLabel
@onready var marker = $Panel/Marker
@onready var target_marker = $Panel/TargetMarker
@onready var result_label = $Panel/ResultLabel
@onready var target_label = $Panel/TargetLabel
@onready var sfx_player = $Panel/SFXPlayer
@onready var background = $Panel/Background


# ==================================================
# 🔧 Variables internas
# ==================================================
var target_r: float
var target_x: float
var target_visible := false


# ==================================================
# ⚙️ Inicialización
# ==================================================
func _ready() -> void:
	# Configurar sliders
	sliderR.min_value = 0.0
	sliderR.max_value = 5.0
	sliderR.step = 0.1
	sliderR.value = 1.0

	sliderX.min_value = -5.0
	sliderX.max_value = 5.0
	sliderX.step = 0.1
	sliderX.value = 0.0

	labelR.text = "R: %.2f" % sliderR.value
	labelX.text = "X: %.2f" % sliderX.value
	result_label.text = ""

	_generate_random_target()
	_hide_target_marker()

	btnCheck.pressed.connect(_on_check_pressed)
	btnExit.pressed.connect(_on_exit_pressed)
	btnShowTarget.pressed.connect(_on_show_target_pressed)
	sliderR.value_changed.connect(_update_marker)
	sliderX.value_changed.connect(_update_marker)

	_update_marker()


# ==================================================
# 🔁 Actualización del marcador rojo
# ==================================================
func _update_marker(_v := 0.0) -> void:
	var r = sliderR.value
	var x = sliderX.value
	labelR.text = "R: %.2f" % r
	labelX.text = "X: %.2f" % x
	var gamma = _calc_gamma(r, x)
	_set_marker_position(marker, gamma, Vector2(-18, 0)) # 🔧 pequeño ajuste a la izquierda


# ==================================================
# 🎯 Generar nuevo objetivo
# ==================================================
func _generate_random_target() -> void:
	target_r = randf_range(0.2, 3.0)
	target_x = randf_range(-2.0, 2.0)
	target_label.text = "Objetivo: R=%.2f | X=%.2f" % [target_r, target_x]


# ==================================================
# 👁️ Mostrar / Ocultar marcador verde
# ==================================================
func _on_show_target_pressed() -> void:
	if target_visible:
		_hide_target_marker()
	else:
		_show_target_marker()

func _show_target_marker() -> void:
	target_visible = true
	_update_target_marker()
	target_marker.visible = true

func _hide_target_marker() -> void:
	target_visible = false
	target_marker.visible = false


# ==================================================
# 🔵 Posicionar marcador verde
# ==================================================
func _update_target_marker() -> void:
	var gamma_target = _calc_gamma(target_r, target_x)
	_set_marker_position(target_marker, gamma_target, Vector2(-8, 0))


# ==================================================
# ➗ Cálculo de coeficiente Γ
# ==================================================
func _calc_gamma(r: float, x: float):
	var z = Complex.new(r, x)
	var num = z.sub(Complex.new(1, 0))
	var den = z.add(Complex.new(1, 0))
	return num.div(den)


# ==================================================
# 📍 Posicionar marcadores
# ==================================================
func _set_marker_position(node, gamma, offset: Vector2 = Vector2.ZERO) -> void:
	if node == null or background == null:
		return

	var panel_size = background.size
	var center = background.position + panel_size * 0.5
	var scale = min(panel_size.x, panel_size.y) * 0.43

	var pos = Vector2(
		center.x + gamma.real * scale,
		center.y - gamma.imag * scale
	) + offset

	if node is Control:
		node.position = pos
	elif node.has_method("set_position"):
		node.call("set_position", pos)


# ==================================================
# ✅ Verificar coincidencia
# ==================================================
func _on_check_pressed() -> void:
	var r = sliderR.value
	var x = sliderX.value

	var gamma = _calc_gamma(r, x)
	var gamma_target = _calc_gamma(target_r, target_x)
	var diff = gamma.sub(gamma_target).abs()

	if diff <= tolerance:
		_play_sound("res://Sonidos/okay.wav")
		result_label.text = "✅ ¡Correcto! Se generó un nuevo objetivo."
		_generate_random_target()
		_hide_target_marker()
	else:
		_play_sound("res://Sonidos/error.wav")
		result_label.text = "❌ Intenta de nuevo. |Γ| diff = %.3f" % diff


# ==================================================
# 🚪 Salir
# ==================================================
func _on_exit_pressed() -> void:
	queue_free()


# ==================================================
# 🔊 Sonido
# ==================================================
func _play_sound(path: String) -> void:
	if sfx_player:
		var st = load(path)
		if st:
			sfx_player.stream = st
			sfx_player.play()

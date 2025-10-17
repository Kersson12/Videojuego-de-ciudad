extends Control
signal minigame_completed(success: bool, reward: float)

@export var target_z0: float = 100.0
@export var tolerance: float = 5.0
@export var time_limit: float = 10.0 # ⏱️ Tiempo máximo (en segundos)

@onready var sliderL = $Panel/SliderL
@onready var sliderC = $Panel/SliderC
@onready var lvalue = $Panel/LValue
@onready var cvalue = $Panel/CValue
@onready var lblZ0 = $Panel/lblZ0
@onready var lblTarget = $Panel/lblTarget
@onready var btnCheck = $Panel/btnCheck
@onready var btnCancel = $Panel/btnCancel
@onready var result_label = $Panel/ResultLabel
@onready var sfx_player = $Panel/SfxPlayer

# 🕒 Temporizador de límite de tiempo
@onready var limit_timer := Timer.new()
@onready var lbl_timer := Label.new()

func _ready():
	# Configurar el objetivo
	lblTarget.text = "🎯 Target Z₀: %.1f Ω" % target_z0

	# Conexiones
	sliderL.connect("value_changed", Callable(self, "_on_slider_changed"))
	sliderC.connect("value_changed", Callable(self, "_on_slider_changed"))
	btnCheck.pressed.connect(Callable(self, "_on_btn_check_pressed"))
	btnCancel.pressed.connect(Callable(self, "_on_btn_cancel_pressed"))

	# Añadir temporizador al nodo
	add_child(limit_timer)
	limit_timer.wait_time = 1.0
	limit_timer.timeout.connect(_on_limit_timer_tick)
	limit_timer.start()

	# Crear etiqueta visual de tiempo
	lbl_timer.text = "⏱️ Tiempo: %.0f s" % time_limit
	lbl_timer.position = Vector2(-50, 150)
	lbl_timer.add_theme_font_size_override("font_size", 22)
	lbl_timer.add_theme_color_override("font_color", Color(1, 0.9, 0.2))
	add_child(lbl_timer)

	_update_labels()

func _on_slider_changed(_v):
	_update_labels()

func _update_labels():
	var L_nH = sliderL.value
	var C_pF = sliderC.value
	lvalue.text = "%.0f nH" % L_nH
	cvalue.text = "%.0f pF" % C_pF
	var L = L_nH * 1e-9
	var C = C_pF * 1e-12
	if C > 0.0:
		var z0 = sqrt(L / C)
		lblZ0.text = "Z₀ = %.1f Ω" % z0
	else:
		lblZ0.text = "Z₀ = —"

func _on_btn_check_pressed():
	var L = sliderL.value * 1e-9
	var C = sliderC.value * 1e-12
	if C <= 0:
		return

	var z0 = sqrt(L / C)
	var diff = abs(z0 - target_z0)
	if diff <= tolerance:
		_play_success_sound()
		result_label.text = "✅ ¡Éxito! Z₀ alineada (%.1f Ω)" % z0
		_end_minigame(true)
	else:
		_play_fail_sound()
		result_label.text = "❌ Fuera de rango (%.1f Ω)" % z0
		_end_minigame(false)

func _on_btn_cancel_pressed():
	# Cancelar manualmente → vuelve al Game principal
	_end_minigame(false)

# ------------------------
# ⏱️ Límite de tiempo
# ------------------------
func _on_limit_timer_tick():
	time_limit -= 1
	lbl_timer.text = "⏱️ Tiempo: %.0f s" % time_limit
	if time_limit <= 0:
		result_label.text = "⌛ ¡Tiempo agotado!"
		_play_fail_sound()
		_end_minigame(false)

# ------------------------
# 🔁 Finalización del minijuego
# ------------------------
func _end_minigame(success: bool):
	# Emitir señal por si es usada por otro nodo
	emit_signal("minigame_completed", success, 100.0 if success else 0.0)

	# Detener temporizador
	if limit_timer:
		limit_timer.stop()

	# Bloquear botones
	btnCheck.disabled = true
	btnCancel.disabled = true
	sliderL.editable = false
	sliderC.editable = false

	# Esperar un breve momento y volver a Game
	await get_tree().create_timer(3.0).timeout
	get_tree().change_scene_to_file("res://Escenas/Game.tscn")

# ------------------------
# 🔊 Sonidos de resultado
# ------------------------
func _play_success_sound() -> void:
	if sfx_player:
		sfx_player.stream = load("res://Sonidos/okay.wav")
		sfx_player.play()
	else:
		print("⚠️ No se encontró el nodo SfxPlayer")

func _play_fail_sound() -> void:
	if sfx_player:
		sfx_player.stream = load("res://Sonidos/error.wav")
		sfx_player.play()
	else:
		print("⚠️ No se encontró el nodo SfxPlayer")

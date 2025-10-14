extends Control
signal minigame_completed(success: bool, reward: float)

@export var target_z0: float = 100.0
@export var tolerance: float = 5.0

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

func _ready():
	lblTarget.text = "Target Z₀: %.1f Ω" % target_z0
	sliderL.connect("value_changed", Callable(self, "_on_slider_changed"))
	sliderC.connect("value_changed", Callable(self, "_on_slider_changed"))
	btnCheck.pressed.connect(Callable(self, "_on_btn_check_pressed"))
	btnCancel.pressed.connect(Callable(self, "_on_btn_cancel_pressed"))
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
	if C <= 0: return
	var z0 = sqrt(L / C)
	var diff = abs(z0 - target_z0)
	if diff <= tolerance:
		_play_success_sound()
		result_label.text = "✅ ¡Éxito! Z₀ alineada (%.1f Ω)" % z0
	else:
		_play_fail_sound()
		result_label.text = "❌ Fuera de rango (%.1f Ω)" % z0

func _on_btn_cancel_pressed():
	queue_free()
	

# ---------- AUDIO (archivos .wav) ----------
func _play_success_sound() -> void:
	if sfx_player:  # Verifica que el nodo exista
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

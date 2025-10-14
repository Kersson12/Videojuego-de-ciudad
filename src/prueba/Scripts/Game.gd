extends Node2D

@onready var ciudad = $Ciudad
@onready var capa2 = ciudad.get_node("Tilemap/Capa 2")
@onready var capa3 = ciudad.get_node("Tilemap/Capa 3")
@onready var timer = Timer.new()

var pulso_actual: Node2D = null
var pulso_esperando_click := false
var minijuegos = [
	"res://Escenas/hangman_game.tscn","res://Escenas/ImpedanceChallenge.tscn","res://Escenas/node_2d.tscn",
	"res://Escenas/quiz_pon.tscn","res://Escenas/SmithMatchGame.tscn"
]

func _ready():
	add_child(timer)
	timer.wait_time = 5.0
	timer.one_shot = true
	timer.connect("timeout", Callable(self, "_on_timer_timeout"))
	timer.start()
	_generar_pulso()

func _generar_pulso():
	if pulso_actual != null:
		return # ya hay un pulso activo

	var posiciones = _obtener_posiciones_de_edificios()
	if posiciones.is_empty():
		return

	var posicion_aleatoria = posiciones[randi() % posiciones.size()]
	var pulso = preload("res://Escenas/PulsoVisual.tscn").instantiate()
	pulso.global_position = posicion_aleatoria
	add_child(pulso)
	pulso_actual = pulso
	pulso_esperando_click = true

	if pulso.has_node("AnimationPlayer"):
		pulso.get_node("AnimationPlayer").play("Pulso")

	pulso.pulso_presionado.connect(_on_pulso_presionado)

func _obtener_posiciones_de_edificios() -> Array:
	var posiciones: Array = []
	for capa in [capa2, capa3]:
		for celda in capa.get_used_cells():
			var pos_mapa = capa.map_to_local(celda)
			var pos_global = capa.to_global(pos_mapa)
			posiciones.append(pos_global)
	return posiciones

func _on_pulso_presionado():
	if not pulso_esperando_click:
		return

	pulso_esperando_click = false

	if pulso_actual:
		pulso_actual.queue_free()
		pulso_actual = null

	# ✅ Escoge una escena de minijuego aleatoria y cambia completamente la escena
	var minijuego = minijuegos[randi() % minijuegos.size()]
	get_tree().change_scene_to_file(minijuego)

func _on_timer_timeout():
	if pulso_actual == null and not pulso_esperando_click:
		_generar_pulso()

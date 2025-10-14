extends Node2D

# Ruta a la escena principal del juego
const GAME_SCENE := "res://Escenas/Game.tscn"

func _ready():
	# Conectar señales de botones
	$VBoxContainer/PlayButton.pressed.connect(_on_play_pressed)
	$VBoxContainer/OptionsButton.pressed.connect(_on_options_pressed)
	$VBoxContainer/QuitButton.pressed.connect(_on_quit_pressed)

func _on_play_pressed():
	var game_scene = load(GAME_SCENE)
	get_tree().change_scene_to_packed(game_scene)

func _on_options_pressed():
	# Más adelante puedes abrir un menú de configuración
	print("Opciones aún no disponibles")

func _on_quit_pressed():
	get_tree().quit()

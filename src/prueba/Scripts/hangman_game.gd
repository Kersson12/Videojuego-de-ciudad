extends Control

@onready var category_label = $VBoxContainer/CategoryLabel
@onready var word_display = $VBoxContainer/WordDisplay
@onready var hint_label = $VBoxContainer/HintLabel
@onready var letters_container = $VBoxContainer/LettersContainer
@onready var attempts_label = $VBoxContainer/AttemptsLabel
@onready var explanation_label = $VBoxContainer/ExplanationLabel
@onready var timer = $Timer

# 🕐 Temporizador para el límite de tiempo
@onready var limit_timer := Timer.new()

# Diccionario de palabras, categorías y pistas
var words_data = {
	"RADAR": {
		"category": "Telecomunicaciones",
		"hint": "Sistema que usa ondas para detectar objetos.",
		"explanation": "Un RADAR envía ondas electromagnéticas y mide el tiempo que tardan en reflejarse, determinando distancia y velocidad."
	},
	"MODEM": {
		"category": "Redes",
		"hint": "Dispositivo que convierte señales digitales en analógicas.",
		"explanation": "El módem modula y demodula señales, permitiendo la comunicación entre computadoras e Internet."
	},
	"FIBRA": {
		"category": "Transmisión",
		"hint": "Medio de transmisión con núcleo de vidrio.",
		"explanation": "La fibra óptica transmite información mediante pulsos de luz a alta velocidad y gran distancia."
	},
	"SATELITE": {
		"category": "Comunicaciones Espaciales",
		"hint": "Objeto en órbita que retransmite señales.",
		"explanation": "Los satélites permiten enlaces globales, transmisión de TV, datos y navegación GPS."
	},
	"ROUTER": {
		"category": "Redes",
		"hint": "Dispositivo que conecta distintas redes.",
		"explanation": "El router dirige paquetes entre redes distintas, gestionando el tráfico mediante tablas de enrutamiento."
	}
}

var current_word = ""
var current_data = {}
var displayed_word = []
var guessed_letters = []
var attempts_left = 6
var max_attempts = 6
var time_limit = 60  # segundos para resolver la palabra

func _ready():
	randomize()
	add_child(limit_timer)
	limit_timer.one_shot = true
	limit_timer.timeout.connect(_on_limit_timer_timeout)
	timer.timeout.connect(_on_timer_timeout)
	start_new_game()

func start_new_game():
	# Seleccionar palabra aleatoria
	var words = words_data.keys()
	current_word = words[randi() % words.size()]
	current_data = words_data[current_word]
	
	# Resetear variables
	displayed_word.clear()
	guessed_letters.clear()
	attempts_left = max_attempts
	
	# Inicializar palabra mostrada
	for i in range(current_word.length()):
		displayed_word.append("_")
	
	# Actualizar UI
	category_label.text = "📚 Categoría: " + current_data["category"]
	hint_label.text = "💡 Pista: " + current_data["hint"]
	hint_label.visible = true
	update_word_display()
	update_attempts_display()
	create_letter_buttons()
	explanation_label.visible = false

	# Iniciar temporizador de límite
	limit_timer.start(time_limit)

func create_letter_buttons():
	for child in letters_container.get_children():
		child.queue_free()
	var alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	for letter in alphabet:
		var button = Button.new()
		button.text = letter
		button.custom_minimum_size = Vector2(45, 45)
		button.pressed.connect(_on_letter_pressed.bind(letter))
		letters_container.add_child(button)

func _on_letter_pressed(letter: String):
	if letter in guessed_letters:
		return
	guessed_letters.append(letter)
	var found = false
	for i in range(current_word.length()):
		if current_word[i] == letter:
			displayed_word[i] = letter
			found = true
	if not found:
		attempts_left -= 1
		update_attempts_display()
	update_word_display()
	disable_letter_button(letter)
	check_game_state()

func disable_letter_button(letter: String):
	for button in letters_container.get_children():
		if button.text == letter:
			button.disabled = true
			if letter in current_word:
				button.modulate = Color(0.5, 1, 0.5) # verde si acierta
			else:
				button.modulate = Color(1, 0.5, 0.5) # rojo si falla

func update_word_display():
	word_display.text = " ".join(displayed_word)

func update_attempts_display():
	var hearts = ""
	for i in range(attempts_left):
		hearts += "❤️"
	for i in range(max_attempts - attempts_left):
		hearts += "🖤"
	attempts_label.text = hearts + "  Vidas: %d/%d" % [attempts_left, max_attempts]

func check_game_state():
	if not "_" in displayed_word:
		show_victory()
	elif attempts_left <= 0:
		show_defeat()

func show_victory():
	_end_game(true)

func show_defeat():
	_end_game(false)

func _end_game(victoria: bool):
	# Detener límite de tiempo
	limit_timer.stop()

	# Desactivar botones
	for button in letters_container.get_children():
		button.disabled = true

	hint_label.visible = false

	if victoria:
		word_display.text = "🎉 ¡CORRECTO! La palabra era: " + current_word
	else:
		word_display.text = "❌ La palabra era: " + current_word

	if explanation_label:
		explanation_label.text = current_data["explanation"]
		explanation_label.visible = true
		explanation_label.custom_minimum_size = Vector2(800, 500)
		explanation_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
		explanation_label.autowrap_mode = TextServer.AUTOWRAP_WORD

	# Esperar unos segundos antes de regresar al juego principal
	timer.start(8.0)

func _on_timer_timeout():
	# 🔁 Cambiar a la escena principal
	get_tree().change_scene_to_file("res://Escenas/Game.tscn")

func _on_limit_timer_timeout():
	# Si el tiempo se acaba, derrota automática
	show_defeat()

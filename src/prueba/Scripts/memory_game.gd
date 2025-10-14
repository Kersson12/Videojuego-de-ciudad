extends Control

@onready var cards_container = $VBoxContainer/GridContainer
@onready var stats_label = $VBoxContainer/Label2
@onready var timer = $Timer

# Precargar la escena de carta
var card_scene = preload("res://Escenas/card.tscn")

# Variables del juego
var card_values = ["LED", "LASER", "FIBRA", "FOTO", "PRISMA", "LENTE"]
var cards = []
var flipped_cards = []
var attempts = 0
var matches = 0

# Temporizador del desafío (segundos máximos)
var total_time = 60  # ⏳ Tiempo límite
var remaining_time = total_time
var time_active = true

# Descripciones educativas de cada componente
var descriptions = {
	"LED": "LED: Diodo emisor de luz. Convierte energía eléctrica en luz para transmitir datos.",
	"LASER": "LÁSER: Fuente de luz coherente y direccional. Ideal para fibra óptica de larga distancia.",
	"FIBRA": "FIBRA ÓPTICA: Cable que transmite luz mediante reflexión total interna.",
	"FOTO": "FOTODETECTOR: Convierte señales de luz en señales eléctricas para procesar datos.",
	"PRISMA": "PRISMA: Separa la luz en diferentes longitudes de onda (colores).",
	"LENTE": "LENTE: Enfoca y dirige los haces de luz en sistemas ópticos."
}

func _ready():
	timer.timeout.connect(_on_timer_timeout)
	setup_game()
	start_countdown()  # ⏱ Inicia el temporizador de límite de tiempo

func setup_game():
	var deck = card_values + card_values
	deck.shuffle()
	
	for i in range(deck.size()):
		var card = card_scene.instantiate()
		cards_container.add_child(card)
		card.setup(deck[i])
		card.card_pressed.connect(_on_card_pressed)
		cards.append(card)
	
	update_stats()

# -----------------------------
# ⏱ LÍMITE DE TIEMPO GLOBAL
# -----------------------------
func start_countdown():
	# Corrutina que cuenta el tiempo sin agregar nodos nuevos
	await get_tree().create_timer(1.0).timeout
	while remaining_time > 0 and matches < card_values.size() and time_active:
		remaining_time -= 1
		stats_label.text = "⏳ Tiempo: %ds | Intentos: %d | Parejas: %d/%d" % [remaining_time, attempts, matches, card_values.size()]
		await get_tree().create_timer(1.0).timeout
	
	# Si el tiempo se acaba antes de completar
	if remaining_time <= 0 and matches < card_values.size():
		time_active = false
		stats_label.text = "❌ Tiempo agotado. Intenta más rápido la próxima vez."
		await get_tree().create_timer(3.0).timeout
		get_tree().change_scene_to_file("res://Escenas/Game.tscn")

# -----------------------------
# 🎮 LÓGICA DE CARTAS
# -----------------------------
func _on_card_pressed(card):
	if flipped_cards.size() >= 2 or not time_active:
		return
	
	card.flip()
	flipped_cards.append(card)
	
	if flipped_cards.size() == 2:
		attempts += 1
		check_match()

func check_match():
	var card1 = flipped_cards[0]
	var card2 = flipped_cards[1]
	
	if card1.card_value == card2.card_value:
		card1.set_matched()
		card2.set_matched()
		matches += 1
		
		var description = descriptions[card1.card_value]
		stats_label.text = "✅ ¡Pareja encontrada! " + description
		flipped_cards.clear()
		
		if matches == card_values.size():
			time_active = false
			timer.start(2.0)
		else:
			await get_tree().create_timer(3.0).timeout
			update_stats()
	else:
		stats_label.text = "❌ No coinciden. Intenta de nuevo..."
		timer.start(1.5)

func _on_timer_timeout():
	if matches == card_values.size():
		show_victory()
	else:
		for card in flipped_cards:
			card.flip_back()
		flipped_cards.clear()
		update_stats()

# -----------------------------
# 🧠 ACTUALIZAR INFO
# -----------------------------
func update_stats():
	stats_label.text = "⏳ Tiempo: %ds | Intentos: %d | Parejas: %d/%d" % [remaining_time, attempts, matches, card_values.size()]

# -----------------------------
# 🏁 FINALIZAR JUEGO
# -----------------------------
func show_victory():
	cards_container.visible = false
	stats_label.add_theme_font_size_override("font_size", 11)
	
	var percentage = (float(card_values.size()) / attempts) * 100
	var used_time = total_time - remaining_time
	
	var victory_message = """🎉 ¡COMPLETADO! 🎉
Intentos: %d (%.1f%% eficiencia)
Tiempo: %ds

━━━━━━━━━━━━━━━━━━━━━━━━━
📡 IMPORTANCIA DE LAS 
COMUNICACIONES ÓPTICAS

🌐 Internet de alta velocidad (>100 Gbps)
💡 Menor pérdida de señal vs. cobre
🔒 Mayor seguridad e inmunidad
🌍 Conectan continentes (99%% tráfico web)
⚡ Menor consumo energético

La fibra óptica es la columna vertebral
de internet, permitiendo streaming,
videollamadas y transferencias masivas
de datos a velocidad de la luz.

¡Gracias por aprender! 📚""" % [attempts, percentage, used_time]
	
	stats_label.text = victory_message
	stats_label.autowrap_mode = TextServer.AUTOWRAP_WORD

	# Esperar 5 segundos antes de volver al juego
	await get_tree().create_timer(5.0).timeout
	get_tree().change_scene_to_file("res://Escenas/Game.tscn")

extends Control

@onready var category_label = $VBoxContainer/CategoryQuestion
@onready var question_label = $VBoxContainer/QuestionLabel
@onready var option_a = $VBoxContainer/VBoxContainer/OptionA
@onready var option_b = $VBoxContainer/VBoxContainer/OptionB
@onready var option_c = $VBoxContainer/VBoxContainer/OptionC
@onready var option_d = $VBoxContainer/VBoxContainer/OptionD
@onready var feedback_label = $VBoxContainer/FeedBackLabel
@onready var progress_label = $VBoxContainer/ProgressLabel
@onready var explanation_panel = $ExplanationPlanel
@onready var explanation_title = $ExplanationPlanel/ExplanationVBox/ExplanationTitle
@onready var explanation_text = $ExplanationPlanel/ExplanationVBox/ExplanationText
@onready var next_button = $ExplanationPlanel/ExplanationVBox/NextButton
@onready var result_panel = $ResultPanel
@onready var result_title = $ResultPanel/ResultVBox/ResultTitle
@onready var score_label = $ResultPanel/ResultVBox/ScoreLabel
@onready var performance_label = $ResultPanel/ResultVBox/PerfomanceLabel
@onready var summary_label = $ResultPanel/ResultVBox/SummaryLabel
@onready var restart_button = $ResultPanel/ResultVBox/RestartButton
@onready var timer = $Timer

var current_question = 0
var score = 0
var questions = []
var selected_answer = -1
var wrong_answers = []

# ⏱ Variables del temporizador global
var total_time = 90 # Tiempo total para completar el quiz
var remaining_time = total_time
var game_active = true

func _ready():
	setup_questions()
	option_a.pressed.connect(_on_option_pressed.bind(0))
	option_b.pressed.connect(_on_option_pressed.bind(1))
	option_c.pressed.connect(_on_option_pressed.bind(2))
	option_d.pressed.connect(_on_option_pressed.bind(3))
	next_button.pressed.connect(_on_next_pressed)
	restart_button.pressed.connect(_on_restart_pressed)
	timer.timeout.connect(_on_timer_timeout)
	show_question()
	start_global_timer() # ⏱ Arranca el temporizador principal

# -----------------------------
# ⏱ TEMPORIZADOR GLOBAL
# -----------------------------
func start_global_timer():
	await get_tree().create_timer(1.0).timeout
	while remaining_time > 0 and game_active:
		remaining_time -= 1
		progress_label.text = "⏳ Tiempo: %ds | Pregunta %d/%d | Correctas: %d" % [remaining_time, current_question + 1, questions.size(), score]
		
		# Si queda poco tiempo, cambiar color
		if remaining_time <= 10:
			progress_label.modulate = Color(1, 0.3, 0.3) # rojo
		else:
			progress_label.modulate = Color(1, 1, 1)
		
		await get_tree().create_timer(1.0).timeout
	
	# Si se acaba el tiempo antes de terminar el quiz
	if remaining_time <= 0 and game_active:
		game_active = false
		show_time_over()

func show_time_over():
	enable_buttons(false)
	feedback_label.text = "⏰ Tiempo agotado. Fin del juego."
	feedback_label.visible = true
	await get_tree().create_timer(3.0).timeout
	get_tree().change_scene_to_file("res://Escenas/Game.tscn")

# -----------------------------
# 🧩 PREGUNTAS
# -----------------------------
func setup_questions():
	questions = [
		{
			"category": "Arquitectura PON",
			"question": "¿Qué significa OLT en redes PON?",
			"options": [
				"Optical Line Terminal",
				"Optical Light Transmitter",
				"Optical Link Technology",
				"Optical Layer Transmission"
			],
			"correct": 0,
			"explanation": """📡 OLT - OPTICAL LINE TERMINAL

La OLT es el equipo activo ubicado en la central del proveedor. Convierte señales eléctricas en ópticas, administra las ONUs y distribuye el tráfico PON.

💡 Es el cerebro de la red, controlando el acceso de todos los usuarios."""
		},
		{
			"category": "Equipos de Usuario",
			"question": "¿Cuál es la diferencia principal entre ONT y ONU?",
			"options": [
				"No hay diferencia, son el mismo dispositivo",
				"ONT termina en el hogar, ONU puede estar en un armario",
				"ONU es para empresas, ONT para hogares",
				"ONT usa GPON, ONU usa EPON"
			],
			"correct": 1,
			"explanation": """🏠 ONT vs ONU

ONT está dentro del hogar (FTTH), mientras la ONU puede ubicarse fuera, en gabinetes o edificios (FTTB).

💡 Todo ONT es una ONU, pero no toda ONU es ONT."""
		},
		{
			"category": "Estándares PON",
			"question": "¿Qué velocidad de downstream ofrece GPON?",
			"options": [
				"1.25 Gbps",
				"2.5 Gbps",
				"10 Gbps",
				"100 Mbps"
			],
			"correct": 1,
			"explanation": """⚡ GPON - G.984

- Downstream: 2.5 Gbps
- Upstream: 1.25 Gbps

💡 El ancho de banda se comparte entre todas las ONTs del mismo puerto."""
		},
		{
			"category": "Arquitectura PON",
			"question": "¿Qué componente pasivo divide la señal en una red PON?",
			"options": [
				"Switch óptico",
				"Splitter óptico",
				"Amplificador óptico",
				"Multiplexor WDM"
			],
			"correct": 1,
			"explanation": """🔀 SPLITTER ÓPTICO

Divide la señal óptica sin energía eléctrica.

Ratios comunes: 1:8, 1:16, 1:32, 1:64  
💡 La “P” de PON viene de estos dispositivos pasivos."""
		},
		{
			"category": "WDM - Multiplexación",
			"question": "En GPON, ¿qué longitud de onda se usa para downstream?",
			"options": [
				"1310 nm",
				"1490 nm",
				"1550 nm",
				"1625 nm"
			],
			"correct": 1,
			"explanation": """🌈 LONGITUDES DE ONDA EN GPON

1490 nm → Downstream  
1310 nm → Upstream  
1550 nm → Video  
1625 nm → Monitoreo"""
		},
		{
			"category": "Distancias y Alcance",
			"question": "¿Cuál es la distancia máxima típica en GPON?",
			"options": [
				"10 km",
				"20 km",
				"40 km",
				"100 km"
			],
			"correct": 1,
			"explanation": """📏 ALCANCE EN GPON

La distancia máxima típica es de 20 km.  
Depende de pérdidas por fibra, conectores y el tipo de splitter.

💡 En entornos urbanos se usan tramos de 5 a 15 km."""
		},
		{
			"category": "Comparación de Tecnologías",
			"question": "¿Qué estándar PON ofrece 10 Gbps simétrico?",
			"options": [
				"GPON",
				"EPON",
				"XG-PON",
				"XGS-PON"
			],
			"correct": 3,
			"explanation": """🚀 XGS-PON

10 Gbps simétrico (10G/10G).  
Ideal para servicios empresariales y 5G backhaul."""
		},
		{
			"category": "Conceptos Técnicos",
			"question": "¿Qué es DBA en el contexto de redes PON?",
			"options": [
				"Database Administrator",
				"Dynamic Bandwidth Allocation",
				"Digital Broadband Access",
				"Downstream Bandwidth Amplification"
			],
			"correct": 1,
			"explanation": """⚙️ DBA

Dynamic Bandwidth Allocation distribuye el ancho de banda según la demanda de cada ONT."""
		},
		{
			"category": "Instalación y Deployment",
			"question": "¿Qué split ratio es más común en despliegues FTTH urbanos?",
			"options": [
				"1:8",
				"1:16",
				"1:32",
				"1:64"
			],
			"correct": 2,
			"explanation": """🏙️ SPLIT RATIO

El más común es 1:32, equilibrio entre pérdidas (~17 dB) y número de usuarios."""
		},
		{
			"category": "Troubleshooting",
			"question": "Si una ONT muestra alta pérdida óptica, ¿qué NO es una causa probable?",
			"options": [
				"Conector sucio o dañado",
				"Splitter defectuoso",
				"Fibra doblada con radio pequeño",
				"Configuración incorrecta del VLAN"
			],
			"correct": 3,
			"explanation": """🔧 PÉRDIDAS ÓPTICAS

Causas físicas: conectores, empalmes o dobleces.

❌ VLAN incorrecta no afecta la potencia óptica."""
		}
	]

func show_question():
	if current_question >= questions.size():
		show_results()
		return
	
	var q = questions[current_question]
	category_label.text = "📚 " + q["category"]
	question_label.text = q["question"]
	option_a.text = "A) " + q["options"][0]
	option_b.text = "B) " + q["options"][1]
	option_c.text = "C) " + q["options"][2]
	option_d.text = "D) " + q["options"][3]
	progress_label.text = "⏳ Tiempo: %ds | Pregunta %d/%d | Correctas: %d" % [remaining_time, current_question + 1, questions.size(), score]
	enable_buttons(true)
	feedback_label.visible = false
	explanation_panel.visible = false

func _on_option_pressed(option_index: int):
	if not game_active:
		return
		
	var q = questions[current_question]
	selected_answer = option_index
	enable_buttons(false)
	
	if option_index == q["correct"]:
		score += 1
		feedback_label.text = "✅ ¡CORRECTO!"
		feedback_label.modulate = Color(0.3, 1, 0.3)
		explanation_title.text = "✅ ¡CORRECTO!"
		explanation_title.modulate = Color(0.3, 1, 0.3)
	else:
		feedback_label.text = "❌ INCORRECTO"
		feedback_label.modulate = Color(1, 0.3, 0.3)
		explanation_title.text = "❌ INCORRECTO"
		explanation_title.modulate = Color(1, 0.3, 0.3)
		wrong_answers.append({
			"question_num": current_question + 1,
			"question": q["question"],
			"correct_answer": q["options"][q["correct"]]
		})
	
	feedback_label.visible = true
	timer.start()

func _on_timer_timeout():
	var q = questions[current_question]
	explanation_text.text = q["explanation"]
	explanation_panel.visible = true

func _on_next_pressed():
	current_question += 1
	explanation_panel.visible = false
	show_question()

func enable_buttons(enabled: bool):
	option_a.disabled = !enabled
	option_b.disabled = !enabled
	option_c.disabled = !enabled
	option_d.disabled = !enabled

# -----------------------------
# 🎯 RESULTADOS
# -----------------------------
func show_results():
	if not game_active:
		return
	
	game_active = false
	result_panel.visible = true
	var percentage = (float(score) / questions.size()) * 100
	score_label.text = "Puntaje: %d/%d (%.0f%%)" % [score, questions.size(), percentage]
	
	var evaluation = ""
	if score >= 9:
		evaluation = "🌟 ¡EXCELENTE! Eres un experto en PON"
	elif score >= 7:
		evaluation = "⭐ ¡MUY BIEN! Tienes sólidos conocimientos"
	elif score >= 5:
		evaluation = "👍 BIEN - Conocimiento básico sólido"
	elif score >= 3:
		evaluation = "📚 REGULAR - Necesitas repasar algunos temas"
	else:
		evaluation = "📖 Estudia los fundamentos de PON"
	
	performance_label.text = evaluation
	
	if wrong_answers.size() > 0:
		var summary = "💡 PREGUNTAS INCORRECTAS:\n\n"
		for error in wrong_answers:
			summary += "❌ Pregunta %d:\n%s\n✅ Respuesta correcta: %s\n\n" % [error["question_num"], error["question"], error["correct_answer"]]
		summary_label.text = summary
	else:
		summary_label.text = "🎉 ¡PERFECTO! Respondiste todas correctamente.\n\nDominas completamente los conceptos de redes PON, WDM y FTTH."

	# Espera 5 segundos y vuelve al juego
	await get_tree().create_timer(5.0).timeout
	get_tree().change_scene_to_file("res://Escenas/Game.tscn")

func _on_restart_pressed():
	current_question = 0
	score = 0
	wrong_answers = []
	result_panel.visible = false
	game_active = true
	remaining_time = total_time
	show_question()
	start_global_timer()

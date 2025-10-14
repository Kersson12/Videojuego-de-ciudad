extends Control

@onready var category_label = $VBoxContainer/CategoryLabel
@onready var word_display = $VBoxContainer/WordDisplay
@onready var hint_label = $VBoxContainer/HintLabel
@onready var letters_container = $VBoxContainer/LettersContainer
@onready var attempts_label = $VBoxContainer/AttemptsLabel
@onready var explanation_label = $VBoxContainer/ExplanationLabel
@onready var timer = $Timer

# Palabras y sus datos
var words_data = {
	"SNELL": {
		"category": "Leyes Fundamentales",
		"hint": "Ley que relaciona ángulos de incidencia y refracción",
		"explanation": """
📐 LEY DE SNELL

La Ley de Snell describe cómo se comporta la luz al 
pasar de un medio a otro con diferente índice de 
refracción.

🔬 FÓRMULA:
n₁ × sen(θ₁) = n₂ × sen(θ₂)

Donde:
- n₁, n₂ = índices de refracción de cada medio
- θ₁ = ángulo de incidencia
- θ₂ = ángulo de refracción

💡 IMPORTANCIA:
Esta ley es fundamental para entender cómo funciona
la fibra óptica, lentes, prismas y todo dispositivo
óptico. Permite calcular la trayectoria de la luz.

🌟 APLICACIÓN:
En fibra óptica, la Ley de Snell explica cómo la luz
se mantiene dentro del núcleo mediante reflexión total
interna cuando el ángulo supera el ángulo crítico.
"""
	},
	"REFLEXION": {
		"category": "Fenómenos Ópticos",
		"hint": "Fenómeno que mantiene la luz dentro de la fibra óptica",
		"explanation": """
🔄 REFLEXIÓN TOTAL INTERNA

Es el fenómeno que ocurre cuando la luz viajando por
un medio más denso (mayor índice de refracción) alcanza
la interfaz con un medio menos denso en un ángulo mayor
al ángulo crítico.

⚡ CONDICIONES:
1. La luz debe ir del medio más denso al menos denso
2. El ángulo debe ser mayor que el ángulo crítico
3. Se refleja el 100% de la luz (sin pérdidas)

🎯 PRINCIPIO DE FUNCIONAMIENTO:
Cuando θ > θc (ángulo crítico), la luz no puede 
refractarse y se refleja completamente hacia el 
interior del medio más denso.

💎 APLICACIONES:
- Fibra óptica: mantiene la señal sin pérdidas
- Prismas en binoculares
- Diamantes (brillo característico)
- Guías de onda ópticas

🌐 EN FIBRA ÓPTICA:
La luz "rebota" continuamente en las paredes del 
núcleo, viajando largas distancias sin salir del cable.
"""
	},
	"CRITICO": {
		"category": "Ángulos Importantes",
		"hint": "Ángulo mínimo para que ocurra reflexión total interna",
		"explanation": """
📏 ÁNGULO CRÍTICO

Es el ángulo de incidencia mínimo necesario para que
ocurra reflexión total interna. Por debajo de este
ángulo, parte de la luz se refracta; por encima,
se refleja completamente.

🔬 FÓRMULA:
θc = arcsen(n₂/n₁)

Donde:
- θc = ángulo crítico
- n₁ = índice del medio más denso (núcleo)
- n₂ = índice del medio menos denso (revestimiento)

📊 EJEMPLO PRÁCTICO:
Para fibra óptica de vidrio:
- Núcleo: n₁ = 1.48
- Revestimiento: n₂ = 1.46
- θc ≈ 80.6°

⚠️ IMPORTANCIA:
Determina el diseño de la fibra óptica. Los fabricantes
ajustan los índices de refracción para controlar el
ángulo crítico y optimizar la transmisión.

🎯 CONCEPTO CLAVE:
Si θ < θc → Parte de luz se escapa (refracción)
Si θ > θc → Reflexión total (ideal para transmisión)
"""
	},
	"ACEPTACION": {
		"category": "Ángulos Importantes",
		"hint": "Determina el cono de luz que puede entrar a la fibra",
		"explanation": """
🎯 ÁNGULO DE ACEPTACIÓN

Es el ángulo máximo con respecto al eje de la fibra
con el que un rayo de luz puede incidir en la entrada
y aún así propagarse por reflexión total interna.

🔬 FÓRMULA:
θa = arcsen(NA)

Donde NA es la Apertura Numérica:
NA = √(n₁² - n₂²)

📐 COMPONENTES:
- θa = ángulo de aceptación
- n₁ = índice del núcleo
- n₂ = índice del revestimiento

💡 CONCEPTO:
Define un "cono de aceptación". Solo la luz que entra
dentro de este cono se propagará correctamente por la
fibra óptica.

🎪 VISUALIZACIÓN:
Imagina un cono invisible en la entrada de la fibra.
La luz debe entrar dentro de este cono para viajar
eficientemente.

📊 IMPORTANCIA PRÁCTICA:
- Diseño de conectores y acopladores
- Eficiencia de acoplamiento luz-fibra
- Determina cuánta luz de una fuente (LED/Láser) 
  entrará efectivamente en la fibra

⚙️ APERTURA NUMÉRICA (NA):
Valores típicos: 0.1 - 0.5
- NA alta: acepta más luz, pero más dispersión
- NA baja: más selectivo, mejor para largas distancias
"""
	},
	"REFRACCION": {
		"category": "Fenómenos Ópticos",
		"hint": "Cambio de dirección de la luz al cambiar de medio",
		"explanation": """
🌈 REFRACCIÓN

Es el cambio de dirección que experimenta la luz al
pasar de un medio a otro con diferente índice de
refracción debido al cambio en su velocidad.

⚡ CAUSA FÍSICA:
La luz viaja a diferentes velocidades en diferentes
materiales. Al cambiar de medio, cambia su dirección
(excepto en incidencia perpendicular).

🔬 RELACIÓN CON LEY DE SNELL:
La refracción sigue la Ley de Snell:
n₁ × sen(θ₁) = n₂ × sen(θ₂)

📊 COMPORTAMIENTO:
- Medio menos denso → más denso: luz se acerca a la normal
- Medio más denso → menos denso: luz se aleja de la normal

🎨 EJEMPLOS COTIDIANOS:
- Lápiz "quebrado" en un vaso de agua
- Espejismos en carreteras calientes
- Arcoíris (refracción en gotas de agua)
- Lentes correctivas

🔬 EN COMUNICACIONES ÓPTICAS:
- Base del funcionamiento de lentes y prismas
- Permite enfocar luz en fibras ópticas
- Determina el diseño de acopladores
- Relacionado con dispersión cromática

⚠️ DISPERSIÓN:
Diferentes longitudes de onda (colores) se refractan
en ángulos ligeramente diferentes, causando dispersión
cromática en fibras ópticas.
"""
	},
	"APERTURA": {
		"category": "Parámetros de Fibra",
		"hint": "Parámetro que indica la capacidad de captación de luz",
		"explanation": """
🎪 APERTURA NUMÉRICA (NA)

Es un parámetro adimensional que caracteriza la
capacidad de una fibra óptica para captar luz.
Está directamente relacionada con el ángulo de
aceptación.

🔬 FÓRMULA:
NA = √(n₁² - n₂²) = sen(θa)

Donde:
- n₁ = índice de refracción del núcleo
- n₂ = índice del revestimiento
- θa = ángulo de aceptación

📊 RANGO DE VALORES:
- Fibra multimodo: NA = 0.2 - 0.5
- Fibra monomodo: NA = 0.1 - 0.14

⚖️ COMPROMISO DE DISEÑO:

📈 NA ALTA (>0.3):
✅ Acepta más luz (fácil acoplamiento)
✅ Menos crítico en alineación
❌ Mayor dispersión modal
❌ Limitada a cortas distancias

📉 NA BAJA (<0.2):
✅ Menor dispersión
✅ Mayor ancho de banda
✅ Largas distancias
❌ Acoplamiento más crítico

💡 INTERPRETACIÓN FÍSICA:
Una NA de 0.3 significa que la fibra acepta un cono
de luz con semi-ángulo de ~17.5°

🎯 APLICACIONES:
- Diseño de sistemas de acoplamiento
- Selección de fuentes de luz (LED vs Láser)
- Cálculo de pérdidas por acoplamiento
- Optimización de conectores

🔧 EN LA PRÁCTICA:
Los fabricantes optimizan NA según la aplicación:
- Redes locales: NA más alta
- Larga distancia: NA más baja
"""
	}
}

var current_word = ""
var current_data = {}
var displayed_word = []
var guessed_letters = []
var attempts_left = 6
var max_attempts = 6

func _ready():
	timer.timeout.connect(_on_timer_timeout)
	start_new_game()

func start_new_game():
	# Seleccionar palabra aleatoria
	var words = words_data.keys()
	current_word = words[randi() % words.size()]
	current_data = words_data[current_word]
	
	# Resetear variables
	displayed_word = []
	guessed_letters = []
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

func create_letter_buttons():
	# Limpiar botones existentes
	for child in letters_container.get_children():
		child.queue_free()
	
	# Crear botones para cada letra del alfabeto
	var alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	for letter in alphabet:
		var button = Button.new()
		button.text = letter
		button.custom_minimum_size = Vector2(45, 45)
		button.pressed.connect(_on_letter_pressed.bind(letter))
		letters_container.add_child(button)

func _on_letter_pressed(letter: String):
	# Evitar letras ya usadas
	if letter in guessed_letters:
		return
	
	guessed_letters.append(letter)
	
	# Buscar letra en la palabra
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
	
	# Verificar victoria o derrota
	check_game_state()

func disable_letter_button(letter: String):
	for button in letters_container.get_children():
		if button.text == letter:
			button.disabled = true
			if letter in current_word:
				button.modulate = Color(0.5, 1, 0.5)  # Verde
			else:
				button.modulate = Color(1, 0.5, 0.5)  # Rojo

func update_word_display():
	word_display.text = " ".join(displayed_word)

func update_attempts_display():
	var hearts = ""
	for i in range(attempts_left):
		hearts += "❤️"
	for i in range(max_attempts - attempts_left):
		hearts += "🖤"
	attempts_label.text = hearts + " Vidas: %d/%d" % [attempts_left, max_attempts]

func check_game_state():
	# Verificar victoria
	if not "_" in displayed_word:
		show_victory()
	# Verificar derrota
	elif attempts_left <= 0:
		show_defeat()

func show_victory():
	# Deshabilitar todos los botones
	for button in letters_container.get_children():
		button.disabled = true
	
	# Mostrar palabra y ocultar pista
	word_display.text = "🎉 ¡CORRECTO! La palabra era: " + current_word
	hint_label.visible = false
	
	# Configurar explanation_label para mejor visualización
	if explanation_label:
		explanation_label.text = current_data["explanation"]
		explanation_label.visible = true
		# Asegurar que use todo el espacio disponible
		explanation_label.custom_minimum_size = Vector2(800, 500)
		explanation_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
		explanation_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	
	# Esperar más tiempo para leer con calma
	timer.start(25.0)  # 25 segundos para leer la explicación

func show_defeat():
	# Deshabilitar todos los botones
	for button in letters_container.get_children():
		button.disabled = true
	
	# Mostrar palabra correcta
	word_display.text = "❌ La palabra era: " + current_word
	hint_label.visible = false
	
	# Mostrar explicación (educativo incluso al perder)
	if explanation_label:
		explanation_label.text = current_data["explanation"]
		explanation_label.visible = true
		# Configurar para mejor visualización
		explanation_label.custom_minimum_size = Vector2(800, 500)
		explanation_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
		explanation_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	
	# Esperar más tiempo para leer
	timer.start(25.0)  # 25 segundos

func _on_timer_timeout():
	# Reiniciar juego
	hint_label.visible = true
	start_new_game()

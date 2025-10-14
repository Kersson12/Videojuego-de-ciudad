extends Area2D

signal pulso_presionado

@onready var anim = $AnimationPlayer

func _ready():
	if anim:
		anim.play("Pulso") # reproduce la animación cada vez que aparece
	connect("input_event", Callable(self, "_on_input_event"))

func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		emit_signal("pulso_presionado")

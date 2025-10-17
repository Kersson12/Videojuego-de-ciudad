extends Node2D

func _ready():
	# Esto evita que se borre al cambiar de escena
	set_process(false)
	get_tree().get_root().add_child(self)
	self.owner = null

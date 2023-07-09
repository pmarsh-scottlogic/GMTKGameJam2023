extends RigidBody2D

# Called when the node enters the scene tree for the first time.
func _ready():
	gravity_scale = 0
	await get_tree().create_timer(0.5).timeout
	gravity_scale = 1

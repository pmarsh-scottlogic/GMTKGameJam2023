extends RigidBody2D

# Speed cap for adding force
var maxForce: float = 1500

# Multiplier for magnitude
var magnitudeMultiplier: float = 2

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _addPlayerForce(force: Vector2):
	apply_impulse(force)

func _input(event):
	if event is InputEventMouseButton and !event.pressed:
		var launch: Vector2 = (self.position - get_global_mouse_position()).normalized()
		var magnitude: float = (self.position - get_global_mouse_position()).length()
		magnitude *= magnitudeMultiplier
		if magnitude > maxForce:
			magnitude = maxForce
		_addPlayerForce(launch * magnitude)

extends RigidBody2D

# Speed cap for adding force
var maxForce: float = 810

# Multiplier for magnitude
var magnitudeMultiplier: float = 12

# Mouse held position
var mouseHeld: bool = false

@onready var line := $Line2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if mouseHeld:
		line.show()
		line.points[0] = to_local(self.position)
		line.points[1] = to_local(get_global_mouse_position())

func _addPlayerForce(force: Vector2):
	self.linear_velocity = Vector2.ZERO
	apply_impulse(force)

func _input(event):
	if event is InputEventMouseButton and !event.pressed:
		mouseHeld = false
		var launch: Vector2 = (self.position - get_global_mouse_position()).normalized()
		var magnitude: float = (self.position - get_global_mouse_position()).length()
		magnitude *= magnitudeMultiplier
		if magnitude > maxForce:
			magnitude = maxForce
		_addPlayerForce(launch * magnitude)
		line.hide()
	elif event is InputEventMouseButton and event.pressed:
		mouseHeld = true
			

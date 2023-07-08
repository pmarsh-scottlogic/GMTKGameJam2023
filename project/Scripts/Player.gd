extends RigidBody2D

# Speed cap for adding force
var maxForce: float = 750

# Multiplier for magnitude
var magnitudeMultiplier: float = 2

# Mouse held position
var mouseHeld: bool = false

var mainNode: Node2D

var arrowScene: PackedScene = preload("res://Scenes/arrow.tscn")

# The Indicator Arrow
@onready var line := $Line2D

# Called when the node enters the scene tree for the first time.
func _ready():
	mainNode = get_tree().get_root().get_node("MainNode")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if mouseHeld:
		_showLine()

func _showLine():
	line.show()
	line.points[0] = to_local(self.position)
	var magnitude: float = (get_global_mouse_position() - self.position).length()
	if magnitude > maxForce:
		var direction: Vector2 = (get_global_mouse_position() - self.position).normalized()
		line.points[1] = to_local(self.position + (direction * maxForce))
	else:
		line.points[1] = to_local(get_global_mouse_position())

func _addPlayerForce(force: Vector2):
	apply_impulse(force)
	_spawnArrow()

func _spawnArrow():
	var newArrow = arrowScene.instantiate()
	newArrow.position = self.position
	mainNode.add_child(newArrow)
	

func _input(event):
	if event is InputEventMouseButton and !event.pressed:
		mouseHeld = false
		var direction: Vector2 = (get_global_mouse_position() - self.position).normalized()
		var magnitude: float = (get_global_mouse_position() - self.position).length()
		if magnitude > maxForce:
			magnitude = maxForce
		magnitude *= magnitudeMultiplier
		_addPlayerForce(direction * magnitude)
		line.hide()
	elif event is InputEventMouseButton and event.pressed:
		mouseHeld = true
			

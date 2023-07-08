extends RigidBody2D

# Speed cap for adding force
@export var maxForce: float = 810

# Multiplier for magnitude
@export var forceMagnitudeMultiplier: float = 12

# Mouse held position
var mouseHeld: bool = false

# Time slowdown proportional speed
@export var timeSLowProportion : float = 0.1

@export var arrows: int = 10

@export var airbourne: bool

# The Indicator Arrow
@onready var line := $Line2D

# Sound players
@onready var shootSoundPlayer := $soundPlayers/shootSoundPlayer
@onready var landSoundPlayer := $soundPlayers/landSoundPlayer


var mainNode: Node2D

var arrowScene: PackedScene = preload("res://Scenes/arrow.tscn")

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

func _playerArrowLaunch(force: Vector2):
	if arrows == 0:
		return
	self.linear_velocity = Vector2.ZERO
	apply_impulse(force)
	_spawnArrow()
	arrows -= 1

func _spawnArrow():
	var newArrow = arrowScene.instantiate()
	newArrow.position = self.position
	mainNode.add_child(newArrow)

func _input(event):
	if event is InputEventMouseButton and !event.pressed:
		mouseHeld = false
		var launch: Vector2 = (get_global_mouse_position() - self.position).normalized()
		var magnitude: float = (get_global_mouse_position() - self.position).length()
		if magnitude > maxForce:
			magnitude = maxForce
		magnitude *= forceMagnitudeMultiplier
		_playerArrowLaunch(launch * magnitude)
		line.hide()
		Engine.time_scale = 1
		shootSoundPlayer.play()
	elif event is InputEventMouseButton and event.pressed:
		mouseHeld = true
		Engine.time_scale = timeSLowProportion

func _on_body_entered(body):
	landSoundPlayer.play()
	print("grounded")
	airbourne = false

func _on_body_exited(body):
	print("airbourne")
	airbourne = true


func _integrate_forces(state):
	print("integrate forces | airbourne: %s" % airbourne)
	if airbourne == false:
		if Input.is_action_pressed("ui_left"):
			print("left")
			apply_impulse(Vector2(-1,0) * 500.0)
		elif Input.is_action_pressed("ui_right"):
			print("right")
			apply_impulse(Vector2(1,0) * 500.0)
	




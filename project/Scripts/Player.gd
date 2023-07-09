extends RigidBody2D

# Speed cap for adding force
@export var maxForce: float = 810

# Multiplier for magnitude
@export var forceMagnitudeMultiplier: float = 12

# Mouse held position
var leftMouseHeld: bool = false

# State for checking if the player is aiming
enum AimStates {IDLE, AIMING}
var aimstate: AimStates = AimStates.IDLE

# Time slowdown proportional speed
@export var timeSlowProportion : float = 0.1

@export var arrows: int = 30

@export var airbourne: bool
@export var lineLengthMultiplier: float = 1

# drawing back the bow takes time
@export var fullDrawbackTime: float = 1
var currentDrawbackTime: float = 0
var drawbackMultiplier: float = 0

var lineAppearanceTimer: float = 0

var visualEnergymultiplier: float = 0

# The Indicator Arrow
@onready var line := get_node("BowArea/Line2D")

# The Arrow
@onready var arrow := $BowArea/Arrow

# The Bow Area
@onready var bowArea := $BowArea

# Sound players
@onready var shootSoundPlayer := $soundPlayers/shootSoundPlayer
@onready var landSoundPlayer := $soundPlayers/landSoundPlayer
@onready var bowDrawSoundPlayer := $soundPlayers/bowDrawSoundPlayer

@onready var launchParticles :  = get_node("BowArea/launchParticles")

var mainNode: Node2D

var arrowScene: PackedScene = preload("res://Scenes/arrow.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	mainNode = get_tree().get_root().get_node("MainNode")
	line.hide()
	arrow.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if aimstate == AimStates.AIMING:
		showLine(delta)
	handleDrawback(delta)
	
func handleDrawback(delta):
	if leftMouseHeld:
		currentDrawbackTime += delta
		drawbackMultiplier = min(currentDrawbackTime / fullDrawbackTime, 1)
		if drawbackMultiplier < 0.7:
			get_node("BowArea/AnimatedSprite2D").frame = 1
		else:
			get_node("BowArea/AnimatedSprite2D").frame = 2
		
func showLine(delta):
	line.show()
	arrow.show()
	line.points[0] = Vector2.ZERO
	var magnitude: float = (get_global_mouse_position() - self.position).length() * drawbackMultiplier
	magnitude = min(magnitude, maxForce) * lineLengthMultiplier
	
	var visualEnergyAppliedAt = 0.6
	var normConst = 1 / (1 - visualEnergyAppliedAt)
	visualEnergymultiplier = max(drawbackMultiplier - visualEnergyAppliedAt, 0) * normConst
	
	var shakeAmount : float =  visualEnergymultiplier * 2
	var shakeOffset := Vector2.UP * sin(lineAppearanceTimer * 800) * shakeAmount
	line.points[1] = Vector2.LEFT * magnitude + shakeOffset
	
	var redness = visualEnergymultiplier
	line.set_modulate(Color(1, 1 - redness / 2, 1 - redness, 1))
	
	lineAppearanceTimer += delta

func playerArrowLaunch(force: Vector2):
	if arrows == 0:
		return
	self.linear_velocity = Vector2.ZERO
	apply_impulse(force)
	spawnArrow()
	arrows -= 1

func spawnArrow():
	var newArrow = arrowScene.instantiate()
	newArrow.position = arrow.global_position
	if(get_global_mouse_position().x > self.get_position().x):
		newArrow.rotation = bowArea.rotation
		newArrow.set_scale(Vector2(-1,1))
	else:
		newArrow.rotation = bowArea.rotation
	
	self.get_owner().add_child(newArrow)

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT :
		if event.pressed:
			leftMouseHeld = true
			arrowAimLogic()
			
		elif !event.pressed:
			leftMouseHeld = false
			launchInputLogic()
			
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT :
		if event.pressed:
			cancelAim()
			bowDrawSoundPlayer.stop()
		elif !event.pressed:
			pass

func _on_body_entered(body):
	landSoundPlayer.play()
	$impactParticles.restart()
	airbourne = false

func _on_body_exited(body):
	airbourne = true

func arrowAimLogic():
	if aimstate != AimStates.IDLE or arrows == 0:
		return
	Engine.time_scale = timeSlowProportion
	bowDrawSoundPlayer.play()
	aimstate = AimStates.AIMING

func launchInputLogic():
	if aimstate != AimStates.AIMING :
		return
	var launch: Vector2 = (get_global_mouse_position() - self.position).normalized()
	var magnitude: float = (get_global_mouse_position() - self.position).length() * drawbackMultiplier
	if magnitude > maxForce:
		magnitude = maxForce
	magnitude *= forceMagnitudeMultiplier
	playerArrowLaunch(launch * magnitude)
	line.hide()
	arrow.hide()
	Engine.time_scale = 1
	shootSoundPlayer.play()
	aimstate = AimStates.IDLE
	currentDrawbackTime = 0;
	drawbackMultiplier = 0;
	launchParticles.restart()
	bowDrawSoundPlayer.stop()
	get_node("BowArea/AnimatedSprite2D").frame = 0

func cancelAim():
	if aimstate != AimStates.AIMING:
		return
	Engine.time_scale = 1
	aimstate = AimStates.IDLE
	line.hide()
	arrow.hide()

func _integrate_forces(state):
	if airbourne == false:
		if Input.is_action_pressed("ui_left"):
			apply_impulse(Vector2.LEFT * 200.0)
		elif Input.is_action_pressed("ui_right"):
			apply_impulse(Vector2.RIGHT * 200.0)

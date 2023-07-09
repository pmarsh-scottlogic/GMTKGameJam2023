extends RigidBody2D

var processCalls = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	print(get_contact_count())
	gravity_scale = 0
	await get_tree().create_timer(0.5).timeout
	gravity_scale = 1
	
func _process(delta):
	processCalls = processCalls + 1
	if processCalls < 3 and get_colliding_bodies().size() > 0:
		print(processCalls)
		print(get_colliding_bodies()[0].name)
		if "TileMap" in get_colliding_bodies()[0].name:
			position = (get_node("../Player").position + position) / 2

func _on_body_entered(body):
	$impactSoundPlayer.play()
	pass # Replace with function body.

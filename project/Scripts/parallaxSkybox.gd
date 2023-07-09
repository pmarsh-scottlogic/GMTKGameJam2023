extends TileMap

@onready var camera = get_node("../Camera2D")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position.x = camera.position.x * 0.9
	pass

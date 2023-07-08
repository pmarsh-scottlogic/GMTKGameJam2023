extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(get_global_mouse_position().x > get_parent().get_position().x):
		look_at(get_global_mouse_position())
		self.rotation_degrees
		set_scale(Vector2(-1,1))
	else: 
		look_at(get_global_mouse_position())
		self.rotation_degrees += 180
		set_scale(Vector2(1,1))

	


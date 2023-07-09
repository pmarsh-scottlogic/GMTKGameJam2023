extends Sprite2D

signal gate_reached


var Level1: String = "res://Scenes/Levels/Level1.tscn"
var	Level2: String = "res://Scenes/Levels/Level2.tscn"

var current_level: String = Level1
var next_level: String = Level2

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_area_2d_body_entered(body):
	if body.name == "Player":
		$fanfarePlayer.play()
		gate_reached.emit()
		get_tree().change_scene_to_file(next_level)
		if(current_level==Level1):
			current_level=Level2
			next_level=Level1
		elif(current_level==Level2):
			current_level=Level1
			next_level=Level2

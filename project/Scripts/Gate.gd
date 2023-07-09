extends Sprite2D

signal gate_reached


var introLevel: String = "res://Scenes/Levels/introLevel.tscn"
var Falling: String = "res://Scenes/Levels/Falling.tscn"
var Level1: String = "res://Scenes/Levels/Level1.tscn"
var	Level2: String = "res://Scenes/Levels/Level2.tscn"
var Level3: String = "res://Scenes/Levels/Level3.tscn"

var current_level: String #Name
var next_level: String #Filepath

# Called when the node enters the scene tree for the first time.
func _ready():
	
	print(get_tree().get_current_scene().get_name())
	current_level = get_tree().get_current_scene().get_name()
	pass # Replace with function body.


func _on_area_2d_body_entered(body):
	if body.name == "Player":
		$fanfarePlayer.play()
		gate_reached.emit()
		get_tree().change_scene_to_file(next_level)
		if(current_level==Level1):
			current_level=Level2
		if(current_level==introLevel):
			print("aaaaaaaaaa")
			await get_tree().create_timer(2).timeout
		else:
			$fanfarePlayer.play()
		
		if(current_level=="introLevel"):
			next_level=Falling
		elif(current_level=="Falling"):
			next_level=Level1
		elif(current_level==Level2):
			current_level=Level1
		elif(current_level=="Level1"):
			next_level=Level2
		elif(current_level=="Level2"):
			next_level=Level3
		elif(current_level=="Level3"):
			next_level=Level1
		get_tree().change_scene_to_file(next_level)

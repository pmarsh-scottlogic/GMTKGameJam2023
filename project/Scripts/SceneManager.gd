extends Node

var arrowScene: PackedScene = preload("res://Scenes/arrow.tscn")

var Level1: PackedScene = preload("res://Scenes/Levels/Level1.tscn")
var	Level2: PackedScene = preload("res://Scenes/Levels/Level2.tscn")

var current_level: Node2D
var next_level: PackedScene


func next_level_is(curLevel: PackedScene):
	match current_level:
		Level1:
			next_level = Level2
		Level2:
			next_level = Level1
		_:
			return


# Called when the node enters the scene tree for the first time.
func _ready():
	
	await get_tree().create_timer(1).timeout
	spawn_level(Level1)
	self.get_child(0).find_child("Gate").connect("gate_reached", spawn_level(Level2))
#	await get_tree().create_timer(1).timeout
#	spawnLevel(Level2)



func spawn_level(level):
	print("weewewewewe")
	self.remove_child(current_level)
	var newLevel = level.instantiate()
	self.add_child(newLevel)
	current_level = newLevel
	current_level.position = Vector2(0,0)

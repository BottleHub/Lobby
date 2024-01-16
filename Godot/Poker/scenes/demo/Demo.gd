extends Node2D

var parent = JavaScriptBridge.get_interface("parent")
@onready var lab = $Label
# Called when the node enters the scene tree for the first time.
func _ready():
	if parent:
		parent.modal3.open()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_pressed():
	if parent:
		parent.modal3.open()
		lab.set_text("Godot Running on the Web")

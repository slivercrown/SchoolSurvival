extends Control
var count = 0

func _ready():
	pass # Replace with function body.

func _on_Button_pressed():
	Global.goto_scene("res://SceneFolder/MainScene.tscn")

func _on_Button2_pressed():
	Global.goto_scene("res://SceneFolder/MainScene.tscn")
	
func _on_Button3_pressed():
	if(count %2==0):
		get_node("Explain_sprite").visible = true
		count +=1
	else:
		get_node("Explain_sprite").visible = false
		count +=1

func _on_Button4_pressed():
	pass
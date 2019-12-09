extends Node2D

var num =0
var pos = 0

func start_at(x,y):
	pos = Vector2(x,y)
	$inventory_kan.modulate = Color(1, 1, 1, 0.5)
	
	
func _physics_process(delta):
	set_global_position(pos)
	
func add_item(num):
	if (num==2):
		get_node("item2_gum").show()
		
	
	elif(num==1):
		get_node("item1_tack").show()
		
		
	elif(num==3):
		get_node("item3_glue").show()
		
		
	elif(num==4):
		get_node("item4_eraser").show()
		
		
	
		
func minus_item(num):
	if (num==2):
		get_node("item2_gum").hide()
		
	
	elif(num==1):
		get_node("item1_tack").hide()
		
	
	
func change_item():
	pass
extends RigidBody2D

var velocity = Vector2(250,250)
var liberados = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var collision_info = move_and_collide(velocity * delta)
	
	# if hit then bounce
	if collision_info:
		velocity = velocity.bounce(collision_info.get_normal())
	
		# if hit brick then destroy brick
		if collision_info.get_collider().is_in_group("tijolos"):
			collision_info.get_collider().queue_free()
		elif collision_info.get_collider().is_in_group("chao"):
			print("aaaaaaaaaaa")
			get_tree().change_scene_to_file("res://scenes/cena.tscn") # reset
		if collision_info.get_collider().is_in_group("personagens"):
			collision_info.get_collider().queue_free()
			liberados += 1
			if liberados == 4:
				get_tree().change_scene_to_file("res://scenes/dating_fim.tscn")

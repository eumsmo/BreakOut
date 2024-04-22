extends Window

@export var frame1: Resource
@export var frame2: Resource

var canvas_layer
var no_centro = false
var andando = true
var index = 0

var speed = 12
var animation_speed = 0.2
var screen_size = DisplayServer.screen_get_size()

# Called when the node enters the scene tree for the first time.
func _ready():
	var y = screen_size.y / 2
	y = y + 100
	position.y = y
	
	
	var timer := Timer.new()
	add_child(timer)
	timer.wait_time = 0.2
	timer.start()
	timer.timeout.connect(func():
		if index == 0:
			$CanvasLayer/TextureRect.texture = frame1
			index = 1
		else:
			$CanvasLayer/TextureRect.texture = frame2
			index = 0
	)
	
	canvas_layer = $CanvasLayer


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not no_centro:
		var x = canvas_layer.offset.x
		var y = canvas_layer.offset.y
		x += speed
		canvas_layer.offset = Vector2(x,y)
		
		if x >= 0:
			no_centro = true
	elif andando:
		var x = position.x
		var y = position.y
		x += speed
		position = Vector2(x,y)
		
		if screen_size.x /2 - 250 <= x:
			andando = false
			queue_free()

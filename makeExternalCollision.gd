extends StaticBody2D

@export var diameter : int= 580 # external diameter
@export var segments : int = 40 # num segments

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var points : Array[Vector2] = []
	
	for i in range(segments):
		var angle = i * 2 * PI / segments
		var direction = Vector2(cos(angle), sin(angle))
		points.append(direction * diameter/2)
	
	build_segment(points)
	pass # Replace with function body.

func build_segment(points: Array):
	for i in range(segments):
		var p1 = points[i]
		var p2 = points[(i+1) % segments]
		
		var collision = CollisionShape2D.new()
		var segment = SegmentShape2D.new()
		
		segment.a = p1
		segment.b = p2
		collision.shape = segment
		
		print("made collision in {p1} {p2}".format({"p1": p1, "p2": p2}))
		add_child(collision)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

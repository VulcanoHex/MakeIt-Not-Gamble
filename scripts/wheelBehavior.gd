extends StaticBody2D

@export var diameter : int= 580 # external diameter
@export var outerBoundSegments : int = 40 # num segments
@export var rotationSpeed: float = 0.0
var listaBuche: Array[Marker2D] = []


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	buildOuterCollision()
	generateMarkerForNumbers()
	pass # Replace with function body.

# Builds the outer collision. Creates a series of points and gives it to helper func
func buildOuterCollision()-> void:
	var points : Array[Vector2] = []
	for i in range(outerBoundSegments):
		var angle = i * 2 * PI / outerBoundSegments
		var direction = Vector2(cos(angle), sin(angle))
		points.append(direction * diameter/2)
	
	buildSegment(points)
	
# helper func of buildOuterCollision
func buildSegment(points: Array) -> void:
	for i in range(outerBoundSegments):
		var p1 = points[i]
		var p2 = points[(i+1) % outerBoundSegments]
		
		var collision = CollisionShape2D.new()
		var segment = SegmentShape2D.new()
		
		segment.a = p1
		segment.b = p2
		collision.shape = segment
		
		#print("made collision in {p1} {p2}".format({"p1": p1, "p2": p2}))
		add_child(collision)

# genera proceduralmente 36 Markers di riferimento nel calcolo del
# pathfind della pallina
func generateMarkerForNumbers():
	var buche = 36
	var angoloPerBuca = 2 * PI / buche
	
	var offsetAngle = angoloPerBuca/2
	var offsetPosition = 40
	
	for i in range(buche):
		var angoloBuca = (i * angoloPerBuca) + offsetAngle
		print(angoloBuca)
		
		var xBuca = cos(angoloBuca) * (diameter-offsetPosition*2)/2
		var yBuca = sin(angoloBuca) * (diameter-offsetPosition*2)/2
		
		var nuovaBuca = Marker2D.new()
		nuovaBuca.position = Vector2(xBuca , yBuca )
		nuovaBuca.name = "Buca_" + str(i)
		
		nuovaBuca.set_meta("buca_id", i)
		listaBuche.append(nuovaBuca)
		add_child(nuovaBuca)
		
#		DEBUG REMOVE LATER
		var debugCircle = ColorRect.new()
		debugCircle.size = Vector2(30, 30)
		debugCircle.position = Vector2(-15, -15) 
		debugCircle.color = Color.GREEN
		nuovaBuca.add_child(debugCircle)
#		END DEBUG

func _physics_process(delta: float) -> void:
	rotation += rotationSpeed * delta


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

extends RigidBody2D

@onready var gravity_center: Area2D = $"../Wheel/WheelGravity"
@export var orbital_force: float = 400
@export var clockwise: bool = false
var keyPress: bool = false
var tangentVector: Vector2 = Vector2(0,0)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var gravity_center: Area2D = $"../WheelGravity"
	pass # Replace with function body.


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.is_echo():
		if event.keycode == KEY_X and gravity_center and tangentVector != Vector2.ZERO:
			
			keyPress = (not keyPress)
			sleeping = false
			
			if keyPress:
				print("SIUMMMMM")
			
			#apply_central_force(tangentVector * orbital_force)


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if keyPress:
		print("go")
		state.linear_velocity = tangentVector * 1000



func _physics_process(delta: float) -> void:
	if not gravity_center:
		print("non ho trovato il centro di gravita permanente")
		return
	#else:
		#print("GRAVITA AGGANCIATA")
	var to_Center: Vector2 = gravity_center.global_position - global_position
	var direction: Vector2 = to_Center.normalized()
	
	if clockwise: 
#		se in senso orario ruoto il vettore di 90 gradi (applico trasformazione (x, y) -> (y, x)
		tangentVector = Vector2(direction.y, -direction.x)
	else:
#		se in senso antiorario ruoto il vettore di 90 gradi (applico trasformazione (x, y) -> (y, x)
		tangentVector = Vector2(-direction.y, direction.x)	
#	applico le forze
	#apply_central_impulse(tangent_vector * orbital_force)
		
	
			
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	pass

extends RigidBody2D


@onready var gravityCenter: Area2D = $"../Wheel/WheelGravity"
@onready var wheel: StaticBody2D = $"../Wheel"

#test su buca 15
@onready var target: Marker2D = wheel.listaBuche[18]

# variabili modificabili pathfinding
@export var orbitalSpeed: float = 400.0
@export var orbitalRadius: float = 330.0
@export var regainOrbitMult: float = .8
@export var breakingRad: float = PI/10
@export var clockwise: bool = false

enum State {ORBITING, ARRIVING, STOPPED}
var currentState: State = State.ORBITING


var goToBuca: Signal

var keyPress: bool = false
var tangentVector: Vector2 = Vector2(0,0)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	pass # Replace with function body.


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.is_echo():
		if event.keycode == KEY_X and gravityCenter and tangentVector != Vector2.ZERO:
			
			keyPress = (not keyPress)
			sleeping = false
			
			if keyPress:
				print("SIUMMMMM")
			
			#apply_central_force(tangentVector * orbitalForce)

func targetBuca(nBuca: int, delta:float) -> void:
	pass




func _integrate_forces(phyState: PhysicsDirectBodyState2D) -> void:
	if not gravityCenter:
		print("non ho trovato il centro di gravita permanente")
		return
	
	# variabili per MANTENERE l'orbita
	var toCenter: Vector2 = gravityCenter.global_position - global_position
	
	var currentRadius: float = toCenter.length()
	var radialDirection: Vector2 = toCenter.normalized()
	
	# variabili per BLEND/ARRIVARE all' target
	var currentAngle: float = (global_position - gravityCenter.global_position).angle()
	var targetAngle: float = (target.global_position - gravityCenter.global_position).angle()
	#var deltaAngle: float = posmod(targetAngle - currentAngle + PI, 2*PI) - PI
	var deltaAngle:float = targetAngle - currentAngle
	
	# CALCOLO VETTORE TANGENZIALE 
	# calcola l'errore di orbita, in modo da rientrarci proporzionalmente
	var orbitError: float = currentRadius - orbitalRadius
	var radialVelocity = radialDirection * orbitError * regainOrbitMult
		
	if clockwise: 
		# se in senso orario ruoto il vettore di 90 gradi (applico trasformazione (x, y) -> (y, -x)
		tangentVector = Vector2(radialDirection.y, -radialDirection.x)
	else:
		# se in senso antiorario ruoto il vettore di 90 gradi (applico trasformazione (x, y) -> (-y, x)
		tangentVector = Vector2(-radialDirection.y, radialDirection.x)	
	var tangentVelocity: Vector2 = tangentVector * orbitalSpeed
	
	match currentState:
		State.ORBITING:
			# applico le forze
			phyState.linear_velocity = tangentVelocity + radialVelocity
			
			# DEBUG: FIXLATER aggiungi la condizione in cui abbiamo ricevuto la buca
			if abs(deltaAngle) < breakingRad:
				currentState = State.ARRIVING
		State.ARRIVING:
			var targetVector: Vector2 = target.global_position - global_position
			var targetDistance: float = targetVector.length()
			
			var angleProgress: float = clamp(abs(deltaAngle) / breakingRad, 0, 1.0)
			
			var targetPull:Vector2 = targetVector.normalized() * orbitalSpeed
			
			
			var dynamicDeltaAngle: float = deltaAngle
		
			if clockwise:
			# If moving clockwise, deltaAngle should be positive. 
			# If it's negative, it means we overshot; add a full spin to keep going forward.
				if dynamicDeltaAngle > breakingRad and dynamicDeltaAngle > PI:
					dynamicDeltaAngle += 2.0 * PI
			else:
			# If moving counter-clockwise, deltaAngle should be negative.
			# If it's positive, add a full spin in the negative direction.
				if dynamicDeltaAngle < -breakingRad and dynamicDeltaAngle < -PI:
					dynamicDeltaAngle -= 2.0 * PI
		
			if abs(dynamicDeltaAngle) > breakingRad * 1.5 and targetDistance > 30.0:
				currentState = State.ORBITING
				return
		# Calculate progress based on the corrected directional angle
			angleProgress = clamp(abs(dynamicDeltaAngle) / breakingRad, 0.0, 1.0)
			
			
			var breakingCoefficient: float = 0.75
			print("switched logic ", breakingCoefficient)
			var desiredVelocity: Vector2 = tangentVelocity.lerp(targetPull, 1 - angleProgress)
			
			
			#print(targetVector,angleProgress,desiredVelocity, breakingCoefficient)
			
			if targetDistance < 10.0:
				print(targetVector, targetDistance)
				phyState.linear_velocity = Vector2.ZERO
				currentState = State.STOPPED
			
			# apply breaking
			desiredVelocity *= breakingCoefficient
			#phyState.linear_velocity = targetPull
			phyState.linear_velocity = phyState.linear_velocity.lerp(desiredVelocity, 60.0 * phyState.step)
		State.STOPPED:
			reparent(wheel)
			phyState.linear_velocity = Vector2.ZERO
	
			
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	pass

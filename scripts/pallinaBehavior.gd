extends RigidBody2D


@onready var gravityCenter: Area2D = $"../Wheel/WheelGravity"
@onready var wheel: StaticBody2D = $"../Wheel"

@export var RoundHandler: Node2D
# signal to dest
@onready var goToBuca: Signal = RoundHandler.finalDestination
# TODO signal to orbit
@export var goToOrbit: Signal 

# variabili modificabili pathfinding
@export var orbitalSpeed: float = 400.0
@export var orbitalRadius: float = 330.0
@export var regainOrbitMult: float = 10
# in ambito della frenata dell'orbita della pallina rispettivamente 
# angolo in dopo cui il target e' considerata vicino 
# (CAMBIA QUESTE VARIABILI A TUO RISCHIO E PERICOLO)
@export var breakingRad: float = PI/8
@export var breakingCoefficient: float = 0.75

@export var clockwise: bool = false

enum State {ORBITING, LOCKED, ARRIVING, STOPPED}
var currentState: State = State.ORBITING
var target: Marker2D

var tangentVector: Vector2 = Vector2(0,0)

# Called when the node enters the scene tree for the first time.
# DEBUG
#var indice_buca_corrente = 0
#var tempo_sosta = 2.0
#var timer_sosta = 0.0
# END DEBUG
func _ready() -> void:
	# connect to finalDest 
	goToBuca.connect(handleGoToBuca)
	
	# connect to goToOrbit
	goToOrbit.connect(handleOrbit)
	pass # Replace with function body.

func handleOrbit():
	currentState = State.ORBITING

func handleGoToBuca(numeroBuca: int):
	# set target
	target = wheel.listaBuche[numeroBuca]	
	# set state to Locked in
	currentState = State.LOCKED
	

# La funzione per cui ho bestemmiato
func targetBuca(buca: Marker2D, phyState:PhysicsDirectBodyState2D) -> void:
	if not gravityCenter:
		# Non ho trovato Wheel/WheelGravity
		print("non ho trovato il centro di gravita permanente")
		return
	
	
	# variabili per MANTENERE l'orbita, utili per ORBITING e STOPPED
	# toCenter calcola il vettore "gravita" dato dal centrodi WheelGravity 
	var toCenter: Vector2 = gravityCenter.global_position - global_position
	# Calcolo il raggio e normalizzo il vettore gravita
	var currentRadius: float = toCenter.length()
	var radialDirection: Vector2 = toCenter.normalized()


	# calcola l'errore di orbita, in modo da rientrarci proporzionalmente 
	var orbitError: float = currentRadius - orbitalRadius
	var radialVelocity = radialDirection * orbitError * regainOrbitMult
	
	# CALCOLO VETTORE TANGENZIALE 
	# calcolo il vettore tangente alla gravita ruotando di +/- 90 gradi il vettore gravita
	if clockwise: 
		# se in senso orario ruoto il vettore di 90 gradi (applico trasformazione (x, y) -> (y, -x)
		tangentVector = Vector2(radialDirection.y, -radialDirection.x)
	else:
		# se in senso antiorario ruoto il vettore di 90 gradi (applico trasformazione (x, y) -> (-y, x)
		tangentVector = Vector2(-radialDirection.y, radialDirection.x)	
	
	var tangentVelocity: Vector2 = tangentVector * orbitalSpeed
	
	# Inizio della stateMachine
	match currentState:
		# Non ho ricevuto un target e sto in idle
		State.ORBITING:
			phyState.linear_velocity = tangentVelocity + radialVelocity
			
		# Ho ricevuto un target e orbito finche non sono abbastanza vicino
		State.LOCKED:
			# variabili per ARRIVARE alla buca target
			# Calcolo dell'angolo corrente e dell'angolo target e relativo delta (angolo in radianti dal punto di vista globale)
			var currentAngle: float = (global_position - gravityCenter.global_position).angle()
			var targetAngle: float = (buca.global_position - gravityCenter.global_position).angle()
			var deltaAngle:float = targetAngle - currentAngle
			
			# Applico sia il vettore radiale (fa salire pallina) sia il vettore tangente (la fa muovere in avanti)
			phyState.linear_velocity = tangentVelocity + radialVelocity
			
			# DEBUG: FIXLATER aggiungi la condizione in cui abbiamo ricevuto la buca
			#timer_sosta = tempo_sosta
			# END DEBUG
			if abs(deltaAngle) < breakingRad:
				currentState = State.ARRIVING
		State.ARRIVING:
			# variabili per ARRIVARE alla buca target
			# Calcolo dell'angolo corrente e dell'angolo target e relativo delta (angolo in radianti dal punto di vista globale)
			var currentAngle: float = (global_position - gravityCenter.global_position).angle()
			var targetAngle: float = (buca.global_position - gravityCenter.global_position).angle()
			var deltaAngle:float = targetAngle - currentAngle
			
			# Calcolo il vettore target e la distanza solo quando sono relativamente vicino
			var targetVector: Vector2 = buca.global_position - global_position
			var targetDistance: float = targetVector.length()
			var targetPull:Vector2 = targetVector.normalized() * orbitalSpeed
			
			# Coefficiente da 0 a 1 per il rateo di interpolazione di vettori in base alla vicinanza della pallina al target
			var angleProgress: float = clamp(abs(deltaAngle) / breakingRad, 0, 1.0)
			
			# Creo il mio vettore desiderato interpolando il vettore tangenziale al vettore Target con l'inverso dell'avvicinamento al target
			var desiredVelocity: Vector2 = tangentVelocity.lerp(targetPull, 1 - angleProgress)
			# Freno
			desiredVelocity *= breakingCoefficient
			
			# applico la velocita
			phyState.linear_velocity = phyState.linear_velocity.lerp(desiredVelocity, 69.0 * phyState.step)

			# Se sono arrivato mi fermo e cambio stato in ARRIVED
			if targetDistance < 10.0:
				phyState.linear_velocity = Vector2.ZERO
				currentState = State.STOPPED
			
		State.STOPPED:
			#tangential speed modulo to simulate la ball ferma
			var modulo: float = currentRadius * wheel.rotationSpeed
			var rotationVector = -tangentVector.normalized() * modulo
			#reparent(wheel)
			phyState.linear_velocity = rotationVector
			
			# DEBUG
			## 2. --- LOGICA DEL TIMER DI CONTROLLO ---
			## Riduciamo il tempo rimanente usando il delta time della fisica (phyState.step)
			#timer_sosta -= phyState.step
			#
			## 3. --- CAMBIO DI TARGET ACQUISITO ---
			#if timer_sosta <= 0.0:
				#print("Tempo scaduto! Lascio la buca ", indice_buca_corrente, " e vado alla prossima.")
				#
				## Passiamo alla buca successiva nell'array
				#indice_buca_corrente += 1
				#
				## Riportiamo lo stato a ORBITING. Al prossimo frame, 'buca_attiva' sarà la successiva,
				## e la pallina riprenderà la velocità orbitale piena per raggiungerla.
				#currentState = State.ORBITING
			# END DEBUG
	
		
pass




func _integrate_forces(phyState: PhysicsDirectBodyState2D) -> void:
	targetBuca(target, phyState)

	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	pass

extends RigidBody2D

@onready var gravityCenter: Area2D = $"../Wheel/WheelGravity"
@onready var wheel: StaticBody2D = $"../Wheel"
#@export var soundEffectPlayer: AudioStreamPlayer
@onready var soundEffectPlayer: AudioStreamPlayer = $"../../SoundEffectsPlayer"

@export var tempoSosta = 2.0
var sosta: bool = false

# variabili modificabili pathfinding
@export var orbitalSpeed: float = 400.0
@export var clockwise: bool = false
var orbitalRadius: float = 330.0
var regainOrbitMult: float = 10
# in ambito della frenata dell'orbita della pallina rispettivamente 
# angolo in dopo cui il target e' considerata vicino 
# (CAMBIA QUESTE VARIABILI A TUO RISCHIO E PERICOLO)
var breakingRad: float = PI/8
var breakingCoefficient: float = 0.75

var goodBucaSFX = preload("res://assets/sounds/sfx/Buca/HoleSFX_Good2.wav")
var badBucaSFX = preload("res://assets/sounds/sfx/Buca/HoleSFX_Bad2.wav")

signal iStillStanding
signal myJobHereIsDone

enum State {ORBITING, LOCKED, ARRIVING, STOPPED}
var currentState: State = State.ORBITING
var target: Marker2D
var bucaGiusta: bool

var tangentVector: Vector2 = Vector2(0,0)

var timerSosta = 0.0

func _ready() -> void:
	pass # Replace with function body.

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
			if targetDistance < 9.0:
				phyState.linear_velocity = Vector2.ZERO
				# Carico il timerigno di sosta
				timerSosta = tempoSosta
				iStillStanding.emit()
				currentState = State.STOPPED
			
		State.STOPPED:
			
			#tangential speed modulo to simulate la ball ferma
			var modulo: float = currentRadius * wheel.rotationSpeed
			var rotationVector = -tangentVector.normalized() * modulo
			phyState.linear_velocity = rotationVector

			# Riduciamo il tempo rimanente usando il delta time della fisica (phyState.step)
			timerSosta -= phyState.step		
			
			if timerSosta <= 0 and not sosta:
				# Setto SFX
				changeStateToStopped()
				sosta = true
				if bucaGiusta:
					soundEffectPlayer.stream = goodBucaSFX
				else:
					soundEffectPlayer.stream = badBucaSFX
					
				# Emetto SFX
				soundEffectPlayer.play()
				# Emetto il segnale
				myJobHereIsDone.emit()
				# Siamo pronti a ripartire
				
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
				
				## Riportiamo lo stato a ORBITING. Al prossimo frame, 'buca_attiva' sarà la successiva,
				## e la pallina riprenderà la velocità orbitale piena per raggiungerla.
				#currentState = State.ORBITING
			# END DEBUG
				
	
		
pass

func changeStateToStopped():
	iStillStanding.emit()

func _integrate_forces(phyState: PhysicsDirectBodyState2D) -> void:
	targetBuca(target, phyState)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	pass

func _on_round_manager_final_destination(numeroBuca: int, giusta: bool) -> void:
	# set target
	target = wheel.listaBuche[numeroBuca]	
	# setto flag buca giusta
	bucaGiusta = giusta
	
	# set state to Locked in
	currentState = State.LOCKED
	pass # Replace with function body.

func _on_round_manager_reset_game_objects() -> void:
	currentState = State.ORBITING
	sosta = false
	pass # Replace with function body.

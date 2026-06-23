extends Node2D

# Variabili 1a Fase
@export var board: Node2D
@export var boardMovement: int
@onready var sfxPlayer = $Camera2D/SoundEffectsPlayer

const SFX_board_in = preload("res://assets/sounds/sfx/Board/BoardSFX_enter3.wav")
const SFX_board_out = preload("res://assets/sounds/sfx/Board/BoardSFX_exit3.wav")

signal clearFiches
signal startMinigame 
signal finalDestination

var roundScore = {}    


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	roundHandler()
	pass # Replace with function body.

# Game Logic (Le varie giornate vanno qui)
func gameHandler():
	pass

# Gestisce l'esecuzione ogni Round, si occupa di arbitrare i vari nodi
func roundHandler():
	# Fase 1: Faccio scendere la board
	print("easeIn")
	var mostraBoard: Tween = create_tween()
	sfxPlayer.stream = SFX_board_in
	mostraBoard.tween_callback(sfxPlayer.play)
	mostraBoard.tween_property(board, "position:y", board.position.y + boardMovement, 0.6)\
	.set_trans(Tween.TRANS_SPRING)\
	.set_ease(Tween.EASE_OUT) 
	
	# Fine Fase 1:
	# sul segnale dalla BoardBehavior (dopo targetSelected)  
	# eseguo il tween per spostare la board
	var args = await board.canLeave
	
	print("easeOut ", " a[0]: ", args[0], " a[1]: ", args[1])
	calcScore(args[0], args[1])
	set_meta("target", args[0])
	var rimuoviBoard: Tween = create_tween()
	sfxPlayer.stream = SFX_board_out
	rimuoviBoard.tween_callback(sfxPlayer.play)
	rimuoviBoard.tween_property(board, "position:y", board.position.y - boardMovement, 0.6)\
		.set_trans(Tween.TRANS_SPRING)\
		.set_ease(Tween.EASE_IN)
	

	startMinigame.emit()
	pass # Replace with function body.



	
	# mando un segnale alla board per clearare le fiches quando off screen
	#rimuoviBoard.tween_callback(clearFiches.emit) 
	
	# Fase 2
	pass

func calcScore(idx:int , ficheArr: Array[int]) -> void:
	# calcola lo score e lo manda al round
	var base_score = 0
	var multiplier = 1
	var count = 1
	
	print("ficheArr ", ficheArr, " idx ", idx)
	if ficheArr[idx] != 0:
		base_score = -(ficheArr[idx])
	
	while count<3:
		if ficheArr[(idx+count)%36] != 0:
			print("fichearr[", (idx+count)%36, "] = ", ficheArr[(idx+count)%36])
			base_score += ficheArr[(idx+count)%36]
			multiplier += 1
		if ficheArr[(idx-count)%36] != 0:
			print("fichearr[", (idx-count)%36, "] = ", ficheArr[(idx-count)%36])
			base_score += ficheArr[(idx-count)%36]
			multiplier += 1
		count += 1
	
	print ("base_score: ", base_score)
	print ("mult: ", multiplier)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_rank_meter_end_minigame(score: int) -> void:
	if has_meta("target"):
		var goToTarget = get_meta("target")
		print(goToTarget)
		finalDestination.emit(goToTarget)
	pass # Replace with function body.

extends Node2D

# Variabili 1a Fase
@export var board: Node2D
@export var boardMovement: int
@export var removeBoardSignal: Signal
signal clearFiches


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
	mostraBoard.tween_property(board, "position:y", board.position.y + boardMovement, 0.6)\
	.set_trans(Tween.TRANS_SPRING)\
	.set_ease(Tween.EASE_OUT)	
	# Fine Fase 1:
	# sul segnale dalla BoardBehavior (dopo targetSelected)  
	# eseguo il tween per spostare la board

	#await removeBoardSignal
	#print("easeOut")
	#var rimuoviBoard: Tween = create_tween()
	#rimuoviBoard.tween_property(board, "position:y", board.position.y - boardMovement, 0.6)\
		#.set_trans(Tween.TRANS_SPRING)\
		#.set_ease(Tween.EASE_IN)
	
	# mando un segnale alla board per clearare le fiches quando off screen
	#rimuoviBoard.tween_callback(clearFiches.emit) 
	
	# Fase 2
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

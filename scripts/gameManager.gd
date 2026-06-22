extends Node2D

# Variabili 1a Fase
@export var board: Node2D
@export var boardMovement: int
signal clearFiches

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
	mostraBoard.tween_property(board, "position:y", board.position.y + boardMovement, 0.6)\
	.set_trans(Tween.TRANS_SPRING)\
	.set_ease(Tween.EASE_OUT)	
	# Fine Fase 1:
	# sul segnale dalla BoardBehavior (dopo targetSelected)  
	# eseguo il tween per spostare la board
	var args = await board.canLeave
	
	print("easeOut ", " a[0]: ", args[0], " a[1]: ", args[1])
	calcScore(args[0], args[1])
	var rimuoviBoard: Tween = create_tween()
	rimuoviBoard.tween_property(board, "position:y", board.position.y - boardMovement, 0.6)\
		.set_trans(Tween.TRANS_SPRING)\
		.set_ease(Tween.EASE_IN)
	pass # Replace with function body.



	
	# mando un segnale alla board per clearare le fiches quando off screen
	#rimuoviBoard.tween_callback(clearFiches.emit) 
	
	# Fase 2
	pass

func calcScore(idx:int , ficheArr: Array[int]) -> void:
	# calcola lo score e lo manda al round
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


#func _on_board_can_leave(idx, ficheArr) -> void:

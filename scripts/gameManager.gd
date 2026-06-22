extends Node2D

# Variabili 1a Fase
@export var board: Node2D
@export var boardMovement: int = 1000
@export var removeBoardSignal: Signal
signal clearFiches

var gameManagerTween: Tween = create_tween()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Game Logic (Le varie giornate vanno qui)
func gameHandler():
	pass

# Gestisce l'esecuzione ogni Round, si occupa di arbitrare i vari nodi
func roundHandler():
	# Fase 1: Faccio scenedere la board
	gameManagerTween.tween_property(board, "position.y", Vector2(0, -boardMovement), 0.6)\
	.set_trans(Tween.TRANS_SPRING)\
	.set_ease(Tween.EASE_OUT)	
	# Fine Fase 1:
	# sul segnale dalla BoardBehavior (dopo targetSelected)  
	# eseguo il tween per spostare la board
	removeBoardSignal.connect(func(): 	
		gameManagerTween.tween_property(board, "position.y", Vector2(0, boardMovement), 0.6)\
		.set_trans(Tween.TRANS_SPRING)\
		.set_ease(Tween.EASE_IN)	
	)
	
	# mando un segnale alla board per clearare le fiches quando off screen
	clearFiches.emit()
	
	# Fase 2
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

extends Node2D

#Max Score (setta pure progressbar e hitscores)
@export var maxScore = 500.0
var pScore: float
var gScore: float
var oScore: float
var mScore: float
#Q.ta' di hit in un round
@export var hitQty = 5
#numero massimo di round settati in questa partita
@export var maxRoundNumber = 5
#RST: Round Score Target
@export var RSTatStart = 0.6
@export var RSTatEnd = 0.85
#round corrente
var currRound: int = 0
#Round Score Target attuale
var roundScoreTarget: float

# Variabili 1a Fase
@export var board: Node2D
@export var boardMovement: int
@onready var sfxPlayer = $Camera2D/SoundEffectsPlayer

const SFX_board_in = preload("res://assets/sounds/sfx/Board/BoardSFX_enter3.wav")
const SFX_board_out = preload("res://assets/sounds/sfx/Board/BoardSFX_exit3.wav")

@onready var previewBox: RichTextLabel = $Camera2D/Schermo/TestUI/PreviewPunteggio

signal setAllValues
signal clearFiches
signal startMinigame 
signal finalDestination
signal updateGameState 
signal startNewRound  

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initializeValues()
	#roundScoreTarget = lerp(RSTatStart * maxScore, RSTatEnd * maxScore, currRound / maxRoundNumber)
	#pScore = maxScore / 5
	#gScore = (maxScore / 5) * 0.75
	#oScore = (maxScore / 5) * 0.5
	#mScore = (maxScore / 5) * 0.1
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
	startNewRound.emit()
	
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
	clearFiches.emit()
	pass # Replace with function body.



	
	# mando un segnale alla board per clearare le fiches quando off screen
	#rimuoviBoard.tween_callback(clearFiches.emit) 
	
	# Fase 2
	pass

func calcScore(idx:int , ficheArr: Array[int]) -> void:
	# calcola lo score e lo manda al round
	var base_score = 0
	var multiplier = 0
	var count = 1
	var idxP = 0
	var idxM = 0
	var targetScope: Array[Variant]
	targetScope.resize(7)
	targetScope.fill(0)
	targetScope[3] = {idx: 0}
	
	print("ficheArr ", ficheArr, " idx ", idx)
	if ficheArr[idx] != 0:
		base_score = -(ficheArr[idx])
	
	
	while count<4:
		idxP = posmod(idx + count, 36)
		idxM = posmod(idx - count, 36)

		targetScope[3+count] = {idxP: ficheArr[idxP]}
		targetScope[3-count] = {idxM: ficheArr[idxM]}
		
		if ficheArr[idxP] != 0:
			#print("fichearr[", (idx+count)%36, "] = ", ficheArr[(idx+count)%36])
			base_score += ficheArr[idxP]
			multiplier += 1
			
		if ficheArr[idxM] != 0:
			#print("fichearr[", (idx-count)%36, "] = ", ficheArr[(idx-count)%36])
			base_score += ficheArr[idxM]
			multiplier += 1
		count += 1
		
	set_meta("Scope", targetScope)
	print (targetScope)
	print ("base_score: ", base_score)
	print ("mult: ", multiplier)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func initializeValues():
	currRound += 1
	roundScoreTarget = lerp(RSTatStart * maxScore, RSTatEnd * maxScore, (currRound - 1) / maxRoundNumber)
	if currRound == 1:
		pScore = maxScore / 5
		gScore = (maxScore / 5) * 0.75
		oScore = (maxScore / 5) * 0.5
		mScore = (maxScore / 5) * 0.1
		setAllValues.emit()
	pass

func calcFinalDestination(scope: Array, score: float) -> int:
	var rng = RandomNumberGenerator.new()
	var weightArr: Array[float]
	weightArr.resize(7)
	weightArr.fill(0)
	
	var tchoice = scope[3]
	
	print(scope)
	scope.sort_custom(
		func(a:Dictionary, b:Dictionary):
			if a == tchoice:
				return true
			if b == tchoice:
				return false
			else:
				return a.values()[0] < b.values()[0]
	)
	print(scope)
	
	var proportion = remap(score, mScore * hitQty, roundScoreTarget, 0.0, 1.0)
	var bellCentre = 1 - proportion
	print (proportion)
	if proportion == 0.0:
		weightArr.fill(0.0)
		weightArr[weightArr.size()-1] = 1.0
	else:
		for i in range(weightArr.size()):
			var t: float = float(i) / (weightArr.size() - 1)
			var distance = (t - bellCentre)
			weightArr[i] = max(1.0 - (distance * distance), 0.001)
	print (weightArr)
	
	return scope[rng.rand_weighted(weightArr)].keys()[0]
	pass
	
func _on_rank_meter_end_minigame(score: float) -> void:
	if has_meta("Scope"):
		print("score: ", score, ". RTS: ", roundScoreTarget)
		var targetScope = get_meta("Scope")
		var tchoice = targetScope[3].keys()[0]
		var mgResult: int
		if score >= roundScoreTarget:
			mgResult = targetScope[3].keys()[0]
		else:
			mgResult = calcFinalDestination(targetScope, score)
		finalDestination.emit(mgResult, true if tchoice == mgResult else false)
		
		updateGameState.emit(targetScope, mgResult, true if tchoice == mgResult else false)
		
	pass # Replace with function body.

func _on_board_show_preview_from_board(idx: int, ficheArr: Array) -> void:
	var base_score = 0
	var multiplier = 0
	var count = 1
	var idxP = 0
	var idxM = 0
	
	if ficheArr[idx] != 0:
		base_score = -(ficheArr[idx])
		
	while count<4:
		idxP = posmod(idx + count, 36)
		idxM = posmod(idx - count, 36)
		
		if ficheArr[idxP] != 0:
			#print("fichearr[", (idx+count)%36, "] = ", ficheArr[(idx+count)%36])
			base_score += ficheArr[idxP]
			multiplier += 1
			
		if ficheArr[idxM] != 0:
			#print("fichearr[", (idx-count)%36, "] = ", ficheArr[(idx-count)%36])
			base_score += ficheArr[idxM]
			multiplier += 1
		count += 1
		
	previewBox.text = " Base: {base} Mult: {mult}".format({
		"base": base_score,
		"mult": multiplier
	})
	pass # Replace with function body.


func _on_game_manager_start_new_round() -> void:
	initializeValues()
	roundHandler()
	pass # Replace with function body.

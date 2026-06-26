extends Node2D

#Max Score (setta pure progressbar e hitscores)
@export var maxScore = 500.0
@export var pScore: float = 1.0
@export var gScore: float = 0.75
@export var oScore: float = 0.5
@export var mScore: float = 0.2
#Q.ta' di hit in un round
@export var hitQty = 5
#RST: Round Score Target
@export var RSTatStart = 0.6
@export var RSTatEnd = 0.85
#round corrente
var currRound: int = 0
var maxRoundNumber: int
#Round Score Target attuale
var roundScoreTarget: float
var base_score: int = 0
var multiplier: int = 0

var valuesFlag = true

# Variabili 1a Fase
@export var board: Node2D
@onready var sfxPlayer = $Camera2D/SoundEffectsPlayer
@export var timerBoard: float = .4

@onready var previewBox: RichTextLabel = $Camera2D/Schermo/TestUI/PreviewPunteggio
@onready var roundBox: RichTextLabel = $Camera2D/Schermo/TestUI/BaseUI/LayerRo/RoundRealDx
@onready var baseBox: RichTextLabel = $Camera2D/Schermo/TestUI/BaseUI/LayerPSc/PrScoreRealBase
@onready var multBox: RichTextLabel = $Camera2D/Schermo/TestUI/BaseUI/LayerPSc/PrScoreRealMult

signal setAllValues
signal clearFiches
signal startMinigame 
signal finalDestination
signal updateGameState 
signal resetGameObjects  

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Game Logic (Le varie giornate vanno qui)
func gameHandler():
	pass

# Gestisce l'esecuzione ogni Round, si occupa di arbitrare i vari nodi
func roundHandler(isFirstRoundOfPlay: bool):
	# Fase 1: Faccio scendere la board
	print("creating timer", isFirstRoundOfPlay)
	if isFirstRoundOfPlay:
		await get_tree().create_timer(timerBoard).timeout
		print("timer done")

		board.makeBoardDescend()
	else:
		board.makeBoardDescend()
	
	resetGameObjects.emit()
	await board.boardDropped
	# Fine Fase 1:
	# sul segnale dalla BoardBehavior (dopo targetSelected)  
	# eseguo il tween per spostare la board
	var args = await board.canLeave
	
	
	print("easeOut ", " a[0]: ", args[0], " a[1]: ", args[1])
	calcScore(args[0], args[1])
	set_meta("target", args[0])
	board.makeBoardAscend()
	await board.boardAscended

	startMinigame.emit()
	clearFiches.emit()
	pass # Replace with function body.



	
	# mando un segnale alla board per clearare le fiches quando off screen
	#rimuoviBoard.tween_callback(clearFiches.emit) 
	
	# Fase 2
	pass

func calcScore(idx:int , ficheArr: Array[int]) -> void:
	# calcola lo score e lo manda al round
	base_score = 0
	multiplier = 0
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
	baseBox.text = "{base}".format({"base": base_score})
	multBox.text = "{mult}".format({"mult": multiplier})
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func initializeValues():
	currRound += 1
	roundBox.text = "{round}".format({"round": currRound})
	roundScoreTarget = lerp(RSTatStart * maxScore, RSTatEnd * maxScore, float(currRound - 1) / float(maxRoundNumber))
	if valuesFlag:
		valuesFlag = false
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
	
	var proportion = remap(score, maxScore * mScore, roundScoreTarget, 0.0, 1.0)
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
	
func _on_rank_meter_end_minigame(mgScore: float) -> void:
	if has_meta("Scope"):
		print("score: ", mgScore, ". RTS: ", roundScoreTarget)
		var targetScope = get_meta("Scope")
		var tchoice = targetScope[3].keys()[0]
		var mgResult: int
		var wOl = false
		if mgScore >= roundScoreTarget:
			mgResult = targetScope[3].keys()[0]
			wOl = true
		else:
			mgResult = calcFinalDestination(targetScope, mgScore)
		finalDestination.emit(mgResult, wOl)
		
		if wOl or mgResult == tchoice:
			updateGameState.emit(base_score * multiplier)
		else:
			for elem in targetScope:
				if elem.keys()[0] == mgResult:
					updateGameState.emit(-elem.values()[0])
		
	pass # Replace with function body.

func _on_board_show_preview_from_board(idx: int, ficheArr: Array) -> void:
	var bScore = 0
	var mPlier = 0
	var count = 1
	var idxP = 0
	var idxM = 0
	
	if ficheArr[idx] != 0:
		bScore = -(ficheArr[idx])
		
	while count<4:
		idxP = posmod(idx + count, 36)
		idxM = posmod(idx - count, 36)
		
		if ficheArr[idxP] != 0:
			#print("fichearr[", (idx+count)%36, "] = ", ficheArr[(idx+count)%36])
			bScore += ficheArr[idxP]
			mPlier += 1
			
		if ficheArr[idxM] != 0:
			#print("fichearr[", (idx-count)%36, "] = ", ficheArr[(idx-count)%36])
			bScore += ficheArr[idxM]
			mPlier += 1
		count += 1
		
	previewBox.text = " Base: {base} Mult: {mult}".format({
		"base": bScore,
		"mult": mPlier
	})
	pass # Replace with function body.


func _on_game_manager_start_new_round() -> void:
	initializeValues()
	roundHandler(false)
	pass # Replace with function body.


func _on_game_manager_new_day_has_come(maxRound: int, isFirstDay: bool) -> void:
	maxRoundNumber = maxRound
	currRound = 0
	initializeValues()
	roundHandler(isFirstDay)
	pass # Replace with function body.

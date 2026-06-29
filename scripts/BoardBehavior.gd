extends Node
@export var fiches: PackedScene
@export var distanzaCaselle: int
@export var offsetCaselle_x: int
@export var offsetCaselle_y: int

var fichesStack: Array
var boardMovement: int = 800

signal killFiches
signal showPreviewFromBoard
signal allChipDropped
signal canLeave
signal boardDropped
signal boardAscended

@onready var sfxPlayer: AudioStreamPlayer = $"../../SoundEffectsPlayer"
const SFX_board_in = preload("res://assets/sounds/sfx/Board/BoardSFX_enter3.wav")
const SFX_board_out = preload("res://assets/sounds/sfx/Board/BoardSFX_exit3.wav")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func makeBoardDescend() -> void:
	var mostraBoard: Tween = create_tween()
	#sfxPlayer.stream = 
	mostraBoard.tween_callback(sfxPlayer.playSound.bind(SFX_board_in))
	mostraBoard.tween_property(self, "position:y", self.position.y + boardMovement, 0.6)\
	.set_trans(Tween.TRANS_SPRING)\
	.set_ease(Tween.EASE_OUT) 
	mostraBoard.tween_callback(boardDropped.emit)
	
func makeBoardAscend() -> void:
	var rimuoviBoard: Tween = create_tween()
	#sfxPlayer.stream = SFX_board_out
	rimuoviBoard.tween_callback(sfxPlayer.playSound.bind(SFX_board_out))
	rimuoviBoard.tween_property(self, "position:y", self.position.y - boardMovement, 0.6)\
		.set_trans(Tween.TRANS_SPRING)\
		.set_ease(Tween.EASE_IN)
	rimuoviBoard.tween_callback(boardAscended.emit)
	
	
func generateRoundBet(ficheArr: Array[int]) -> void:
	if (len(ficheArr) != 36):
		print("Unvalid fiches array length, not spawning any")
		return
	
	var probWeight: Array[float] = ([5, 0.5, 0.4, 0.3, 0.2])
	var ranges: Array[int] = [0, 150, 250, 350, 500]
	var rng = RandomNumberGenerator.new()	
	
	var roundrng = 0
	var count = 0
	var checkFive = 0
	
	while (count < 36): 
		roundrng = ranges[rng.rand_weighted(probWeight)]
		if (roundrng != 0):
			ficheArr[count] = rng.randi_range(roundrng - 145, roundrng)
			checkFive = ficheArr[count] % 5
			if (checkFive != 0):
				ficheArr[count] = ficheArr[count] - checkFive
		else:
			ficheArr[count] = 0
		print("arr[", count, "] = ", ficheArr[count])
		count+=1
	
	set_meta("boardRoundValue", ficheArr)	 
	pass
	
func placeFiches(ficheArr: Array[int]) -> void:
	var masterTween = create_tween()
	#masterTween.set_parallel(true)
	fichesStack.resize(0)
	if (len(ficheArr) != 36):
		print("Unvalid fiches array length, not spawning any")
		return
	var idx = 0
	for chipsInNumber in ficheArr:
		if chipsInNumber != 0:
#		(arrayposition + 1) % 6 => numero di riga
#		math.floor((arrayposition) / 6) + 1 => numero di colonna
#		moltiplico per i miei offset dimensionali e dovrei esserci
			
			# creo l'oggetto fiches per animarlo meglio dopo
			var new_fiche = fiches.instantiate()
			new_fiche.value = chipsInNumber
			new_fiche.tween = masterTween
			# calcolo le coordinate locali e lo inserisco
			var riga: int = (idx) % 6
			var colonna: int = floori(idx/6)
			
			riga = riga - 3
			colonna = colonna - 3
			
			var x = (riga*distanzaCaselle) + (offsetCaselle_x)
			var y = (colonna*distanzaCaselle) + (offsetCaselle_y * sign(colonna))

#				-3*offsetCaselle, (-3*offsetCaselle)-.5*offsetCaselle
			var spawnPosition = Vector2(x,y)
			print("idx ",idx, " riga ",riga," colonna ",colonna)
			print("spawing in ", spawnPosition)
			new_fiche.position = Vector2(spawnPosition)
			
			add_child(new_fiche)
			fichesStack.append(new_fiche)
			
			if new_fiche.value != 0:
				ficheArr[idx] -= new_fiche.value
		idx += 1
#	metto in fondo alla coda di animazione il segnale per segnalare la fine dell'animazione
	masterTween.chain().tween_callback(allChipDropped.emit)
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_board_button_container_target_selected(idx: int) -> void:
	if has_meta("boardRoundValue"):
		var ficheArr = get_meta("boardRoundValue")
		canLeave.emit(idx, ficheArr)
		print("idx: ", idx)
		print("value: ", ficheArr[idx])
	else:
		print("cannot take board value")
	pass # Replace with function body.


func _on_board_button_container_show_preview(idx: int) -> void:
	if has_meta("boardRoundValue"):
		var ficheArr = get_meta("boardRoundValue")
		showPreviewFromBoard.emit(idx, ficheArr)
	else:
		print("cannot take board value")
	pass # Replace with function body.


func _on_round_manager_clear_fiches() -> void:
	for stack in fichesStack:
		for child in stack.get_children(true):
			child.queue_free()
		stack.queue_free()
	pass # Replace with function body.


func _on_round_manager_reset_game_objects() -> void:
	var ficheArr: Array[int]
	ficheArr.resize(36)
	generateRoundBet(ficheArr)
	placeFiches(ficheArr)
	pass # Replace with function body.

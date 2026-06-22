extends Node2D

@export var maxStackSize: int = 5
@onready var sfxPlayer = $SFXPlayer
const SFX_SMLDROP = preload("res://assets/sounds/sfx/ChipsSFX_SmlDrop.wav")
const SFX_MEDDROP = preload("res://assets/sounds/sfx/ChipsSFX_MedDrop.wav")
const SFX_BIGDROP = preload("res://assets/sounds/sfx/ChipsSFX_BigDrop.wav")

var value: int
var tween: Tween

# black 100
# green 50
# yellow 25
# red 10
# blue 5
var chipValue = {"black": 100, "green": 50, "yellow": 25, "red": 10, "blue": 5}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var chipArray = makeFichesStack()
	if len(chipArray) != 0:
		for chip in chipArray:
			var target_y = chip.position.y + 73
			chip.position.y -= 1000
			
			#	cade
			tween.tween_property(chip, "position:y", target_y, .1)\
			.set_trans(Tween.TRANS_QUAD)\
			.set_ease(Tween.EASE_IN)
			
#			play sfx
			if len(chipArray) == 5: 
				sfxPlayer.stream = SFX_BIGDROP
			elif  len(chipArray) >= 2 and len(chipArray) <= 4:
				sfxPlayer.stream = SFX_MEDDROP
			else:
				sfxPlayer.stream = SFX_SMLDROP
			tween.tween_callback(sfxPlayer.play)
			
			
#		rimbalza
			tween.tween_property(chip, "position:y", target_y-5, .05)
			tween.tween_property(chip, "position:y", target_y, .01)
	#	delete
			#tween.chain().tween_callback(queue_free)
pass # Replace with function body.

func makeFichesStack() -> Array[Node2D]:
	var chipArray: Array[Node2D] = []
	var stackHeight = 0
	
	for chip in range(maxStackSize):
		var best_chip_key = ""
		var max_affordability = 0
		if value > 5:
			for possibleChip in chipValue:
				var current = chipValue[possibleChip]
				if current <= value and current > max_affordability:
					max_affordability = current
					best_chip_key = possibleChip
#		se abbiamo trovato qualcosa nella ricerca greedy precedente
		if best_chip_key != "":
			value -= max_affordability
			
#			getto il nodo associato alla chip, lo duplico e lo rendo visibile
			var template_node = get_node(best_chip_key) as Node2D
			if template_node:
				var new_chip = template_node.duplicate() as Node2D
				new_chip.visible = true
				
				new_chip.position.y -= stackHeight * 4
				stackHeight += 1
				
				add_child(new_chip)
				chipArray.append(new_chip)
		else:
			break
	return chipArray

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

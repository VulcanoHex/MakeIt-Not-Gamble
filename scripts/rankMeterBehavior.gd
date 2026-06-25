extends Node2D

@onready var perfect_area: Area2D = $RankMeterSprite/PerfectArea
@onready var good_area: Area2D = $RankMeterSprite/GoodArea
@onready var ok_area: Area2D = $RankMeterSprite/OkArea

@onready var visibleMeter: ProgressBar = $RankMeterSprite/ProgressBar
@onready var RoundManager: Node2D = $"../../.."
@onready var pallina: RigidBody2D = $"../Pallina"
@onready var board: Node2D = $"../Board"

@onready var SFXplayer: AudioStreamPlayer = $"../../SoundEffectsPlayer"

const SFXPerfect = preload("res://assets/sounds/sfx/Hit/SFXHit_Perf.wav")
const SFXGood = preload("res://assets/sounds/sfx/Hit/SFXHit_Good.wav")
const SFXOk = preload("res://assets/sounds/sfx/Hit/SFXHit_Ok.wav")
const SFXMiss = preload("res://assets/sounds/sfx/Hit/SFXHit_Miss.wav")

signal endMinigame

var roundStarted = false
var calculating = false
var mgscore: float
var count: int
var activeHitbox = {"PerfectArea": false, "GoodArea": false, "OkArea": false, "MissArea": true}
var hitScores: Dictionary
var hitSFX: Dictionary

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	
	hitSFX = {
		"PerfectArea": SFXPerfect,
		"GoodArea": SFXGood,
		"OkArea": SFXOk,
		"MissArea": SFXMiss
	}
	
	perfect_area.body_entered.connect(_on_body_entered.bind(perfect_area))
	perfect_area.body_exited.connect(_on_body_exited.bind(perfect_area))
	
	good_area.body_entered.connect(_on_body_entered.bind(good_area))
	good_area.body_exited.connect(_on_body_exited.bind(good_area))
	
	ok_area.body_entered.connect(_on_body_entered.bind(ok_area))
	ok_area.body_exited.connect(_on_body_exited.bind(ok_area))
	
	count = 0
	
	pass # Replace with function body.

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		if event.keycode == KEY_SPACE:
			calculating = true
			print(roundStarted)
			if roundStarted:
				count += 1
				for area in activeHitbox:
					if activeHitbox[area]: 
						SFXplayer.stream = hitSFX[area]
						mgscore += hitScores[area]
						break
				SFXplayer.play()
				updateMeter()
				if count == 5:
					endMinigame.emit(mgscore)
					roundStarted = false
					await board.allChipDropped
					resetvalues()				
			calculating = false	

func updateMeter():
	var updateBar = create_tween()
	
	updateBar.tween_property(visibleMeter, "value", mgscore, 0.8)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_OUT)
	pass

func updateValues(maxScore):
	visibleMeter.max_value = maxScore
	hitScores = {
		"PerfectArea": maxScore / RoundManager.hitQty * RoundManager.pScore,
		"GoodArea": (maxScore / RoundManager.hitQty) * RoundManager.gScore,
		"OkArea": (maxScore / RoundManager.hitQty) * RoundManager.oScore,
		"MissArea": (maxScore / RoundManager.hitQty) * RoundManager.mScore
	}

func resetvalues():
	roundStarted = false
	mgscore = 0
	calculating = false
	count = 0
	visibleMeter.value = 0
	pass
	
func _on_body_entered(body: Node2D, area: Area2D):
	if body is RigidBody2D and !calculating:
		activeHitbox[area.name] = true
	pass
	
func _on_body_exited(body: Node2D, area: Area2D):
	if body is RigidBody2D:
		activeHitbox[area.name] = false
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_round_manager_start_minigame() -> void:
	roundStarted = true
	pass # Replace with function body.


func _on_round_manager_set_all_values() -> void:
	var maxScore = RoundManager.maxScore
	updateValues(maxScore)
	pass # Replace with function body.

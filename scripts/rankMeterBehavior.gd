extends Sprite2D

@onready var perfect_area: Area2D = $PerfectArea
@onready var good_area: Area2D = $GoodArea
@onready var ok_area: Area2D = $OkArea

@onready var meter: Area2D = $Meter

@onready var pallina: RigidBody2D = $"../Pallina"

signal endMinigame

var roundStarted = true
var calculating = false
var mgscore: int
var count: int
var activeHitbox = {"PerfectArea": false, "GoodArea": false, "OkArea": false}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
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
			if roundStarted:
				count += 1
				if activeHitbox["PerfectArea"]:
					print("perfect")
					mgscore += 100
				elif activeHitbox["GoodArea"]:
					print("good")
					mgscore += 75
				elif activeHitbox["OkArea"]:
					print("ok")
					mgscore += 50
				else:
					print("miss")
					mgscore += 25
			if count == 5:
				endMinigame.emit(mgscore)
				resetvalues()				
			calculating = false	

func resetvalues():
	roundStarted = false
	mgscore = 0
	calculating = 0
	count = 0
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

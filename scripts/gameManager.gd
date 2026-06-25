extends Node2D

var playerScore: int
@export var maxDays: int = 3
@export var minRound: int = 3
@export var maxRound: int = 5
@export var minObj: int = 5000
@export var maxObj: int = 8000
var day: int
var dailyObjective: Array[int]
var roundInDay: Array[int]

@onready var roundInformation: Node2D = $"Round Manager"
@onready var pallina: RigidBody2D = $"Round Manager/Camera2D/Schermo/Pallina"

@onready var scoreText: RichTextLabel = $"Round Manager/Camera2D/Schermo/TestUI/BaseUI/LayerSc/ScoreReal"
@onready var daylyObjText: RichTextLabel = $"Round Manager/Camera2D/Schermo/TestUI/BaseUI/LayerDO/DailyObjReal"
@onready var dayText: RichTextLabel = $"Round Manager/Camera2D/Schermo/TestUI/BaseUI/LayerDay/DayReal"
@onready var roundSxText: RichTextLabel = $"Round Manager/Camera2D/Schermo/TestUI/BaseUI/LayerRo/RoundRealSx"

@export var loseScreenScene: PackedScene

signal startNewRound
signal newDayHasCome

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var loseScreen = loseScreenScene.instantiate()
	add_child(loseScreen)
	set_meta("loseScene", loseScreen)
	setValues()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func setValues():
	playerScore = 0
	scoreText.text = "{score}".format({"score": playerScore})
	day = 1
	dayText.text = "{day}".format({"day": day})
	
	#generate array of dailyobj and round for day
	dailyObjective.resize(maxDays)
	roundInDay.resize(maxDays)
	
	for i in range(maxDays):
		dailyObjective[i] = int(round(lerp(minObj, maxObj, float(i) / float(maxDays))))
		roundInDay[i] = int(ceil(lerp(minRound, maxRound, float(i) / float(maxDays))))
	
	daylyObjText.text = "{DObj}".format({"DObj": dailyObjective[day - 1]})
	roundSxText.text = "{rounds}".format({"rounds": roundInDay[day - 1]})
	
	newDayHasCome.emit(roundInDay[day - 1])
	pass

func _on_round_manager_update_game_state(finalScore: int) -> void:

	playerScore += finalScore 
	
	scoreText.text = "{score}".format({"score": playerScore})
	
	if roundInformation.currRound == roundInDay[day - 1]:
		if playerScore >= dailyObjective[day - 1]:
			if day <= maxDays:
				day += 1
				playerScore = 0
				await pallina.iStillStanding
				scoreText.text = "{score}".format({"score": playerScore})
				dayText.text = "{day}".format({"day": day})
				daylyObjText.text = "{DObj}".format({"DObj": dailyObjective[day - 1]})
				roundSxText.text = "{rounds}".format({"rounds": roundInDay[day - 1]})
				newDayHasCome.emit(roundInDay[day - 1])
			else:
				print("gg hai vinto")
		else:
			print("skill issue hai perso")
			var lose = get_meta("loseScene")
			lose.skill_issue()
			
	pass # Replace with function body.


func _on_pallina_my_job_here_is_done() -> void:
	startNewRound.emit()
	pass # Replace with function body.

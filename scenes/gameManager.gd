extends Node2D

var playerScore: int
var dailyObjective: int
var day: int


@onready var scoreText: RichTextLabel = $"Round Manager/Camera2D/Schermo/TestUI/BaseUI/LayerSc/ScoreReal"
@onready var daylyObjText: RichTextLabel = $"Round Manager/Camera2D/Schermo/TestUI/BaseUI/LayerDO/DailyObjReal"
@onready var dayText: RichTextLabel = $"Round Manager/Camera2D/Schermo/TestUI/BaseUI/LayerDay/DayReal"

signal startNewRound



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	playerScore = 0
	scoreText.text = "{score}".format({"score": playerScore})
	day = 1
	dayText.text = "{day}".format({"day": day})
	dailyObjective = 5000
	daylyObjText.text = "{DObj}".format({"DObj": dailyObjective})
	
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_round_manager_update_game_state(targetScope: Array, finalDest: int, res: bool) -> void:
	var finalScore
	if res:
		var base = 0
		var mult = 0
		for elem in targetScope:
			if finalDest != elem.keys()[0]:
				if elem.values()[0] > 0:
					base += elem.values()[0]
					mult += 1
			else:
				base -= elem.values()[0]	
		finalScore = base * mult
	else:
		finalScore = -targetScope[targetScope.find(finalDest)].values()[0]
		
	playerScore += finalScore 
	
	scoreText.text = "punteggio: {score}".format({
		"score": playerScore
	})
	
	#await pallina.myJobHereIsDone
	#startNewRound.emit()
	pass # Replace with function body.


func _on_pallina_my_job_here_is_done() -> void:
	startNewRound.emit()
	pass # Replace with function body.

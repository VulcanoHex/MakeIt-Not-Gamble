extends Node2D

var playerScore: int
@export var maxDays: int = 3
@export var minRound: int = 2
@export var maxRound: int = 4
@export var minObj: int = 1500
@export var maxObj: int = 3500
var day: int
var dailyObjective: Array[int]
var roundInDay: Array[int]

@onready var roundInformation: Node2D = $"Round Manager"
@onready var pallina: RigidBody2D = $"Round Manager/Camera2D/Schermo/Pallina"

@onready var scoreText: RichTextLabel = $"Round Manager/Camera2D/Schermo/TestUI/BaseUI/LayerSc/ScoreReal"
@onready var daylyObjText: RichTextLabel = $"Round Manager/Camera2D/Schermo/TestUI/BaseUI/LayerDO/DailyObjReal"
@onready var dayText: RichTextLabel = $"Round Manager/Camera2D/Schermo/TestUI/BaseUI/LayerDay/DayReal"
@onready var roundSxText: RichTextLabel = $"Round Manager/Camera2D/Schermo/TestUI/BaseUI/LayerRo/RoundRealSx"

@onready var sfxPlayer: AudioStreamPlayer = $"Round Manager/Camera2D/SoundEffectsPlayer"
@export var loseScreenScene: PackedScene
@export var winScreenScene: PackedScene
const LOSE_SFX = preload("uid://2r6w8srnilex")
const WIN_SFX = preload("uid://c3melcjb8t3jt")


signal startNewRound
signal newDayHasCome

# Called when the node enters the scene tree for the first time.
func _ready() -> void:

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
	
	newDayHasCome.emit(roundInDay[day - 1], day == 1 and roundInformation.currRound == 0)
	pass

func _on_round_manager_update_game_state(finalScore: int) -> void:

	playerScore += finalScore
	#aspetta che la pallina vada in buca per aggiornare la UI 
	await pallina.iStillStanding
	
	#verifica che sia l'ultimo round della giornata
	if roundInformation.currRound == roundInDay[day - 1]:
		#verifica se hai superato la giornata con lo score
		if playerScore >= dailyObjective[day - 1]:
			#verifica se sono o non sono finite le giornate
			if day < maxDays:
				#se sei qui dentro aggiorni tutta la ui
				day += 1
				playerScore = 0
				scoreText.text = "{score}".format({"score": playerScore})
				dayText.text = "{day}".format({"day": day})
				daylyObjText.text = "{DObj}".format({"DObj": dailyObjective[day - 1]})
				roundSxText.text = "{rounds}".format({"rounds": roundInDay[day - 1]})
				await pallina.myJobHereIsDone
				newDayHasCome.emit(roundInDay[day - 1], false)
			else:
				print("gg")
				var winScreen = winScreenScene.instantiate()
				add_child(winScreen)
				winScreen.gg()
				sfxPlayer.playSound(WIN_SFX)
		#se non hai superato l'obiettivo giornaliero hai perso (skill issue)
		else:
			print("skill issue hai perso")
			var loseScreen = loseScreenScene.instantiate()
			add_child(loseScreen)
			loseScreen.skill_issue()
			sfxPlayer.playSound(LOSE_SFX)

			
	else:
		scoreText.text = "{score}".format({"score": playerScore})
		await pallina.myJobHereIsDone
		startNewRound.emit()	
		
			
	pass # Replace with function body.


func _on_pallina_my_job_here_is_done() -> void:
	#startNewRound.emit()
	pass # Replace with function body.

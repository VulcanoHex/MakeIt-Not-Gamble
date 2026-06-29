extends CanvasLayer

@onready var animation: AnimationPlayer = $LoseAnimation
@onready var retryButton: BaseButton = $ButtonRetry
@onready var exitButton: BaseButton = $ButtonExit


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#animation.play("showLoseScreen")
	pass # Replace with function body.

func skill_issue():
	animation.play("showScreen")
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_retry_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/roulette_scam_test.tscn")
	pass # Replace with function body.


func _on_button_exit_pressed() -> void:
	get_tree().quit()
	pass # Replace with function body.

extends CanvasLayer

@onready var animation: AnimationPlayer = $LoseAnimation
@onready var retryButton: BaseButton = $ButtonRetry
@onready var exitButton: BaseButton = $ButtonExit

signal ohShitHereWeGoAgain

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#animation.play("showLoseScreen")
	pass # Replace with function body.

func skill_issue():
	animation.play("showLoseScreen")
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_retry_pressed() -> void:
	ohShitHereWeGoAgain.emit()
	pass # Replace with function body.


func _on_button_exit_pressed() -> void:
	get_tree().quit()
	pass # Replace with function body.

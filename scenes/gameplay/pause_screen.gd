extends CanvasLayer

@onready var menuPanel: Control = $MenuPanel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("MENU PAUSA ci sono")
	#togglePause()

	menuPanel.hide()
	pass # Replace with function body.

func _input(event: InputEvent) -> void:
#	TODO: aggiungi condizione per non mettere pausa nel menu iniziale
	#if get_tree().current_scene.name == "MenuIniziale":
		#return
	if event.is_action_pressed("ui_cancel"):
		togglePause()

func togglePause() -> void:
	# Se in pausa riprende e viceversa
	get_tree().paused = !get_tree().paused
	
	# Se in pausa mostra menu
	if get_tree().paused:
		menuPanel.show()
	else:
		menuPanel.hide()
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_resume_button_pressed() -> void:
	togglePause()
	pass # Replace with function body.


func _on_quit_game_pressed() -> void:
	get_tree().quit()
	pass # Replace with function body.

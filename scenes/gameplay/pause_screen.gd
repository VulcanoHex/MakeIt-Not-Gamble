extends CanvasLayer

@onready var sfxSlider: HSlider = $"MenuPanel/MenuContainer/SFX/SFX Slider"
@onready var musicSlider: HSlider = $"MenuPanel/MenuContainer/Music/Music Slider"

@onready var menuPanel: Control = $MenuPanel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
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

func set_bus_volume(bus_index: int, value: float) -> void:
	# Convert linear 0.0-1.0 to Decibels
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
	# Optional: Mute if volume is 0
	AudioServer.set_bus_mute(bus_index, value <= 0.0)

func _on_resume_button_pressed() -> void:
	togglePause()
	pass # Replace with function body.


func _on_quit_game_pressed() -> void:
	get_tree().quit()
	pass # Replace with function body.


func _on_sfx_slider_value_changed(value: float) -> void:
	set_bus_volume(AudioServer.get_bus_index("Effects"), value)
	pass # Replace with function body.


func _on_music_slider_value_changed(value: float) -> void:
	set_bus_volume(AudioServer.get_bus_index("Music"), value)
	pass # Replace with function body.

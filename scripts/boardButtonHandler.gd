extends GridContainer
signal targetSelected
signal showPreview

@export var textureButtonInScope: Texture2D = preload("res://assets/sprites/grid/hoverbutton.png")
@export var opacityInScope = .5

@onready var SFXplayer: AudioStreamPlayer = $"../../../SoundEffectsPlayer"
@onready var clickSfx = preload("res://assets/sounds/sfx/Click/ClickSFX_1.wav")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.hide()
	
	#ciclo iniziale per disattivare tutti i bottoni e connettere funzione pressione tasto
	for child in get_children():
		if child is TextureButton:
			child.pressed.connect(buttonPressed.bind(child.get_index()))
			child.mouse_entered.connect(buttonHover.bind(child.get_index()))
			child.mouse_exited.connect(buttonExit.bind(child.get_index()))
			child.disabled = true
			
	print("stacca stacca")
	pass # Replace with function body.

func buttonExit(idx: int):
	for offset in range(-3, 4):
		if offset == 0:
			continue
		
		var child = get_child(posmod(idx + offset, 36))
		child.texture_normal = null
		child.self_modulate.a = 1
	pass

func buttonHover(idx: int):
	showPreview.emit(idx)
	for offset in range(-3, 4):
		if offset == 0:
			continue
		
		var child = get_child(posmod(idx + offset, 36))
		child.texture_normal = textureButtonInScope
		child.self_modulate.a = .4
	pass
	
func buttonPressed(idx: int):
	setButtonsState(true)
	SFXplayer.playSound(clickSfx)
	targetSelected.emit(idx)
	print("tasto: ", idx)

func setButtonsState(state: bool):
	for child in get_children():
		if child is TextureButton:
			child.disabled = state
			

func _on_board_all_chip_dropped() -> void:
	print("collega colleghi")
	setButtonsState(false)
	self.show()
	print("collegato collega")
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

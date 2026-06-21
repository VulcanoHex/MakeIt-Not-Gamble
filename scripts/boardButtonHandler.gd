extends GridContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.hide()
	setButtonsState(true)
	print("stacca stacca")
	pass # Replace with function body.

func setButtonsState(state: bool):
	for child in get_children():
		if child is TextureButton:
			child.pressed.connect(buttonPressed.bind(child.get_index()))
			child.disabled = state
			
func buttonPressed(idx: int):
	setButtonsState(true)
	print("tasto: ", idx)

func _on_board_all_chip_dropped() -> void:
	print("collega colleghi")
	setButtonsState(false)
	self.show()
	print("collegato collega")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

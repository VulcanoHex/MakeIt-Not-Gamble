extends Sprite2D

@export var rotation_speed : float = .4

# delete me later
@onready var pallina : Sprite2D = $"Test Casella Target/Pallina"

@export var intervalloScelto : Area2D

var more_rot : bool = false
var is_inside_marker : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pallina.modulate = Color.YELLOW
	intervalloScelto.body_entered.connect(_on_body_entered)
	intervalloScelto.body_exited.connect(_on_body_exited)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	pass

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.is_echo():
		if event.keycode == KEY_Z:
			print("mod")
			more_rot = not more_rot
		elif event.keycode == KEY_SPACE and is_inside_marker:
			pallina.modulate = Color.GREEN
			print("bravo")
			



func _on_body_entered(body: Node2D) -> void:
	print(body.name)
	if body.name == "Pallina":
		print("Entrata")
		is_inside_marker = true
	pass # Replace with function body.

func _on_body_exited(body: Node2D) -> void:
	print(body.name)
	if body.name == "Pallina":
		print("Uscita")
		is_inside_marker = false
		pallina.modulate = Color.YELLOW
	pass # Replace with function body.

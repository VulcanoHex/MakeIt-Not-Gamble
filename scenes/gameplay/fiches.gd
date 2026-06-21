extends Node2D

var value: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var tween = create_tween().set_parallel()
	
#	cade
	tween.tween_property(self, "position:y", position.y+73, .45)\
	.set_trans(Tween.TRANS_QUAD)\
	.set_ease(Tween.EASE_IN)
	
#	delete
	#tween.chain().tween_callback(queue_free)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

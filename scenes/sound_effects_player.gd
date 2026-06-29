extends AudioStreamPlayer

var queueSize = 6
var sfxQueue: Array[AudioStream] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	finished.connect(soundFinished)
	pass # Replace with function body.

func soundFinished():
	playNext()

func playNext():
	if sfxQueue.is_empty():
		return
	var nextSound = sfxQueue.pop_front()
	self.stream = nextSound
	self.play()
	
# API per playare un sound da un nodo qualsiasi
func playSound(sfx: AudioStream):
	if sfx == null:
		return
	
	if sfxQueue.size() >= queueSize:
		return
	
	sfxQueue.append(sfx)
	if not playing:
		playNext()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

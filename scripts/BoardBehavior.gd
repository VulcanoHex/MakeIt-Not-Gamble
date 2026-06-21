extends Node
@export var fiches: PackedScene
@export var offsetCaselle: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var test: Array[int]
	test.resize(36)
	test.fill(0)
	test[1] = 5
	
	placeFiches(test)
	pass # Replace with function body.

func placeFiches(ficheArr: Array[int]) -> void:
	if (len(ficheArr) != 36):
		print("Unvalid fiches array length, not spawning any")
		return
	var idx = 0
	for chipsInNumber in ficheArr:
		if chipsInNumber != 0:
#		(arrayposition + 1) % 6 => numero di riga
#		math.floor((arrayposition) / 6) + 1 => numero di colonna
#		moltiplico per i miei offset dimensionali e dovrei esserci
			
			# creo l'oggetto fiches per animarlo meglio dopo
			var new_fiche = fiches.instantiate()
			new_fiche.value = chipsInNumber
			
			# calcolo le coordinate locali e lo inserisco
			var riga: int = (idx+1) % 6
			var colonna: int = floori(idx/6)
			
			if colonna <= 3:
				colonna = colonna - 3

#				-3*offsetCaselle, (-3*offsetCaselle)-.5*offsetCaselle
			var spawnPosition = Vector2(riga*offsetCaselle, colonna*offsetCaselle)
			print("riga ",riga," colonna ",colonna)
			print("spawing in ", spawnPosition)
			new_fiche.position = Vector2(spawnPosition)
			
			add_child(new_fiche)
		idx += 1
		
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

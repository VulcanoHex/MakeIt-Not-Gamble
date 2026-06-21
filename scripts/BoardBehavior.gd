extends Node
@export var fiches: PackedScene
@export var distanzaCaselle: int
@export var offsetCaselle_x: int
@export var offsetCaselle_y: int
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var test: Array[int]
	test.resize(36)
	generateRoundBet(test)
	#test.fill(1)
#	test[0] = 1
#	test[21] = 1
#	test[16] = 1
#	test[10] = 1
#	test[30] = 1
#	test[35] = 1 
#	test[34] = 1

	placeFiches(test)
	pass # Replace with function body.
	
func generateRoundBet(ficheArr: Array[int]) -> void:
	if (len(ficheArr) != 36):
		print("Unvalid fiches array length, not spawning any")
		return
	
	var probWeight: Array[float] = ([0.4, 0.2, 0.2, 0.1, 0.1])
	var ranges: Array[int] = [0, 150, 250, 350, 500]
	var rng = RandomNumberGenerator.new()	
	
	var roundrng = 0
	var count = 0
	var checkFive = 0
	
	while (count < 36): 
		roundrng = ranges[rng.rand_weighted(probWeight)]
		if (roundrng != 0):
			ficheArr[count] = rng.randi_range(roundrng - 145, roundrng)
			checkFive = ficheArr[count] % 5
			if (checkFive != 0):
				ficheArr[count] = ficheArr[count] - checkFive
		else:
			ficheArr[count] = 0
		print("arr[", count, "] = ", ficheArr[count])
		count+=1
		 
	pass
	
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
			var riga: int = (idx) % 6
			var colonna: int = floori(idx/6)
			
			riga = riga - 3
			colonna = colonna - 3
			
			var x = (riga*distanzaCaselle) + (offsetCaselle_x)
			var y = (colonna*distanzaCaselle) + (offsetCaselle_y * sign(colonna))

#				-3*offsetCaselle, (-3*offsetCaselle)-.5*offsetCaselle
			var spawnPosition = Vector2(x,y)
			print("idx ",idx, " riga ",riga," colonna ",colonna)
			print("spawing in ", spawnPosition)
			new_fiche.position = Vector2(spawnPosition)
			
			add_child(new_fiche)
		idx += 1
		
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

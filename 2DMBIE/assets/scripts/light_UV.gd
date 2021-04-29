extends Light2D

onready var timer = $Timer

func _ready():
	randomize()

func _on_Timer_timeout():
	var rand_amt = (randf())
	print(rand_amt)
	if rand_amt < 0.1:
		self.energy = 0
	else:
		self.energy = 1
extends Node2D

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), -10)

func _process(_delta):
	$cursor.position = get_global_mouse_position()
	if Input.is_action_just_released("game_reset"):
		var _error = get_tree().reload_current_scene()
		#standaard stats voor de enemies
		Global.Score = 0
		Global.MaxWaveEnemies = 4
		Global.CurrentWaveEnemies = 0
		Global.Currentwave = 1
		Global.maxHealth = 500
		Global.EnemyDamage = 300
		Global.Speed = 200
	
	if Global.brightness:
		$CanvasModulate.color = Color("#bbbbbb")
	else:
		$CanvasModulate.color = Color("#7f7f7f")

func _on_WaveTimer_timeout(): #stats voor de enemies
	if Global.CurrentWaveEnemies != 0:
		Global.CurrentWaveEnemies = 0
		Global.MaxWaveEnemies += 4
		Global.Currentwave += 1
		Global.maxHealth *= 1.05
		Global.EnemyDamage *= 1.05
		Global.Speed += 4
#		print("next wave")
#		print("new enemies")
#		print(Global.MaxWaveEnemies)
	else:
		pass
	

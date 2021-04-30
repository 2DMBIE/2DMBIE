extends Node2D

var plenemy := preload("res://assets/scenes/zombie.tscn")
var PlayerBody = false


func _on_Timer_timeout():
	$Timer.start(5)
	if PlayerBody == true:
		if Global.CurrentWaveEnemies < Global.MaxWaveEnemies:
			var enemy := plenemy.instance()
			enemy.position = $spawnpoint.get_global_position()
			get_tree().current_scene.add_child(enemy)
			var enemyAmount = get_tree().get_nodes_in_group("enemies").size()
			Global.CurrentWaveEnemies += 1
			print(Global.CurrentWaveEnemies)
			if enemyAmount > 15:
				enemy.queue_free()
		else:
			var enemyAmount = get_tree().get_nodes_in_group("enemies").size()
			if enemyAmount == 0:
				get_node("../../WaveTimer").start(2) # total wait time is this time + the spawn timer

func _on_PlayerDetectionRadius_body_entered(body):
	if body.is_in_group("player"):
		PlayerBody = true

func _on_PlayerDetectionRadius_body_exited(body):
	if body.is_in_group("player"):
		PlayerBody = false



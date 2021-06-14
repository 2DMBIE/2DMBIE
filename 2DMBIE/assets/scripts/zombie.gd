extends KinematicBody2D

var currentPath
var currentTarget
var pathFinder

var speed = 75
var jumpForce = 400
var gravity = 600
var padding = 2
var finishPadding = 6 # 6 or 8 for better padding when state machine
const dropthroughBit = 5

var movement
var zombiestep = false
signal play_sound(library)
export (int) var growl_time_min = 5 
export (int) var growl_time_max = 12
var growl_timer = Timer.new()
var _time_diff = growl_time_max - growl_time_min 
var _wait_time = randi()%_time_diff + growl_time_min
var one_shot = true
var dead = false

onready var health = maxHealth setget _set_health
signal health_updated(health)
var maxHealth = 500 #Global.maxHealth
var enemyDamage = 300 #Global.EnemyDamage
var is_dead = false

puppet var puppet_pos = Vector2()
puppet var puppet_movement = Vector2()
puppet var puppet_health = int()

func _ready():
	set_network_master(1) # let the host control the zombie
	$AnimationTree.active = true
	if is_network_master():
		randomize()
		var walk_current = randi()%10 # 0 till 9
		rpc("set_animation", "parameters/walk/current", walk_current) 
		growl_timer.wait_time = _wait_time
		growl_timer.one_shot = false
		growl_timer.connect("timeout", self, "growl")
		growl_timer.autostart = true
		add_child(growl_timer)
		
		pathFinder = get_tree().get_root().get_node("World").find_node("Pathfinder")
		movement = Vector2(0, 0)
		var timer = Timer.new()
		timer.set_wait_time(.1)
		timer.set_one_shot(false)
		timer.connect("timeout", self, "repeat_me")
		add_child(timer)
		timer.start()

func nextPoint():
	if len(currentPath) == 0:
		currentTarget = null
		return
	currentTarget = currentPath.pop_front()
	if !currentTarget:
		jump()
		nextPoint()
	if (currentTarget.y - 128 > self.position.y):
		if is_on_floor() && get_slide_collision(0).collider.name != null:
			if get_slide_collision(0).collider.name == "Floor":
				set_collision_mask_bit(dropthroughBit, false)

func jump():
	if (self.is_on_floor()):
		movement[1] = -jumpForce

func _process(delta):
	if is_network_master():
		if currentTarget:
			if (currentTarget[0] - padding > position[0]) and position.distance_to(currentTarget) > padding:
				if zombiestep:
					movement[0] = speed * 2
				else:
					movement[0] = speed
			elif (currentTarget[0] + padding < position[0]) and position.distance_to(currentTarget) > padding:
				if zombiestep:
					movement[0] = -speed * 2
				else:
					movement[0] = -speed
			else:
				movement[0] = 0
			if abs(position.x - currentTarget.x) < finishPadding and is_on_floor():
				nextPoint()
		else:
			movement[0] = 0
		if !is_on_floor():
			movement[1] += gravity * delta
		
		if !dead:
			if !is_on_floor():
				rpc_unreliable("set_animation", "parameters/in_air/current", 0)
			else:
				rpc_unreliable("set_animation", "parameters/in_air/current", 1)
			if self.movement.x < 0:
				direction("left")
			elif self.movement.x > 0:
				direction("right")
			rset("puppet_movement", movement)
			rset("puppet_pos", position)
	else:
		if !dead:
			position = puppet_pos
			movement = puppet_movement
	if !dead:
		var _moveSlide = move_and_slide(movement, Vector2(0, -1))
		if get_tree().get_network_unique_id() != gamestate.player_id:
			puppet_pos = position
			puppet_movement = movement
		
	if health <= 0 and one_shot == true:
		dead = true
		if get_tree().get_network_unique_id() == 1:
			Global.add_to_global("enemiesKilled", 1)
		var packageTimer = Timer.new()
		packageTimer.set_wait_time(.1)
		packageTimer.set_one_shot(false)
		packageTimer.connect("timeout", self, "kill")
		add_child(packageTimer)
		packageTimer.start()
		one_shot = false


func repeat_me():
	if is_on_floor():
		var space_state = get_world_2d().direct_space_state

		var players = gamestate.players.keys()
		players.append(1) # include host in player network
		var paths = {}
		for player_id in players: # get all players
			var player = get_tree().root.get_node("/root/World/Players/" + str(player_id)) # for each player
			var distance_x = self.position.distance_to(player.position) # get the distance between the player and the zombie
			if not player.is_dead:
				paths[player_id] = distance_x # add distance to array
		var shortest_path = paths.values().min() # get shortest distance value in array
		var target = 0 # zero means no target found yet
		for key in paths.keys():
			if paths[key] == shortest_path: # get the id from the player with the shortest path
				target = key # new target found
		if target == 0: # everyone is dead since the target still has not changed
			var _msg = "Game over"
			for p_id in gamestate.players:
				rpc_id(p_id, "end_game_error", _msg)
			gamestate.end_game_error(_msg)
			return
		var playerPos = get_tree().root.get_node("/root/World/Players/" + str(target)).position
		
		var pos = Vector2(playerPos.x, playerPos.y)
		var result = space_state.intersect_ray(Vector2(pos[0], pos[1] + get_tree().root.get_node("/root/World/Players/1/CollisionShape2D").shape.height/2 + 10), Vector2(pos[0], pos[1] + 1000))
		if (result):
			var goTo = result["position"]
			currentPath = pathFinder.findPath(self.position, goTo)
			nextPoint()

func direction(x):
	var body = get_node("body")
	if (x == "left") && !(body.scale == Vector2(-1,1)):
		rpc("set_direction", Vector2(-1,1))
		#body.scale = Vector2(-1,1)
	elif (x == "right") && !(body.scale == Vector2(1,1)):
		#body.scale = Vector2(1,1)
		rpc("set_direction", Vector2(1,1))

func growl():
	rpc("play_sound_remote", "growl")

func togglestep():
	zombiestep = !zombiestep

func show_damage_animation(_health_percentage):
	var _index
	var _array = [Color("ffcbcb"), Color("ff9f9f"), Color("ff7e7e"), Color("ff5858"), Color("ffe7e7")] #Color("ffcbcb")
	if _health_percentage < 100 and _health_percentage >= 80:
		_index = 0
	elif _health_percentage < 80 and _health_percentage >= 60:
		_index = 1
	elif _health_percentage < 60 and _health_percentage >= 40:
		_index = 2
	elif _health_percentage < 40 and _health_percentage >= 20:
		_index = 3
	elif _health_percentage < 20:
		_index = 4
	
	var _timer = Timer.new()
	_timer.one_shot = true
	_timer.wait_time = 0.15
	_timer.connect("timeout", self, "_reset_module")
	add_child(_timer)
	modulate = _array[_index]
	_timer.start()

func _reset_module():
	modulate = Color("ffffff")

#remote func Hurt2(damage):
#	_set_health(health - damage)
#	var percentage = health/maxHealth*100
#	#show_damage_animation(percentage)
#	show_damage_animation(percentage)
#	emit_signal("play_sound", "hurt")
#	#rpc("show_damage_animation", percentage)
#	#rpc("play_sound_remote", "hurt")

func _set_health(value):
	var prevHealth = health
	health = clamp(value, 0, maxHealth)
	if health != prevHealth:
		emit_signal("health_updated", health)
		if health == 0:
			kill()
			#else:
			#	Global.rpc_id(1, "add_to_global", "enemiesKilled", 1)
			#Global.enemiesKilled += 1

remotesync func change_health(value):
	health = clamp(value, 0, maxHealth)

func kill():
	if get_tree().get_network_unique_id() == target_id:
		Global.Score += Global.ScoreIncrement
	queue_free()

func _on_GroundChecker_body_exited(_body):
	set_collision_mask_bit(dropthroughBit, true)

remotesync func play_sound_remote(sound):
	emit_signal("play_sound", sound)

remotesync func set_animation(path, value):
	$AnimationTree.set(path, value)
	
remotesync func set_direction(scale):
	get_node("body").scale = scale

var target_id = 0

remotesync func hurt(damage, id):
	target_id = id
	emit_signal("play_sound", "hurt")
	_set_health(health - damage)
	var percentage = health/maxHealth*100
	show_damage_animation(percentage)


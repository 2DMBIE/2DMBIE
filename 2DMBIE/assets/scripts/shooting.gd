extends Sprite

#onready variables
onready var bulletDelayTimer := $BulletDelayTimer

#bullet variables
signal is_shooting(value)
signal no_aim_shoot(value)
signal shake_camera(value)
signal set_camera_decay(value)
signal set_gun_recoil_sensitivity(value)
signal play_sound(value)
signal ammo_ui(ammo, maxClipammo, totalAmmo)
# Gun Node2D Position:
# X 22.073
# Y -1.744

var mouse_position
var bulletpoint_position
var mouse_direction
var bullet_direction
var valid_aim = true

var current_gun_index
var canShoot = true # Used for ammo

var guns = [MP5.new(), SPAS12.new(), M4A1.new(), AK12.new(), BARRETT50.new()]

func _ready():
	set_gun(3)

func _process(_delta):
	if Input.is_action_just_released("weapon1"):
		set_gun(0)
	elif Input.is_action_just_released("weapon2"):
		set_gun(1)
	elif Input.is_action_just_released("weapon3"):
		set_gun(2)
	elif Input.is_action_just_released("weapon4"):
		set_gun(3)
	elif Input.is_action_just_released("weapon5"):
		set_gun(4)
	
	var _gun: Gun
	_gun = get_current_gun()
	emit_signal("ammo_ui", _gun.ammo, _gun.maxclipAmmo, _gun.totalAmmo)
	#als de player wil schieten, en waarnaartoe
	if Input.is_action_pressed("attack") and bulletDelayTimer.is_stopped() and canShoot and _gun.ammo > 0:
		bulletDelayTimer.start()
		var bullet = _gun.getBullet() 
		
		mouse_position = get_global_mouse_position()
		bulletpoint_position = $BulletPoint.get_global_position()
		
		bullet.position = bulletpoint_position
		if Input.is_action_pressed("aim") and valid_aim: #aiming
			emit_signal("no_aim_shoot", false)
			bullet.rotation = (mouse_position - bullet.position).angle()
			mouse_direction = bullet.position.direction_to(mouse_position).normalized()
			emit_signal("is_shooting", true)
			emit_signal("shake_camera", _gun.camera_shake)
			emit_signal("play_sound", _gun.name.to_lower() + str("_shot"))
			
			bullet.set_direction(mouse_direction)
			var muzzleflashInstance = _gun.getMuzzleFlash()
			$BulletPoint.add_child(muzzleflashInstance)
			get_tree().current_scene.add_child(bullet)
			_gun.ammo -= 1
		elif not Input.is_action_pressed("aim") and canShoot and _gun.ammo > 0: #not aiming
			emit_signal("no_aim_shoot", true)
			var facingDir = 10
			var facing = get_node("../../../../").facing
			emit_signal("is_shooting", true)
			emit_signal("shake_camera", _gun.camera_shake)
			emit_signal("play_sound", _gun.name.to_lower() + str("_shot"))
			if facing == "right":
				facingDir = 10
			elif facing == "left":
				bullet.scale = Vector2(-1,1) # bullet trail fixed when shooting to the left
				facingDir = -10
			bullet.set_direction(bullet.position.direction_to(bullet.position + Vector2(facingDir, 0)).normalized())
		
			var muzzleflashInstance = _gun.getMuzzleFlash()
			$BulletPoint.add_child(muzzleflashInstance)
			get_tree().current_scene.add_child(bullet)
			_gun.ammo -= 1
	reload()
	
func _on_aimzone_exited():
	valid_aim = true

func _on_aimzone_entered():
	valid_aim = false

func set_gun(index):
	current_gun_index = index
	var _gun = guns[index]
	self.texture = _gun.texture
	self.scale = _gun.scale
	self.offset = _gun.offset
	bulletDelayTimer.wait_time = _gun.bulletdelay
	get_node("BulletPoint").position = _gun.bulletpoint
	emit_signal("set_camera_decay", _gun.camera_decay)
	emit_signal("set_gun_recoil_sensitivity", _gun.gun_recoil_sensitivity)
	emit_signal("play_sound", _gun.name.to_lower() + str("_draw"))
	
func get_current_gun():
	return guns[current_gun_index]

func reload():
	var _gun = guns[current_gun_index]
	if _gun.totalAmmo > 0:
		if Input.is_action_just_pressed("reload") and _gun.ammo < 30 or _gun.ammo == 0:
			var reloadTimer = Timer.new()
			reloadTimer.one_shot = true
			reloadTimer.wait_time = 2
			reloadTimer.connect("timeout", self, "on_reload_timeout_finished")
			add_child(reloadTimer)
			reloadTimer.start()
			canShoot = false

func on_reload_timeout_finished():
	var _gun = guns[current_gun_index]
	var _prevAmmo = _gun.ammo
	
	_prevAmmo = _gun.ammo
	if _gun.totalAmmo <= _gun.maxclipAmmo:
		_gun.ammo = _gun.ammo + _gun.totalAmmo
		if _gun.ammo > _gun.maxclipAmmo:
			_gun.ammo = _gun.maxclipAmmo
	else:
		_gun.ammo = _gun.maxclipAmmo
	_gun.totalAmmo -= (_gun.maxclipAmmo - _prevAmmo)
		
	canShoot = true
	if _gun.totalAmmo < 0:
		_gun.totalAmmo = 0
		
	
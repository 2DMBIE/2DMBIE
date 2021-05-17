extends Node2D

var spriteMP5 = preload("res://assets/sprites/guns/mp5.png")
var spriteSPAS12 = preload("res://assets/sprites/guns/spas12.png")
var spriteM4A1 = preload("res://assets/sprites/guns/m4a1.png")
var spriteAK12 = preload("res://assets/sprites/guns/ak12.png")
var spriteBARRETT50 = preload("res://assets/sprites/guns/barrett50.png")
var spriteArray = [spriteMP5, spriteSPAS12, spriteM4A1, spriteAK12, spriteBARRETT50]
var colorArray = [Color.limegreen, Color.turquoise, Color.gold, Color.orange, Color.pink]
var nameArray = ["MP5", "SPAS12", "M4A1", "AK12", "BARRETT50"]
var priceArray = ["1500", "2500", "3000", "3100", "4000"]

var canBuy = false
var enoughMoney = false
onready var gunscript = get_node("../Player/body/chest/torso/gun")

export(int, "MP5", "SPAS12", "M4A1", "AK12", "BARRETT50") var Selected_Weapon = 0 

#the player can buy a weapon ans sets it to the correct slot
func _physics_process(_delta):
	if Input.is_action_just_pressed("use") and canBuy and enoughMoney:
		for w in range(gunscript.weapon_slots.size()):
			if gunscript.weapon_slots[w] == -1:
				gunscript.current_weapon = w
				gunscript.weapon_slots[w] = Selected_Weapon
				break
		
		for c in range(gunscript.weapon_slots.size()):
			if gunscript.current_weapon == c:
				gunscript.weapon_slots[c] = Selected_Weapon
				break
			
		gunscript.set_gun(Selected_Weapon)
		
		# The price of the weapon minus the score of the player
		for i in spriteArray.size():
			if Selected_Weapon == i:
				Global.Score -= int(priceArray[i])

#checks if the player is in the buy area
func _on_buyarea_body_entered(body):
	if body.is_in_group("player"):
		canBuy = true
#		print("player entered the area")
#		print(canBuy)

# checks if the player has enough money/score
	for joas in spriteArray.size():
		if Selected_Weapon == joas:
			if Global.Score >= int(priceArray[joas]):
				enoughMoney = true
#				print(enoughMoney)
			else:
				enoughMoney = false
#				print(enoughMoney)

#checks if the player is out of the buy area
func _on_buyarea_body_exited(body):
	if body.is_in_group("player"):
		canBuy = false
#		print("player exited the area")
#		print(canBuy)

#Dynamically sets the label with the correct values and also sets the sprites to the right one
func _ready():
	for cum in spriteArray.size():
		if Selected_Weapon == cum:
			$Sprite.set_texture(spriteArray[cum])
			$Light2D.color = colorArray[cum]
			$WeaponLabelName.text = nameArray[cum]
			$WeaponLabelPrice.text = priceArray[cum]

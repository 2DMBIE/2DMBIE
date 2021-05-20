extends Node2D

var priceArray = [500, 750, 1000, 1250, 1500, 2000, 2500, 3000, 4000, 5000, 6000, 7500]
var price 
var can_buy = false
	
func _physics_process(_delta):
	if Input.is_action_just_pressed("use") && Global.Score >= price && can_buy == true:
		buy_door()
		Global.unlocked_doors += 1 
		can_buy = false
	price = priceArray[Global.unlocked_doors]
	
			
func _on_doorareaRight_body_entered(body):
	if body.is_in_group("player"):
		$PricelabelRight.text = str(int(price))
		$PricelabelRight.visible = true
		can_buy= true

func _on_doorareaRight_body_exited(body):
	if body.is_in_group("player"):
		$PricelabelRight.visible = false

func buy_door():
	$doorareaRight/right.disabled = true
	$doorareaLeft/left.disabled = true
	$door.disabled = true
	$doorSprite.visible = false
	Global.Score -= price

func _on_doorareaLeft_body_entered(body):
	if body.is_in_group("player"):
		$PricelabelLeft.text = str(int(price))
		$PricelabelLeft.visible = true
		can_buy= true

func _on_doorareaLeft_body_exited(body):
	if body.is_in_group("player"):
		$PricelabelLeft.visible = false
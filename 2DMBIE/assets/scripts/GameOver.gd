extends Control

var messages = ['Well played!', 'Good games!', 'Better luck next time!', 'You did great!', 'You have displayed extraordinary skills!']
var fontSize
var rng = RandomNumberGenerator.new()
var colorSpeed = 0.0075
onready var fontOutline = $VBOX/Title.get_font("font")
onready var fontRed = 1
onready var fontGreen = 1
onready var fontBlue = 1
var is_time_formatted = false
var TimeDummy
var TimeSeconds = 10000
var TimeMinutes = 0
var TimeHours = 0
var TimeText

func _ready():
	rng.randomize()
	$VBOX/Label.text = messages[rng.randi() % messages.size()]
	$VBOX/Title.get_font("font").size = 200
	fontOutline.outline_color = Color.white
	fontRed = rng.randf()
	fontGreen = rng.randf()
	fontBlue = rng.randf()
	$Seconds.start(1)
	


func _process(_delta):
	$VBOX/HBox/VBox/Score/Score.text = str(Global.Score)
	$VBOX/HBox/VBox/Wave/Wave.text = str(Global.Currentwave)
	$VBOX/HBox/VBox/Kills/Kills.text = str(Global.totalEnemiesKilled)
	
	if visible:
		if !is_time_formatted:
			$VBOX/HBox/VBox/Time/Time.text = format_time()
		if !$AudioStreamPlayer.playing:
			$AudioStreamPlayer.play()
		fontOutline = $VBOX/Title.get_font("font")
		if $VBOX/Title.get_font("font").size >= 96:
			$VBOX/Title.get_font("font").size -= 0.5
			fontOutline.outline_color = Color(fontRed, fontGreen, fontBlue)
			fontRed -= colorSpeed
			fontGreen -= colorSpeed
			fontBlue -= colorSpeed
		else:
			$VBOX/Title.get_font("font").outline_color = Color.black
			$VBOX/HBox.visible = true
			$VBOX/PlayAgainButton.visible = true
			$VBOX/ExitToMenu.visible = true

func _on_Seconds_timeout():
	$Seconds.stop()
	if !visible:
		TimeSeconds += 1
		$Seconds.start(1)

func format_time():
	TimeText = str(TimeSeconds)+" seconds"
	print('timetext: '+TimeText)
	print('timeseconds: '+str(TimeSeconds))
	if TimeSeconds > 59:
		TimeDummy = TimeSeconds % 60
		TimeMinutes = (TimeSeconds - TimeDummy) / 60
		TimeSeconds -= TimeMinutes * 60
		TimeText = str(TimeMinutes)+":"+str(TimeSeconds)
	print('timetext: '+TimeText)
	print('timeseconds: '+str(TimeSeconds))
	print('timeminutes: '+str(TimeMinutes))
	
	if TimeMinutes > 59:
		TimeDummy = TimeMinutes % 60
		TimeHours = (TimeMinutes - TimeDummy) / 60
		TimeMinutes -= TimeHours * 60
		TimeText = str(TimeHours)+":"+str(TimeMinutes)+":"+str(TimeSeconds)
	print('timetext: '+TimeText)
	print('timeseconds: '+str(TimeSeconds))
	print('timeminutes: '+str(TimeMinutes))
	print('timehours: '+str(TimeHours))
	is_time_formatted = true
	return TimeText

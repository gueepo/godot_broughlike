extends Control

onready var highscoresRun = $HIGHSCORES_RUN
onready var highscoresScore = $HIGHSCORES_SCORE
onready var highscoresTotal = $HIGHSCORES_TOTAL
onready var saveFile = $SaveFile
var MAX_ENTRIES = 5

func _ready():
	saveFile.Load()
	var saveData = saveFile.saveFile
	var numEntries = min(MAX_ENTRIES, saveData.size())
	
	# populate run
	highscoresRun.text = "RUN\n"
	for i in range(numEntries):
		highscoresRun.text += str(saveData[i].run)
		highscoresRun.text += "\n"
		
	# populate scores
	highscoresScore.text = "SCORE\n"
	for i in range(numEntries):
		highscoresScore.text += str(saveData[i].score)
		highscoresScore.text += "\n"
		
	# populate totals
	highscoresTotal.text = "TOTAL\n"
	for i in range(numEntries):
		highscoresTotal.text += str(saveData[i].total)
		highscoresTotal.text += "\n"

func _on_Button_pressed():
	get_tree().change_scene("res://Scenes/MainScene.tscn")


extends Node

# the save file is an array of 10 values of { run, score, total, active }
var saveFile = Array()

# we should have JUST ONE ACTIVE run

func Save():
	var _saveFile = File.new()
	_saveFile.open("user://savegame.save", File.WRITE)
	_saveFile.store_line(to_json(saveFile))
	print("file saved!")
	
func Load():
	var _saveFile = File.new()
	if not _saveFile.file_exists("user://savegame.save"):
		return
	
	_saveFile.open("user://savegame.save", File.READ)
	saveFile = parse_json(_saveFile.get_line())
	_saveFile.close()
	
	print("loaded save file!")
	for i in range(saveFile.size()):
		print("score: ", saveFile[i].score, " total score: ", saveFile[i].total)

func AddData(score, won):
	print("adding data...")
	var actualRun = 1
	var actualTotal = score
	for i in range(saveFile.size()):
		if saveFile[i].active:
			actualTotal += saveFile[i].total
			actualRun = saveFile[i].run + 1
			saveFile[i].active = false
			break;
	
	var dataToSave = {'run':actualRun, 'score':score, 'total':actualTotal, 'active':won}
	
	if saveFile.size() >= 10:
		saveFile.remove(9)
	
	if saveFile.size() == 0:
		saveFile.append(dataToSave)
		Save()
		return
	
	var inserted = false
	for i in range(saveFile.size()):
		print("iterating on ", saveFile.size(), " entries")
		if saveFile[i].score < dataToSave.score:
			print("inserting ", dataToSave, " at ", i)
			saveFile.insert(i, dataToSave)
			inserted = true
			break
		
	if !inserted:
		print ("inserting ", dataToSave, " at the end")
		saveFile.append(dataToSave)
	
	Save()

func CleanSave():
	var dir = Directory.new()
	dir.remove("user://savegame.save")

extends Control

var data
var assocs
var LabelDialog
var BackgroundImage
var DialogueSound
var DialogueControl
var BackgroundSound
var ButtonImageNext
var ButtonNext
var ButtonPrev
var Forks
var Last
var choicesHistory = [] # This saves player choices for dialogue control
var nextActions
var DirPath

var text_margin = -32 # Looks better if its not at the total bottom

var p

func choice (n):
	choicesHistory.append (n)
	for c in DialogueControl.get_children ():
		DialogueControl.remove_child (c)
	for i in nextActions:
		InputMap.action_add_event ("next", i)
		DialogueControl.hide ()
	ButtonNext.set_disabled (false)
	ButtonImageNext.set_disabled (false)
	get_node ("/root/dialogue_loader").page = Forks[n]
	go_to_page (Forks[n])

func go_to_page (i):
	var x = data[i]
	var d = DynamicFontData.new ()
	var f = DynamicFont.new ()
	if x.has ("b"):
		BackgroundImage.set_texture (load (x["b"]))
		clear_items () # We wont need extra items when changing scene
	if x.has ("i"):
		clear_items ()
		for item in (x["i"]):
			add_item (item[0], item[1], item[2])
	if x.has ("t"):
		LabelDialog.set_text (x["t"])
	if x.has ("f"):
		d.set_font_path ("res://" + x["f"])
		f.set_font_data (d)
		LabelDialog.get_theme ().set_default_font (f)
	if x.has ("c"):
		LabelDialog.add_color_override ("font_color", Color (x["c"]))
	if x.has ("ts"):
		f = LabelDialog.get_theme ().get_default_font ()
		f.set_size (x["ts"])
		LabelDialog.get_theme ().set_default_font (f)
		LabelDialog.set_margin (MARGIN_BOTTOM, text_margin)
	if x.has ("d"):
		DialogueSound.stop ()
		DialogueSound.set_stream (load (x["d"]))
		DialogueSound.get_stream ().set_loop (false)
		DialogueSound.play ()
	else:
		DialogueSound.stop ()
	if x.has ("s") and x["s"] != "":
		BackgroundSound.stop ()
		BackgroundSound.set_stream (load (x["s"]))
		BackgroundSound.play ()
	elif x.has ("s") and x["s"] == "":
		BackgroundSound.stop ()
	if x.has ("g"):
		Last = get_node ("/root/dialogue_loader").page
		get_node ("/root/dialogue_loader").page = assocs[x["g"]] - 2 # Next will incrememnt
	if x.has ("x"):
		show_choice (x)
	else:
		Forks = null
		for i in nextActions:
			InputMap.action_add_event ("next", i)

func add_item (img, posX, posY):
	var r = load(img)
	var t = TextureRect.new ()
	t.set_texture (r)
	BackgroundImage.add_child (t)
	t.set_margin (MARGIN_LEFT, posX) 
	t.set_margin (MARGIN_TOP, posY) 

func clear_items ():
	for c in BackgroundImage.get_children ():
		BackgroundImage.remove_child (c)
		c.queue_free ()

func show_choice (x):
	DialogueControl.show ()
	ButtonImageNext.set_disabled (true)
	ButtonNext.set_disabled (true)
	for i in nextActions:
		InputMap.action_erase_event ("next", i)
	Forks = []
	Last = get_node ("/root/dialogue_loader").page
	var c = 0
	for i in x["x"]:
		var v = assocs[i[0]]
		if v != null:
			Forks.append (v - 1)
			var b = Button.new ()
			DialogueControl.add_child (b)
			b.set_text (i[1])
			var s = GDScript.new ()
			s.set_source_code ("extends Button\nfunc _pressed():\n\tget_node(\"/root/Control\").choice(" + String (c) + ")")
			s.reload ()
			b.set_script (s)
			c = c + 1

func next ():
	if get_node ("/root/dialogue_loader").page + 1 < data.size ():
		get_node ("/root/dialogue_loader").page = get_node ("/root/dialogue_loader").page + 1
		go_to_page (get_node ("/root/dialogue_loader").page)
		ButtonPrev.set_disabled (false)
	else:
		var err = get_tree ().change_scene ("menu/menu.tscn")
		if err :
			print("Can't change scene!")

func prev ():
	if get_node ("/root/dialogue_loader").page > 0:
		get_node ("/root/dialogue_loader").page = get_node ("/root/dialogue_loader").page - 1
		go_to_page (get_node ("/root/dialogue_loader").page)
	clear_items ()
	ButtonNext.set_disabled (false)
	if DialogueControl.get_children () != []:
		for c in DialogueControl.get_children ():
			DialogueControl.remove_child (c)
		for i in nextActions:
			InputMap.action_add_event ("next", i)
		DialogueControl.hide ()
	var x = data[get_node ("/root/dialogue_loader").page]
	if not x.has ("c"):
		var i = get_node ("/root/dialogue_loader").page - 1
		while not data[i].has ("c") and i >= 0:
			i = i - 1
		if (i >= 0):
			LabelDialog.add_color_override ("font_color", Color (data[i]["c"]))
	if not x.has ("b"):
		var i = get_node ("/root/dialogue_loader").page - 1
		while (not data[i].has ("b") and i >= 0):
			i = i - 1
		if i >= 0:
			BackgroundImage.set_texture (load (data[i]["b"]))
	if not x.has ("ts"):
		var i = get_node ("/root/dialogue_loader").page - 1
		while not data[i].has ("ts") and i >= 0:
			i = i - 1
		if i >= 0:
			var f = LabelDialog.get_theme ().get_default_font ()
			f.set_size (data[i]["ts"])
			LabelDialog.get_theme ().set_default_font (f)
			LabelDialog.set_margin (MARGIN_BOTTOM, text_margin)
	if not x.has ("s"):
		var i = get_node ("/root/dialogue_loader").page - 1
		while not data[i].has ("s") and i >= 0:
			i = i - 1
		if i >= 0 and load (data[i]["s"]).get_path () != BackgroundSound.get_stream ().get_path ():
			BackgroundSound.stop ()
			if data[i]["s"] != "":
				BackgroundSound.set_stream (load (data[i]["s"]))
				BackgroundSound.play (0)
	if not x.has ("i"):
		var i = get_node ("/root/dialogue_loader").page - 1
		while not data[i].has ("i") and i >= 0:
			i = i - 1
		if i >= 0:
			clear_items ()
			for j in data[i]["i"]:
				add_item (j[0], j[1], j[2])

func _ready ():
	BackgroundImage = get_node ("Panel/PictNext/BackgroundImage")
	LabelDialog = get_node ("Panel/LabelDialog")
	DialogueSound = get_node ("Panel/DialogueSound")
	DialogueControl = get_node ("Panel/DialogueControl")
	BackgroundSound = get_node ("Panel/BackgroundSound")
	ButtonImageNext = get_node ("Panel/PictNext")
	ButtonNext = get_node ("Panel/ButtonNext")
	ButtonPrev = get_node ("Panel/ButtonPrev")
	DirPath = OS.get_executable_path().get_base_dir()
	var t = Theme.new ()
	var d = DynamicFontData.new ()
	d.set_font_path ("res://dialogue/fonts/font.ttf") # Need to override the bitmap font with a vector font
	var f = DynamicFont.new ()
	f.set_font_data (d)
	f.set_size (12)
	t.set_default_font (f)
	LabelDialog.set_theme (t)
	LabelDialog.set_margin (MARGIN_BOTTOM, text_margin)
	var parser = XMLParser.new ()
	if parser.open ("res://dialogue/data.xml") != 0:
		print ("Error Opening: ", "dialogue/data.xml")
		return null
	data = get_node ("/root/dialogue_loader").get_dialogue_data (parser)
	if data == null:
		print ("XML read failure")
		get_tree ().quit ()
	var meta = data[0]
	if (meta.has ("name")):
		get_node ("/root/dialogue_loader").game_name = meta["name"]
	assocs = data[1]
	data = data[2]
	if data.size () == 0:
		print ("No scene data found")
		get_tree ().quit ()
	if(get_saves(DirPath) != []):
		get_node ("Menu/CenterContainer/VBoxContainer/Load").set_disabled (false)
	#if get_saves ("/saves.gvnsave".insert (0, OS.get_executable_path().get_base_dir())) != []:
	#	get_node ("Menu/CenterContainer/VBoxContainer/Load").set_disabled (false)
	nextActions = InputMap.get_action_list ("next")
	go_to_page (get_node ("/root/dialogue_loader").page) # Needed for loading saved games
	set_focus_mode (FOCUS_ALL)
	grab_focus ()

func _input (event):
	if event.is_action_pressed ("next"):
		next ()
		accept_event ()
	elif event.is_action_pressed ("prev"):
		prev ()
		accept_event ()
	elif event.is_action_pressed ("menu"):
		if (not get_node ("Menu").is_visible()):
			get_node ("Menu").show ()
			get_node ("Panel").hide ()
			for i in nextActions:
				InputMap.action_erase_event ("next", i)
		else:
			get_node ("Menu").hide ()
			get_node ("Panel").show ()
			for i in nextActions:
				InputMap.action_add_event ("next", i)
		accept_event ()

func list_files_in_directory(path):
	var files = []
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin()
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with("."):
			files.append(file)
	dir.list_dir_end()
	return files
	
func get_saves(path):
	var dir = Directory.new()
	var files
	var f = File.new()
	var saves = []
	for i in range(20):
		saves.append("")
	if dir.dir_exists(path + "/saves"):
		print("Saves directory exists.")
		if (list_files_in_directory(path+"/saves") != []):
			files = list_files_in_directory(path+"/saves")
			for file in files:
				if (file.begins_with("slot_") && file.ends_with(".sav")): 
					if (f.open (path+"/saves/"+file, File.READ) != OK):
						print("Couldn't open save file "+file)
					else:
						print("Save file "+file+" found.")
						saves[int(file.lstrip("slot_").rstrip(".sav"))] = file
						f.close()
		#else:
			#print("Saves directory is empty.")
	else:
		print("Saves directory does not exist, creating...")
		dir.open(path)
		dir.make_dir("saves")
	return saves

func save_game(idx):
	var f = File.new()
	var time = OS.get_datetime()
	var nameweekday= ["Sun", "Mon", "Tue", "W", "Thu", "Fri", "Sat"]
	var namemonth= ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
	var dayofweek = time["weekday"]
	var day = time["day"]
	var month= time["month"]
	var year= time["year"]
	var hour= time["hour"]
	var minute= time["minute"]
	var second= time["second"]
	var date = str(nameweekday[dayofweek])+" "+str("%02d" % [day])+" "+str(namemonth[month-1])+" "+str(year)+" "+str("%02d" % [hour])+":"+str("%02d" % [minute])+":"+str("%02d" % [second])
	
	if (f.open (DirPath+"/saves/slot_"+String(idx)+".sav", File.WRITE) != OK):
		print("Couldn't open save file in slot "+idx)
		return false
	else:
		f.store_line ("Godot vn save file, do not edit by hand.")
		f.store_line (get_node ("/root/dialogue_loader").game_name)
		f.store_line ("date:"+date)
		f.store_line ("xml file")
		f.store_line ("page:"+String (get_node ("/root/dialogue_loader").page))
		f.store_line("choices_history:")
		for choice in choicesHistory:
			f.store_string(str(choicesHistory[choice-1]))
			f.store_string(',')
		f.store_line ("")
		f.close ()
		return true

	
func load_game (idx):
	var f = File.new()
	var s = get_saves (DirPath)
	var line
	var page = -1
	if s == null or idx >= s.size ():
		return false
		
	if (f.open (DirPath+"/saves/"+"slot_"+str(idx)+".sav", File.READ) != OK):
		print("Couldn't read save file "+"slot_"+str(idx)+".sav")
	else:
		while not f.eof_reached():
			line = f.get_line()
			if line.begins_with("page:"):
				page = int(line.lstrip("page:"))
		f.close()
		if (page < 0):
			print("Load game failed - save file doesn't contain saved page!")
			return false
	get_node ("/root/dialogue_loader").page = page
	prev () # Reload items that may not be specified on current page
	next ()
	return true

func _on_SaveList_ItemList_item_activated (idx):
	save_game (idx)
	get_node ("Menu").hide ()
	get_node ("Panel").show ()
	popup("Saved game in slot "+String(idx)+"!")
	p.queue_free ()
	
func _on_LoadList_ItemList_item_activated (idx):
	load_game (idx)
	get_node ("Menu").hide ()
	get_node ("Panel").show ()
	popup("Loaded game from slot "+String(idx)+"!")
	p.queue_free ()
	#for i in nextActions:
	#	InputMap.action_add_event ("next", i)
	
func popup(text):
	var l = Label.new ()
	var x = PanelContainer.new ()
	var p = PopupDialog.new ()
	l.set_text (text)
	x.add_child (l)	
	p.add_child (x)
	get_tree ().get_current_scene ().add_child (p)
	p.popup_centered (Vector2 (0, 0))


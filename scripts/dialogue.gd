extends Area2D

var player: Node = null

func _on_body_entered(body: Node) -> void:
	if body.name == "Player":
		player = body
		if self.name.begins_with("Auto"):
			if not Global.triggered_dialogues.has(self.name):
				trigger_dialogue(true)
				Global.triggered_dialogues[self.name] = true
			else:
				queue_free() 


func _on_body_exited(body: Node) -> void:
	if body == player:
		player = null

func _process(_delta: float) -> void:
	# Manual trigger: requires player input, retriggerable
	if player and Input.is_action_just_pressed("interact"):
		if not self.name.begins_with("Auto"):
			trigger_dialogue(false)

func trigger_dialogue(is_auto: bool) -> void:
	match self.name:

		"AutoDialogueMon01":
			player.dialogue_text = "I think there is still food in the kitchen"
		"AutoDialogueMon02":
			player.dialogue_text = "I miss my guitar"
		"AutoDialogueMon03":
			player.dialogue_text = "My favorite painting"
		"AutoDialogueMon04":
			player.dialogue_text = "There should be a food here"
		"AutoDialogueMon05":
			player.dialogue_text = "Father forgot to fix the window again"
		"AutoDialogueMon06":
			player.dialogue_text = "*sigh*"
		"DialogueMon01":
			player.dialogue_text = "It's almost Halloween..."
		"DialogueMon02":
			player.dialogue_text = "Will I have the chance to visit this place again?"
		"DialogueMon03":
			player.dialogue_text = "Hello Bubbly and Finley!"
		"DialogueMon04":
			player.dialogue_text = "Father said to stay away from this door"
		"DialogueMon05":
			player.dialogue_text = "My guitar... *sigh*"


		"AutoDialogueTues01":
			player.dialogue_text = "I wonder if Father remember to buy a food"
		"AutoDialogueTues02":
			player.dialogue_text = "Father is probably drunk again"
		"AutoDialogueTues03":
			player.dialogue_text = "What is that sound?"
		"AutoDialogueTues04":
			player.dialogue_text = "He was so drunk that he left the keys here"
		"AutoDialogueTues05":
			player.dialogue_text = "It feels more windy than usual"
		"AutoDialogueTues06":
			player.dialogue_text = "I remember that baby formula is in the counter"
		"AutoDialogueTues07":
			player.dialogue_text = "It's the tall monster from my dream..."
		"DialogueTues01":
			player.dialogue_text = "There is no feed... I have to get one at the mart, but I'll be needing money"
		"DialogueTues02":
			player.dialogue_text = "A guard post, with no guard... classic"
		"DialogueTues03":
			player.dialogue_text = "Maybe it's best to not go there"

		"AutoDialogueWed01":
			player.dialogue_text = "His room is awfully quiet, maybe he haven't return home yet"
		"AutoDialogueWed02":
			player.dialogue_text = "I have to be quick before the monster arrives"
		"AutoDialogueWed03":
			player.dialogue_text = "His wallet isn't here, but I remember he has a spare wallet on his old ddddbackpack"
			Global.wallet_loc_known = true
		"DialogueWed01":
			player.dialogue_text = "Father forgot to buy food again"


		"OverDialogue01":
			player.dialogue_text = "I don't feel like laying down"
		_:
			player.dialogue_text = "..."

	GlobalSfx.hm.play()
	player.update_dialogue_label()

	# Auto dialogues disappear after triggering
	if is_auto:
		queue_free()

extends Container
@onready var board = $"../../.."
@onready var card = preload("res://scenes/cardHolder.tscn")
const GAME = preload("res://scenes/game.tscn")

var startPosition
var cardHighlighted = false

func _on_mouse_entered():
	$Anim.play("select")
	cardHighlighted = true


func _on_mouse_exited():
	$Anim.play("deselect")
	cardHighlighted = false


func _on_gui_input(event):
	#print(event)
	if (event is InputEventMouseButton) and (event.button_index == 1):
		if event.button_mask == 1:
			# press down
			if cardHighlighted:
				print("hihi")
				var cardTemp = card.instantiate()
				#get_tree().get_root().get_node("Game/CardHolder").add_child(cardTemp)
				board.cardSelected = true
				if cardHighlighted:
					#print("hihi")
					self.get_child(0).hide()
		elif event.button_mask == 0:
			# press up
			if !board.mouseOnPlacement:
				cardHighlighted = false
				self.get_child(0).show()
			for i in get_tree().get_root().get_node("Game/CardHolder").get_child_count():
				# only works if the cards are the same
				get_tree().get_root().get_node("Game/CardHolder").get_child(i).queue_free()
			board.cardSelected = false

extends Area2D
var durability:int = 3

@onready var shape = $CollisionShape2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if durability <= 0:
		queue_free()
func enable():
	shape.disabled = false

func disable():
	shape.disabled = true

func _on_area_entered(area):
	if area.name == "Hurtbox":
		durability -= 1

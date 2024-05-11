extends CharacterBody2D

const SPEED = 130.0
const ACCEL = 3
const DECEL = 15
const JUMP_VELOCITY = -250.0
const TOP_SPEED = 100
var current_accel = 1
const DASH_SPEED = abs(JUMP_VELOCITY) * 1.15 

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var last_direction = 1
var is_dashing = false
var can_dash = true  # New variable to track if the player can dash
var is_sliding = false
var first_jump = true

@onready var weapons = $Weapon
@onready var sword = $Weapon/Sword
@onready var animations = $AnimationPlayer
@onready var animated_sprite = $AnimatedSprite2D

func _physics_process(delta):
	if not is_dashing:
		
		if not is_on_floor():
			velocity.y += gravity * delta #
			
		if is_on_wall() and (Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right")):
			is_sliding = true
			first_jump = false	

		if is_sliding:
			velocity.y = min(velocity.y + gravity, 60)
			#print("ON WALL " + str(velocity.y))

			if Input.is_action_pressed("jump"):
				velocity.y = JUMP_VELOCITY
				velocity.x = 550 * -last_direction
				is_sliding = false

			if is_on_floor():
				is_sliding = false
			
			if Input.is_action_pressed("jump") and is_on_floor():
				velocity.y = JUMP_VELOCITY
				last_direction = 0
			
		var direction = Input.get_axis("move_left", 'move_right') #

		if direction:
			is_sliding = false
			if current_accel == 0:
				current_accel = 13 * direction
			if last_direction != direction:
				current_accel = 13 * direction
			current_accel = clamp(current_accel + direction * 15 * delta, -25, 25)
			last_direction = direction
		else:
			current_accel = 0
			
		if is_on_floor():
			_on_Foot_area_body_entered(self)
			if is_sliding:
				velocity.y = min(velocity.y + gravity, 60)
			
			is_sliding = false
			if Input.is_action_just_pressed("jump"):
				velocity.y = JUMP_VELOCITY
			if direction == 0:
				animated_sprite.play("idle")
			else:
				animated_sprite.play("run")
		else:
			if Input.is_action_just_pressed("jump") and first_jump:
				animated_sprite.play("jumping")
				velocity.y = JUMP_VELOCITY
				first_jump = false
			
		
		animated_sprite.flip_h = last_direction == -1
		
		velocity.x = move_toward(clamp(velocity.x + current_accel, -TOP_SPEED, TOP_SPEED), 0, 600*delta)
		

		if Input.is_action_just_pressed("attack"):
			if(last_direction==1):attack_right()
			if(last_direction==-1):attack_left()
		
		if Input.is_action_just_pressed("dash") and can_dash:  # Check if the player can dash
			current_accel = 0
			is_dashing = true
			can_dash = false  # Set can_dash to false when dashing
			
			
			if Input.is_action_pressed("move_right") and Input.is_action_pressed("ui_up"):
				velocity.x = DASH_SPEED
				velocity.y = -DASH_SPEED
			elif Input.is_action_pressed("move_left") and Input.is_action_pressed("jump"):
				velocity.x = -DASH_SPEED
				velocity.y = -DASH_SPEED
			elif Input.is_action_pressed("move_left") and Input.is_action_pressed(""):
				velocity.x = -DASH_SPEED
				velocity.y = DASH_SPEED
			elif Input.is_action_pressed("move_right") and Input.is_action_pressed("ui_down"):
				velocity.x = DASH_SPEED
				velocity.y = DASH_SPEED
			elif last_direction > 0:
				velocity.x = DASH_SPEED
				velocity.y = 0
			elif last_direction < 0:
				velocity.x = -DASH_SPEED
				velocity.y = 0
			else:
				velocity.x = 0
				velocity.y = -DASH_SPEED
			$DashTime.start()
	
	move_and_slide()


func _on_dash_time_timeout():
	velocity.y = 0
	is_dashing = false

func attack_right():
	animations.play("attack-right")
	weapons.enable()
	await animations.animation_finished
	weapons.disable()
	animations.stop()

func attack_left():
	animations.play("attack-left")
	weapons.enable()
	await animations.animation_finished
	weapons.disable()
	animations.stop()

func _on_Foot_area_body_entered(body):
	first_jump = true
	can_dash = true  # Set can_dash to true when the player touches the ground

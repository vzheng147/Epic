extends Node2D

enum State {
	IDLE,
	CHASE,
	ATTACK,
	SWIRL
}

# variables for the child nodes
@onready var minotaur = $minotaur_sprite
@onready var attack_1_area2d = $attack_1_range
@onready var attack_2_area2d = $attack_2_range
@onready var swirl_area2d = $swirl_range
@onready var swirl_timer = $swirl_cooldown

# initializing game-state variables (do not change!)
var player : CharacterBody2D = null
var current_state : State = State.IDLE
var is_attacking : bool = false
var swirl_ready : bool = true
var in_attack_1_range = false
var in_attack_2_range = false
var in_swirl_range = false

# adjust these accordingly
var chase_range: float = 500 # switches from Idle to Chase
var attack_range: float = 35 # switches from Chase to Attack
var speed: float = 85  # Minotaur's movement speed
var swirl_range = 44 # range that Minotaur will use swirl
var charge_range = 150 # range that Minotaur will use charge
var eruption_range = 200 # range that Minotaur will use eruption

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_parent().get_node("Player")
	

func _process(delta):
	match current_state:
		State.IDLE:
			idle_state(delta)
		State.CHASE:
			chase_state(delta)
		State.ATTACK:
			attack_state(delta)
		State.SWIRL:
			swirl_state(delta)
	flip_towards_player()


func idle_state(delta):
	minotaur.play("idle")
	if player_in_range(chase_range):
		current_state = State.CHASE
		
func chase_state(delta):
	minotaur.play("run")
	move_towards_player(delta)
	if player_in_range(swirl_range) and swirl_ready:
		current_state = State.SWIRL
	elif player_in_range(attack_range):
		current_state = State.ATTACK
	elif not player_in_range(chase_range):
		current_state = State.IDLE



func attack_state(delta):
	
	if is_attacking:
		return
	is_attacking = true
	var rng = RandomNumberGenerator.new()
	rng.randomize() 
	var random_number = rng.randi_range(1, 2)
	if random_number == 1:
		minotaur.play("attack2")
		await minotaur.animation_finished
		if in_attack_1_range:
			player.take_damage(30)
	else:
		minotaur.play("attack1")  
		await minotaur.animation_finished
		if in_attack_2_range:
			player.take_damage(50)
	
	is_attacking = false
	current_state = State.CHASE
	
func swirl_state(delta):
	
	if (is_attacking):
		return
	is_attacking = true
	
	minotaur.play("swirl")
	await minotaur.animation_finished
	swirl_timer.start()
	swirl_ready = false
	
	if in_swirl_range:
		player.take_damage(100)
	
	is_attacking = false
	current_state = State.CHASE


func player_in_range(range: float) -> bool:
	return position.distance_to(player.position) < range
	
func move_towards_player(delta):
	var direction = (player.position - position).normalized()
	direction.y = 0;
	position += direction * speed * delta

# Function to flip the Area2D horizontally
func flip_area2d_horizontally(area: Area2D, flip: bool):
	var scale = Vector2(-1 if flip else 1, 1)
	area.scale = scale


func flip_towards_player():
	if player.position.x < position.x:
		minotaur.flip_h = true  # Player is to the left, flip horizontally
		flip_area2d_horizontally(attack_1_area2d, true)
		flip_area2d_horizontally(attack_2_area2d, true)
	else:
		minotaur.flip_h = false
		flip_area2d_horizontally(attack_1_area2d, false)
		flip_area2d_horizontally(attack_2_area2d, false)


func _on_attack_1_range_body_entered(body):
	if body == player:
		in_attack_1_range = true

func _on_attack_1_range_body_exited(body):
	if body == player:
		in_attack_1_range = false

func _on_attack_2_range_body_entered(body):
	if body == player:
		in_attack_2_range = true

func _on_attack_2_range_body_exited(body):
	if body == player:
		in_attack_2_range = false

func _on_swirl_cooldown_timeout():
	swirl_ready = true

func _on_swirl_range_body_entered(body):
	in_swirl_range = true

func _on_swirl_range_body_exited(body):
	in_swirl_range = false

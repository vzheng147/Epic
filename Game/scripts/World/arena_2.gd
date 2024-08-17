extends Node2D

@onready var exit = $Exit
@onready var arrow1 = $ArrowTrap
@onready var arrow2 = $ArrowTrap2
@onready var arrow3 = $ArrowTrap3
@onready var arrow4 = $ArrowTrap4
@onready var arrow5 = $ArrowTrap5
@onready var arrow6 = $ArrowTrap6
@onready var arrow7 = $ArrowTrap7
@onready var arrow8 = $ArrowTrap8
@onready var arrow9 = $ArrowTrap9
@onready var arrow10 = $ArrowTrap10
@onready var arrow11 = $ArrowTrap11
@onready var arrow12 = $ArrowTrap12


@export var drop : ItemData
var back := "res://scenes/World/floor_2.tscn"
var destination := "res://scenes/World/floor_3.tscn"
var door := preload("res://scenes/World/door.tscn")
var chest := preload("res://scenes/Collectables/golden_chest.tscn")

func _ready():
	arrow1.arrowTrap.play("RESET")
	arrow2.arrowTrap.play("RESET")
	arrow3.arrowTrap.play("RESET")
	arrow4.arrowTrap.play("RESET")
	arrow5.arrowTrap.play("RESET")
	arrow6.arrowTrap.play("RESET")
	arrow7.arrowTrap.play("RESET")
	arrow8.arrowTrap.play("RESET")
	arrow9.arrowTrap.play("RESET")
	arrow10.arrowTrap.play("RESET")
	arrow11.arrowTrap.play("RESET")
	arrow12.arrowTrap.play("RESET")
	

func shoot():
	arrow1.visible = true
	arrow2.visible = true
	arrow3.visible = true
	arrow4.visible = true
	arrow5.visible = true
	arrow6.visible = true
	arrow7.visible = true
	arrow8.visible = true
	arrow9.visible = true
	arrow10.visible = true
	arrow11.visible = true
	arrow12.visible = true
	
	arrow1.arrowTrap.play("activate")
	arrow2.arrowTrap.play("activate")
	arrow3.arrowTrap.play("activate")
	arrow4.arrowTrap.play("activate")
	arrow5.arrowTrap.play("activate")
	arrow6.arrowTrap.play("activate")
	arrow7.arrowTrap.play("activate")
	arrow8.arrowTrap.play("activate")
	arrow9.arrowTrap.play("activate")
	arrow10.arrowTrap.play("activate")
	arrow11.arrowTrap.play("activate")
	arrow12.arrowTrap.play("activate")
	
	await get_tree().create_timer(4.5).timeout
	arrow1.arrowTrap.play("RESET")
	arrow2.arrowTrap.play("RESET")
	arrow3.arrowTrap.play("RESET")
	arrow4.arrowTrap.play("RESET")
	arrow5.arrowTrap.play("RESET")
	arrow6.arrowTrap.play("RESET")
	arrow7.arrowTrap.play("RESET")
	arrow8.arrowTrap.play("RESET")
	arrow9.arrowTrap.play("RESET")
	arrow10.arrowTrap.play("RESET")
	arrow11.arrowTrap.play("RESET")
	arrow12.arrowTrap.play("RESET")
	arrow1.visible = false
	arrow2.visible = false
	arrow3.visible = false
	arrow4.visible = false
	arrow5.visible = false
	arrow6.visible = false
	arrow7.visible = false
	arrow8.visible = false
	arrow9.visible = false
	arrow10.visible = false
	arrow11.visible = false
	arrow12.visible = false

func boss_death():
	var door_instance = door.instantiate()
	door_instance.destination = destination
	door_instance.global_position = Vector2(75, 35)
	add_child(door_instance)
	var chest_instance = chest.instantiate()
	chest_instance.drop = drop
	chest_instance.global_position = Vector2(30, 22)
	Global.player_position = Vector2(0, 0)
	add_child(chest_instance)
	
	
func _on_exit_pressed():
	Global.player_position = Vector2(958, 78)
	get_tree().change_scene_to_file(back)

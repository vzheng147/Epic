extends Node2D

@onready var signLabel = get_node("Label");
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	

func _on_detection_zone_body_entered(body):# Replace with function body.
	signLabel.visible = true;


func _on_detection_zone_body_exited(body):
	signLabel.visible = false;

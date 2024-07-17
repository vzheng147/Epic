extends Node

var coins_score = 0
var health_refill_bottle_number = 0
@onready var coins_score_label = $CoinsScoreLabel
@onready var hr_bnumberabel = $HRBnumberabel

func add_point():
	coins_score += 1
	coins_score_label.text = "You collected " + str(coins_score) + " coins."
	
func add_HRB():
	health_refill_bottle_number +=1
	hr_bnumberabel.text = "You collected " + str(health_refill_bottle_number) + " HRBs ."

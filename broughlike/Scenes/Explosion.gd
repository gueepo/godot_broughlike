extends Node2D

const DESTROY_TIME = 0.2
var self_timer = null

func _ready():
	print ("starting explo")
	# wait some time and destroy thyself
	self_timer = Timer.new()
	self_timer.set_wait_time(DESTROY_TIME)
	self_timer.set_one_shot(true)
	self_timer.connect("timeout", self, "_on_timer_timeout")
	add_child(self_timer)
	self_timer.start()
	

func _on_timer_timeout():
	print("timer over")
	self_timer.queue_free()
	self_timer = null
	queue_free()

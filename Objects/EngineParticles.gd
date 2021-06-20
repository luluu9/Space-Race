extends Particles2D

# types of emitting
var boost = false
var accel = false

func set_type(type, value):
	match type:
		"boost":
			boost = value
		"accel":
			accel = value

func emit(type):
	self.emitting = true
	set_type(type, true)

func stop_emit(type):
	set_type(type, false)
	if !boost and !accel:
		self.emitting = false

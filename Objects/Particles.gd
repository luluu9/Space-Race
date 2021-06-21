extends Node

onready var engine_particles = $EngineParticles
# types of engine emitting
var boost = false
var accel = false

onready var left_side_particles = $LeftSideParticles
onready var right_side_particles = $RightSideParticles

func set_type_engine(type, value):
	match type:
		"boost":
			boost = value
		"accel":
			accel = value

remotesync func emit_engine(type):
	engine_particles.emitting = true
	set_type_engine(type, true)

remotesync func stop_emit_engine(type):
	set_type_engine(type, false)
	if !boost and !accel:
		engine_particles.emitting = false

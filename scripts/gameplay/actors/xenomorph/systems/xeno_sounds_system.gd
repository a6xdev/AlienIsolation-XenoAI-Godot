extends Node3D

@onready var actor_xenomorph: Xenomorph = $".."
@onready var voice_over: AudioStreamPlayer3D = $VoiceOver
@onready var footstep_sound: AudioStreamPlayer3D = $FootstepSound

enum SoundType {
	PATROL,
	PATROL_AWAY_PLAYER,
	INVESTIGATE,
	CHASE
}

@export var patrol_sounds:AudioStreamRandomizer = null
@export var patrol_away_sounds:AudioStreamRandomizer = null ## Away from player
@export var investigate_sounds:AudioStreamRandomizer = null
@export var chase_sounds:AudioStreamRandomizer = null

var footstep_timer = 0.0
var footstep_interval = 0.55

func _process(delta: float) -> void:
	footstep_timer += delta
	
	if not actor_xenomorph.is_stopped and actor_xenomorph.is_on_floor() and not actor_xenomorph.is_on_duct:
		if footstep_timer >= footstep_interval and actor_xenomorph.velocity.length() > 0.1:
			var sound_event := SoundEvent.new()
			add_child(sound_event)
			
			if actor_xenomorph.is_running:
				footstep_interval = 0.6
				footstep_sound.play()
				footstep_sound.volume_db = 10.0
				sound_event.max_distance = 50.0
				sound_event.global_position = global_position
			elif actor_xenomorph.is_walking:
				footstep_interval = 1.0
				footstep_sound.play()
				footstep_sound.volume_db = 0.0
				sound_event.max_distance = 30.0
				sound_event.global_position = global_position
			
			footstep_timer = 0.0

func play_sound(type:SoundType) -> void:
	if not voice_over.playing:
		match type:
			SoundType.PATROL:
				voice_over.stream = patrol_sounds
			SoundType.PATROL_AWAY_PLAYER:
				voice_over.stream = patrol_away_sounds
			SoundType.INVESTIGATE:
				voice_over.stream = investigate_sounds
			SoundType.CHASE:
				voice_over.stream = chase_sounds
		
		if voice_over.stream:
			voice_over.play()

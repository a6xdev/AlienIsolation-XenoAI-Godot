extends Node3D

@onready var actor_xenomorph: Xenomorph = $".."
@onready var ai_chase: Node = $"../behaviors/AI_CHASE"
@onready var ai_investigate: Node = $"../behaviors/AI_INVESTIGATE"
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
#region SIGNALS
#endregion SIGNALS

class_name BaseStructure
extends StaticBody2D


@export var _team: Color = Color(0.5, 0.5, 0.5)
@export var _maxHP: float = 10000.0
@export var _armorVal: float = 10.0
@export var _sightRadius = 256.0
@export var _weaponRange = 0.0
@export var _aimingErr: float = 128.0
@export var _weaponDamageMax: float = 0.0
@export var _weaponCooldownMax: float = 1.0
@export var _isActive: bool = false

@onready var _sprite: Sprite2D = $StructureSprite

const TEAM_NEUTRAL: Color = Color(0.5, 0.5, 0.5)

var _HP: float
var _weaponCooldown: float
var _shootTarget: Vector2
var _lookDirection: Vector2
var _isDestroyed: bool
var _captureProgress: Dictionary

# Called when the node enters the scene tree for the first time.
func _ready():
	_sprite.modulate = _team
	_HP = _maxHP
	_weaponCooldown = 0.0
	_lookDirection = ((get_viewport_rect().size * 0.5) - global_position).normalized()
	_isDestroyed = false
	if _team != TEAM_NEUTRAL:
		_captureProgress = {_team: 1.0}
	else:
		_captureProgress = {TEAM_NEUTRAL: 0.0}

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if _isActive:
		pass

func takeDamage(dmg: float) -> void:
	_HP = _HP - dmg
	if _HP < 0.0 or is_zero_approx(_HP):
		_HP = 0.0
		destroy()

func _capture(capturingTeam: Color, progress: float) -> void:
	if _captureProgress.has(capturingTeam):
		var currentProgress = _captureProgress.get(capturingTeam) + progress
		if currentProgress >= 1.0:
			if _team == TEAM_NEUTRAL:
				set_team(capturingTeam)
	else:
		var currentProgress = _captureProgress.get(_captureProgress.keys[0]) - progress
		if currentProgress < 0.0:
			set_neutral()
			_captureProgress = {capturingTeam: abs(currentProgress)}

func set_team(newTeam: Color) -> void:
	_team = newTeam
	if _team == TEAM_NEUTRAL: _isActive = false
	else: _isActive = true

func set_neutral() -> void:
	_team = TEAM_NEUTRAL
	_isActive = false

func destroy() -> void:
	_isActive = false
	_isDestroyed = true
	_sprite.modulate = _team * 0.1

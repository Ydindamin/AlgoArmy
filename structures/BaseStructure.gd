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

const TEAM_NEUTRAL: Color = Color(0.5, 0.5, 0.5)

var _HP: float
var _weaponCooldown: float
var _shootTarget: Vector2
var _lookDirection: Vector2
var _isDestroyed: bool
var _captureTeam: Color
var _captureProgress: float
var _sprite: Sprite2D
var _captureArea: Area2D
var _unitsInArea: Array

# Called when the node enters the scene tree for the first time.
func _ready():
	_sprite.modulate = _team
	_HP = _maxHP
	_weaponCooldown = 0.0
	_lookDirection = ((get_viewport_rect().size * 0.5) - global_position).normalized()
	_isDestroyed = false
	_unitsInArea = []
	_captureTeam = _team
	if _team == TEAM_NEUTRAL:
		_captureProgress = 0.0
	else:
		_captureProgress = 1.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#if _isActive:
		#pass

func take_damage(dmg: float) -> void:
	_HP = _HP - dmg
	if _HP < 0.0 or is_zero_approx(_HP):
		_HP = 0.0
		destroy()

func get_capturers() -> Array:
	var units = ($CaptureArea.get_overlapping_bodies()).map(func(unit) -> BaseUnit: return unit as BaseUnit).filter(func(unit) -> bool: return unit != null)
	return units

func capture(capturingTeam: Color, newProgress: float, bar: ProgressBar) -> void:
	if capturingTeam == _captureTeam:
		_captureProgress = _captureProgress + newProgress
	else:
		_captureProgress = _captureProgress - newProgress
	
	if _captureProgress >= 1.0:
		_captureProgress = 1.0
		if _captureTeam != _team:
			set_team(_captureTeam)
	elif _captureProgress < 0.0:
		if _team != TEAM_NEUTRAL:
			set_neutral()
		_captureTeam = capturingTeam
		_captureProgress = abs(_captureProgress)
	
	bar.value = _captureProgress
	bar.get_theme_stylebox("fill").set_bg_color(_captureTeam)
	
	if _captureTeam == _team and _captureProgress == 1.0:
		bar.visible = false
	else:
		bar.visible
	
	#if _captureProgress.has(capturingTeam):
		#var currentProgress = _captureProgress.get(capturingTeam) + newProgress
		#if currentProgress >= 1.0:
			#if _team == TEAM_NEUTRAL:
				#set_team(capturingTeam)
	#else:
		#var currentProgress = _captureProgress.get(_captureProgress.keys[0]) - newProgress
		#if currentProgress < 0.0:
			#set_neutral()
			#_captureProgress = {capturingTeam: abs(currentProgress)}

func set_team(newTeam: Color) -> void:
	_team = newTeam
	_sprite.modulate = _team
	_isActive = true

func set_neutral() -> void:
	_team = TEAM_NEUTRAL
	_sprite.modulate = TEAM_NEUTRAL
	_isActive = false

func destroy() -> void:
	_isActive = false
	_isDestroyed = true
	_sprite.modulate = _team * 0.1

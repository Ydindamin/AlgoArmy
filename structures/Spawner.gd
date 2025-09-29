class_name Spawner
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
@export var _spawnCooldownMax: float = 10.0
@export var _unitToSpawn: BaseUnit

const TEAM_NEUTRAL: Color = Color(0.5, 0.5, 0.5)
const UNIT_TEMPLATE: PackedScene = preload("res://units/BaseUnit.tscn")

@onready var _sprite: Sprite2D = $SpawnerSprite
@onready var _captureArea: Area2D = $CaptureArea
@onready var _captureBar: ProgressBar = $CaptureBar
@onready var _rallyPoint: Vector2 = $RallyPoint.global_position

var _HP: float
var _weaponCooldown: float
var _shootTarget: Vector2
var _lookDirection: Vector2
var _isDestroyed: bool
var _captureTeam: Color
var _captureProgress: float
var _unitsInArea: Array
var _spawnCooldown: float


# Called when the node enters the scene tree for the first time.
func _ready():
	_sprite.modulate = _team
	_spawnCooldown = _spawnCooldownMax

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_unitsInArea = get_capturers()
	for u: BaseUnit in _unitsInArea:
		capture(u._team, 0.333 * delta, _captureBar)
	if _isActive:
		_spawnCooldown = _spawnCooldown - delta
		if _spawnCooldown <= 0.0:
			spawn_unit(UNIT_TEMPLATE)
			_spawnCooldown = _spawnCooldown + _spawnCooldownMax
	else:
		_spawnCooldown = _spawnCooldownMax


func take_damage(dmg: float) -> void:
	_HP = _HP - dmg
	if _HP < 0.0 or is_zero_approx(_HP):
		_HP = 0.0
		destroy()

func spawn_unit(unitToSpawn: PackedScene) -> void:
	var newUnit = unitToSpawn.instantiate()

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

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
@export var _spawnCooldownMax: float = 8.0
@export var _rallyPoint: Node2D

const TEAM_NEUTRAL: Color = Color(0.5, 0.5, 0.5)
const UNIT_TEMPLATE: PackedScene = preload("res://units/BaseUnit.tscn")

@onready var _sprite: Sprite2D = $SpawnerSprite
@onready var _captureArea: Area2D = $CaptureArea
@onready var _captureBar: ProgressBar = $CaptureBar

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
	if _team != TEAM_NEUTRAL:
		_captureTeam = _team
		_captureProgress = 1.0
		_isActive = true
	else:
		_captureTeam = TEAM_NEUTRAL
		_captureProgress = 0.0
		_isActive = false
	_captureBar.value = _captureProgress
	_captureBar.get_theme_stylebox("fill").set_bg_color(_captureTeam)
	_spawnCooldown = _spawnCooldownMax

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_unitsInArea = get_capturers()
	if _unitsInArea.size() > 0:
		capture(_unitsInArea)
	
	#for u: BaseUnit in _unitsInArea:
		#capture(u._team, 0.1 * delta)
	
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
	add_child(newUnit)
	newUnit.init(self)

func get_capturers() -> Array:
	var units = (_captureArea.get_overlapping_bodies()).map(func(unit) -> BaseUnit: return unit as BaseUnit).filter(func(unit) -> bool: return unit != null)
	return units

func capture(units: Array) -> void:
	var capturers: Dictionary
	
	for u: BaseUnit in units: # group capturers by team
		if !capturers.has(u._team):
			capturers.set({u._team: 1})
		else:
			capturers.set({u._team: capturers.get(u._team) + 1})
	
	if capturers.size() > 0:
		determine_capture(capturers)

func determine_capture(capturers: Dictionary) -> void:
	var captureCounts: Array = capturers.values()
	captureCounts.sort()
	var mostCount: int = captureCounts[-1]
	var secondMostCount: int = 0
	
	if capturers.size() > 1:
		secondMostCount = captureCounts[-2]
	
	var captureQuantity: int = mostCount - secondMostCount
	if captureQuantity > 0:
		advance_capture(capturers.find_key(mostCount), captureQuantity)

func advance_capture(capturingTeam: Color, capturingQty: int) -> void:
	if capturingTeam == _captureTeam:
		_captureProgress = _captureProgress + capturingQty
	else:
		_captureProgress = _captureProgress - capturingQty
	
	if _captureProgress >= 1.0:
		_captureProgress = 1.0
		if _captureTeam != _team:
			set_team(_captureTeam)
	elif _captureProgress < 0.0:
		if _team != TEAM_NEUTRAL:
			set_neutral()
		_captureTeam = capturingTeam
		_captureProgress = abs(_captureProgress)
	
	_captureBar.value = _captureProgress
	_captureBar.get_theme_stylebox("fill").set_bg_color(_captureTeam)
	
	if _captureTeam == _team and _captureProgress == 1.0:
		_captureBar.visible = false
	else:
		_captureBar.visible = true

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

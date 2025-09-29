class_name BaseUnit
extends CharacterBody2D


@export var _team: Color = Color(0.5, 0.5, 0.5)
@export var _maxHP: float = 100.0
@export var _armorVal: float = 0.0
@export var _moveSpeed: float = 100.0
@export var _visionDistance: float = 256.0
@export var _weaponRange: float = 128.0
@export var _aimingErr: float = 32.0
@export var _weaponDamageMax: float = 10.0
@export var _weaponCooldownMax: float = 0.333
@export var _behaviorState: States = States.RALLY
@export var _oscillatorMax: float = 10.0

@onready var _sprite: Sprite2D = $UnitSprite
@onready var _sightRadius: Area2D = $SightRadius

const SQUAD_SIZE_MAX: int = 1								# (TODO: implement squads)

var _spawner: Spawner
var _HP: float
var _weaponCooldown: float
var _shootTarget: Vector2
var _lookDirection: Vector2
var _moveTarget: Vector2
var _squadSize: int											# (TODO: implement squads)
var _protectTarget: BaseUnit
var _oscillator: float


enum States {
	INACTIVE,
	RALLY,
	MOVE,
	SEARCH,
	CAPTURE,
	PROTECT,
	DEAD
}


func _ready():
	print_debug("Unit Ready!")
	_sprite.modulate = _team
	_spawner = get_parent()
	_HP = _maxHP
	_weaponCooldown = 0.0
	_lookDirection = ((get_viewport_rect().size * 0.5) - global_position).normalized()
	_behaviorState = States.RALLY
	_sightRadius.get_child(0).shape.radius = _visionDistance
	_oscillator = _oscillatorMax

func _physics_process(delta):
	_oscillator = _oscillator - delta
	if _oscillator < 0.0:
		_oscillator = _oscillator + _oscillatorMax
	if !(_behaviorState == States.INACTIVE or _behaviorState == States.DEAD):
		determine_move_target()
		var moveVector: Vector2 = determine_move_vector()
		
		velocity = moveVector.normalized() * _moveSpeed
		move_and_slide()


func init(origin: Spawner):
	print_debug("Unit Init!")
	_sprite = $UnitSprite
	_sightRadius = $SightRadius
	_spawner = origin
	_team = _spawner._team
	_sprite.modulate = _team
	_behaviorState = States.RALLY
	_moveTarget = _spawner._rallyPoint.global_position


func scan_for_units() -> Array:
	var entities = (_sightRadius.get_overlapping_bodies()).map(func(entity) -> BaseUnit: return entity as BaseUnit).filter(func(entity) -> bool: return entity != null)
	return entities

func scan_for_spawners() -> Array:
	var entities = (_sightRadius.get_overlapping_bodies()).map(func(entity) -> Spawner: return entity as Spawner).filter(func(entity) -> bool: return entity != null)
	return entities

func determine_move_target() -> void:
	if _behaviorState == States.INACTIVE:
		_moveTarget = global_position
	if _behaviorState == States.RALLY:
		_moveTarget = get_parent()._rallyPoint.global_position
		if (_moveTarget - global_position).length() < 64.0: 
			_behaviorState = States.SEARCH
	if _behaviorState == States.MOVE:
		if (_moveTarget - global_position).length() < 64.0: 
			_behaviorState = States.SEARCH
	if _behaviorState == States.SEARCH:
		for s: Spawner in scan_for_spawners():
			if s._team != _team:
				_behaviorState = States.CAPTURE
				_moveTarget = s.global_position
				return
		if (_moveTarget - global_position).length() < 64.0:
			_moveTarget = Vector2(randf() * get_viewport().size.x, randf() * get_viewport().size.y)
	if _behaviorState == States.CAPTURE:
		for s: Spawner in scan_for_spawners():
			if s._team != _team:
				_moveTarget = s.global_position
				return
		_moveTarget = Vector2(randf() * get_viewport().size.x, randf() * get_viewport().size.y)
		_behaviorState = States.SEARCH
	if _behaviorState == States.PROTECT:
		_moveTarget = _protectTarget.global_position
	if _behaviorState == States.DEAD:
		_moveTarget = global_position

func determine_move_vector() -> Vector2:
	var newMoveVector: Vector2 = _moveTarget - global_position
	if abs(newMoveVector.x) <= _sprite.get_rect().size.x:
		newMoveVector.x = 0
	if abs(newMoveVector.y) <= _sprite.get_rect().size.y:
		newMoveVector.y = 0
	return newMoveVector

func take_damage(dmg: float) -> void:
	_HP = _HP - dmg
	if _HP < 0.0 or is_zero_approx(_HP):
		_HP = 0.0
		_sprite.modulate = _team * 0.1
		_behaviorState = States.DEAD

func die() -> void:
	pass

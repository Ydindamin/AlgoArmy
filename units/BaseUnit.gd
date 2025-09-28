class_name BaseUnit
extends CharacterBody2D


@export var _team: Color = Color(0.5, 0.5, 0.5)
@export var _maxHP: float = 100.0
@export var _armorVal: float = 0.0
@export var _moveSpeed = 100.0
@export var _sightRadius = 256.0
@export var _weaponRange = 128.0
@export var _aimingErr: float = 32.0
@export var _weaponDamageMax: float = 10.0
@export var _weaponCooldownMax: float = 0.333
@export var _behaviorState: States = States.STANDGROUND

@onready var _sprite: Sprite2D = $UnitSprite

const SQUAD_SIZE_MAX: int = 1								# (TODO: implement squads)

var _spawner: Spawner
var _HP: float
var _weaponCooldown: float
var _shootTarget: Vector2
var _lookDirection: Vector2
var _moveTarget: Vector2
var _squadSize: int											# (TODO: implement squads)
var _protectTarget: BaseUnit


enum States {
	INACTIVE,
	RALLY,
	MOVE,
	ATTACKMOVE,
	SEARCH,
	STANDGROUND,
	PROTECT,
	CONSOLIDATE,												# (TODO: implement squads)
	DEAD
}


func _ready():
	_sprite.modulate = _team
	_HP = _maxHP
	_weaponCooldown = 0.0
	_lookDirection = ((get_viewport_rect().size * 0.5) - global_position).normalized()
	_behaviorState = States.RALLY

func _physics_process(delta):
	
	if !(_behaviorState == States.INACTIVE or _behaviorState == States.DEAD):
		_behaviorState = evaluateState()
		var mousePosition: Vector2 = get_viewport().get_mouse_position()
		_moveTarget = determineMoveTarget(mousePosition)
		var moveVector: Vector2 = determineMoveVector()
		
		velocity = moveVector.normalized() * _moveSpeed
		move_and_slide()


func init(spawnedFrom: Spawner):
	pass


func determineAction() -> void:
	if _behaviorState == States.INACTIVE:
		pass
	if _behaviorState == States.RALLY:
		pass
	if _behaviorState == States.MOVE:
		pass
	if _behaviorState == States.ATTACKMOVE:
		pass
	if _behaviorState == States.SEARCH:
		pass
	if _behaviorState == States.STANDGROUND:
		pass
	if _behaviorState == States.PROTECT:
		pass
	if _behaviorState == States.CONSOLIDATE:					# (TODO: implement squads)
		_behaviorState = States.SEARCH
	if _behaviorState == States.DEAD:
		pass

func evaluateState() -> States:
	return States.ATTACKMOVE

func determineMoveTarget(mousePos: Vector2) -> Vector2:
	return mousePos

func determineMoveVector() -> Vector2:
	var newMoveVector: Vector2 = _moveTarget - global_position
	if abs(newMoveVector.x) <= _sprite.get_rect().size.x:
		newMoveVector.x = 0
	if abs(newMoveVector.y) <= _sprite.get_rect().size.y:
		newMoveVector.y = 0
	return newMoveVector

func takeDamage(dmg: float) -> void:
	_HP = _HP - dmg
	if _HP < 0.0 or is_zero_approx(_HP):
		_HP = 0.0
		_sprite.modulate = _team * 0.1
		_behaviorState = States.DEAD

func die() -> void:
	pass

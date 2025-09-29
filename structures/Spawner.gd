class_name Spawner
extends BaseStructure


@export var _rallyPoint: Vector2 = Vector2(0.0, 0.0)
@export var _spawnCooldownMax: float = 10.0
@export var _unitToSpawn: BaseUnit

var _spawnCooldown: float
var _captureBar: ProgressBar


# Called when the node enters the scene tree for the first time.
func _ready():
	_sprite = $SpawnerSprite
	_captureArea = $CaptureArea
	_captureBar = $CaptureBar
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
			spawn_unit()
			_spawnCooldown = _spawnCooldown + _spawnCooldownMax
	else:
		_spawnCooldown = _spawnCooldownMax


func spawn_unit() -> void:
	pass

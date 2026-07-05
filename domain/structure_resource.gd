class_name StructureResource
extends Resource

@export var name: String
@export var texture: Texture2D
@export var bound_resource: GameResource
@export var building_limit_amount: int = 0 # <=0 no limit
@export var building_cost: Array[Transaction]
@export var on_build_earnings: Array[Transaction]
@export var setup_phase_production: Array[GameResourceFormula]
@export var turn_production: Array[GameResourceFormula]

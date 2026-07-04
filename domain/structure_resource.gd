class_name StructureResource
extends Resource

@export var name: String
@export var texture: Texture2D
# <=0 no limit
@export var building_limit_amount: int = 0
@export var building_cost: Array[Transaction]

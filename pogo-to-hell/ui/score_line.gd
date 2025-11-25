extends HBoxContainer


@export var score_name: String
@export var time: float
@export var score: int
@export var place: int


@onready var name_label: Label = $NameLabel
@onready var time_label: Label = $TimeLabel
@onready var score_label: Label = $ScoreLabel
@onready var place_label: Label = $PlaceLabel


func _ready() -> void:
	place_label.text = str(place)
	name_label.text = score_name
	time_label.text = "%0.2fs" %time
	score_label.text = str(score)

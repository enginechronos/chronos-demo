extends Area2D

var player_in := false
onready var hud = get_node("../HUD/Message")

var _did_steal := false

func _ready():
	connect("body_entered", self, "_on_enter")
	connect("body_exited", self, "_on_exit")

func _on_enter(body):
	if body.name == "Player":
		player_in = true
		if _did_steal:
			hud.text = "You already stole the apple. Go to the guard."
		else:
			hud.text = "Press E to steal an apple."

func _on_exit(body):
	if body.name == "Player":
		player_in = false
		hud.text = ""

func _process(_delta):
	# Prevent spamming requests if player holds E
	if not player_in:
		return
	if _did_steal:
		return

	if Input.is_action_just_pressed("interact"):
		_did_steal = true
		hud.text = "You stole an apple..."

		print("MERCHANT: queueing Chronos calls...")

		# 1) Append event
		Chronos.append_event(
			"player_1",
			"player_stole_item",
			{"item": "apple", "from": "merchant_1"},
			true
		)

		# 2) Ask brain to process
		Chronos.brain_think(50)

		# 3) Refresh guard state
		Chronos.get_npc_state("guard_1")

		print("MERCHANT: queued append + think + get_state")

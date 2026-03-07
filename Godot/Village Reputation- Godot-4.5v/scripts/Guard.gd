extends Area2D

var player_in := false
var mood := "neutral"

# UPDATED PATHS: Based on your scene tree
@onready var hud: Label = get_node("../HUD/Message")
@onready var gate: CollisionShape2D = get_node("../Gate Blocker/CollisionShape2D")

const NPC_ID := "guard_1"

func _ready() -> void:
	body_entered.connect(_on_enter)
	body_exited.connect(_on_exit)

	Chronos.npc_state_updated.connect(_on_npc_state_updated)

	# UPDATED PATH: ReputationActions is a sibling to Guard under Main
	var rep = get_node_or_null("../ReputationActions")
	if rep:
		rep.demo_mood_changed.connect(_on_demo_mood_changed)

	print("GUARD: requesting initial npc state...")
	Chronos.get_npc_state(NPC_ID)

func _on_enter(body: Node) -> void:
	if body.name == "Player":
		player_in = true
		_show_dialog()

func _on_exit(body: Node) -> void:
	if body.name == "Player":
		player_in = false
		if hud: hud.text = ""

func _on_demo_mood_changed(new_mood) -> void:
	mood = str(new_mood)
	print("GUARD: demo mood applied →", mood)
	_apply_mood()

func _on_npc_state_updated(row) -> void:
	if typeof(row) != TYPE_DICTIONARY or not row.has("npc_id") or str(row["npc_id"]) != NPC_ID:
		return

	var state = row.get("state", {})
	if state.has("state") and typeof(state["state"]) == TYPE_DICTIONARY:
		state = state["state"]

	if state.has("mood"):
		mood = str(state["mood"])
		_apply_mood()

func _show_dialog() -> void:
	if not hud: return
	if mood == "friendly":
		hud.text = "Guard: Welcome, friend 🙂"
	elif mood == "suspicious":
		hud.text = "Guard: Hmm… I’m watching you."
	elif mood == "hostile":
		hud.text = "Guard: STOP. You’re not allowed through!"
	else:
		hud.text = "Guard: Good day."

func _apply_mood() -> void:
	if gate:
		var block := (mood == "hostile")
		gate.set_deferred("disabled", not block)

	if player_in:
		_show_dialog()

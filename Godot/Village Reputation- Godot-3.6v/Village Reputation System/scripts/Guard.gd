extends Area2D

var player_in := false
var mood := "calm"

onready var hud = get_node("../HUD/Message")
onready var gate = get_node("../GateBlocker/CollisionShape2D")

func _ready():
	connect("body_entered", self, "_on_enter")
	connect("body_exited", self, "_on_exit")

	Chronos.connect("request_ok", self, "_on_chronos_ok")

	# Load remembered state on startup
	print("GUARD: requesting initial npc state...")
	Chronos.get_npc_state("guard_1")

func _on_enter(body):
	if body.name == "Player":
		player_in = true
		_show_dialog()

func _on_exit(body):
	if body.name == "Player":
		player_in = false
		hud.text = ""

func _show_dialog():
	if mood == "calm":
		hud.text = "Guard: All is peaceful."
	else:
		hud.text = "Guard: STOP. Something feels wrong..."

func _on_chronos_ok(tag, data):

	if tag != "npc.state":
		return

	if typeof(data) != TYPE_DICTIONARY:
		return

	if not data.has("state"):
		print("GUARD: npc.state missing state field →", data)
		return

	var state = data["state"]

	if typeof(state) != TYPE_DICTIONARY:
		return

	if state.has("mood"):
		mood = state["mood"]

	print("GUARD: mood updated →", mood)

	_apply_mood()

func _apply_mood():

	if mood == "suspicious":
		hud.text = "Guard: Thief detected 🚨"
		gate.disabled = false   # BLOCK PLAYER
	else:
		gate.disabled = true    # OPEN PATH

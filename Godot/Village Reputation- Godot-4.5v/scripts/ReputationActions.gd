extends Node

signal demo_mood_changed(mood)

# UPDATED PATH: Go up to Main, then down to HUD/Message
@onready var hud: Label = get_node("../HUD/Message")

var reputation_score := 0
var _next_brain_time := 0

func _ready() -> void:
	print("REPUTATION: system ready")
	Chronos.request_ok.connect(_on_ok)
	Chronos.request_err.connect(_on_err)

func _on_ok(tag, data) -> void:
	if tag != "npc.state": return
	
	var mood_from_server := _extract_mood_from_npc_state(data)
	if mood_from_server != "":
		_apply_guard_dialog(mood_from_server)
		demo_mood_changed.emit(mood_from_server)
		return

	var fallback := _mood_from_score()
	_apply_guard_dialog(fallback)
	demo_mood_changed.emit(fallback)

# FIXED LINE 29: Added underscores to unused parameters to remove the red/yellow marks
func _on_err(_tag, code, _message, _raw) -> void: 
	if int(code) == 429 and hud:
		hud.text = "Rate limited. Try again in ~60s."

# FIXED NAMES: Changed to lowercase to match your button signals
func _on_btn_help_pressed() -> void:
	if hud: hud.text = "You helped a villager 🙂"
	reputation_score += 1
	_send_event_and_refresh("player_helped_villager", {"target": "villager_1"})

func _on_btn_donate_pressed() -> void:
	if hud: hud.text = "You donated coins 💰"
	reputation_score += 2
	_send_event_and_refresh("player_donated_coin", {"amount": 5})

func _on_btn_lie_pressed() -> void:
	if hud: hud.text = "You lied to the guard 😈"
	reputation_score = -3
	_send_event_and_refresh("player_lied_to_guard", {"context": "conversation"})

func _send_event_and_refresh(event_type: String, payload: Dictionary) -> void:
	Chronos.append_event("player_1", event_type, payload, true)
	
	var now := int(Time.get_unix_time_from_system())
	if now >= _next_brain_time:
		_next_brain_time = now + 15
		Chronos.brain_think(50)
	
	Chronos.get_npc_state("guard_1")
	
	var mood_local := _mood_from_score()
	_apply_guard_dialog(mood_local)
	demo_mood_changed.emit(mood_local)

func _mood_from_score() -> String:
	if reputation_score >= 3: return "friendly"
	if reputation_score <= -3: return "hostile"
	if reputation_score < 0: return "suspicious"
	return "neutral"

func _extract_mood_from_npc_state(data) -> String:
	if typeof(data) != TYPE_DICTIONARY or not data.has("state"): return ""
	var state = data["state"]
	if typeof(state) == TYPE_DICTIONARY and state.has("state"): state = state["state"]
	return str(state.get("mood", ""))

func _apply_guard_dialog(mood_value: String) -> void:
	if not hud: return
	if mood_value == "friendly":
		hud.text = "Guard: Welcome, friend 🙂"
	elif mood_value == "suspicious":
		hud.text = "Guard: Hmm… I’m watching you."
	elif mood_value == "hostile":
		hud.text = "Guard: STOP. You’re not allowed through!"
	else:
		hud.text = "Guard: Good day."

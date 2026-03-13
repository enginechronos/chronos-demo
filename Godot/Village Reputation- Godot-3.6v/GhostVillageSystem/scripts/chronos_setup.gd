extends Node

func _ready():
	print("SETUP: running chronos_setup.gd")

	# ----------------------------------------
	# Core Chronos connection
	# ----------------------------------------
	Chronos.configure(
		"https://chronos-magic-engine-live.vercel.app",
		"CHRONOS_xxxxxxxx",
		"reputat_xx",
		"guard_1"
	)

	# ----------------------------------------
	#  runtime config
	# ----------------------------------------
	# auto_brain_enabled = true
	# auto_brain_min_interval_sec = 2
	# auto_brain_max_events = 50
	Chronos.configure_runtime(true, 2, 50)

	# ----------------------------------------
	# Clean up old signal wiring if it exists
	# ----------------------------------------
	if Chronos.is_connected("status", self, "_on_status"):
		Chronos.disconnect("status", self, "_on_status")
	if Chronos.is_connected("request_ok", self, "_on_ok"):
		Chronos.disconnect("request_ok", self, "_on_ok")
	if Chronos.is_connected("request_err", self, "_on_err"):
		Chronos.disconnect("request_err", self, "_on_err")

	# ----------------------------------------
	# Connect only what we want now
	# ----------------------------------------
	Chronos.connect("status", self, "_on_status")

	# Optional: keep these connected silently so old signal paths never break
	Chronos.connect("request_ok", self, "_on_ok")
	Chronos.connect("request_err", self, "_on_err")

	# ----------------------------------------
	# Start runtime
	# ----------------------------------------
	Chronos.start()

	print("SETUP: Chronos configured + started")


func _on_status(msg):
	print("[Chronos STATUS]", msg)
 

# Keep these methods so stale/old signal paths never throw debugger errors.
# Intentionally silent to avoid duplicate logs.
func _on_ok(_tag, _data):
	pass


func _on_err(_tag, _code, _message, _raw):
	pass

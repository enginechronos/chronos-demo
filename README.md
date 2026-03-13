# Chronos Demo 0.1v — Persistent NPC Memory Example

From non-persistent NPC logic to persistent world memory — with only a small Chronos SDK integration.

This demo shows how a simple non-persistent NPC interaction can become persistent using the Chronos SDK.  
The game sends events, Chronos stores memory, derives NPC state, and restores that behavior across sessions.

---

## Demo Repository

Full demo project:

https://github.com/enginechronos/chronos-demo

This repository contains the minimal Godot integration used to demonstrate persistent NPC behavior using Chronos.

---

## What this demo proves

- A game can send simple gameplay events to Chronos
- Chronos automatically derives NPC state
- NPC behavior persists across sessions
- The same game logic can be tuned later through server-side rules

---

## Demo flow

1. Player interacts with the guard  
2. Game sends a Chronos event  
3. Chronos stores world memory  
4. Brain derives new NPC state  
5. Guard behavior changes  
6. After reopening the game, the guard still remembers

---

## Minimal SDK calls used in this demo


```gdscript
Chronos.append_event(...)
Chronos.connect("npc_state_updated", self, "_on_npc_state_updated")
Chronos.get_npc_state("guard_1") # initial load


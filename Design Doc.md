# Agent Game: Design Doc

**Created by:** David Anthony Martinez
**Original notes:** `Projects\Video Games\agent.txt` (project start 11/02/2017)
**Doc started:** 10/07/2026

---

## Core idea
A **think-before-you-act** game. The Agent scans, plans, then executes. Information matters more than reflexes, and combat is fast and lethal on both sides.

This game split off from the action "megametroidvania" concept. That game is about power growth and beat-'em-up action, and this one is about stealth and tactics.

---

## World (from the 2017 notes)
High-tech near future:
- Advanced AI, cloud computing
- Drones, robots, surrogates (self-driving or flying)
- Androids, exo-suits
- Smart objects and devices
  - **Privacy bubble**: sensor and detector blockers, anti-recognition tech
  - Wearable tech: watches and wristbands, fashionable tech jewelry
  - Internet glasses or contacts (microscope, binocular, telescope; **full EM spectrum**)
  - Advanced sensors
- Personal networks and satellite uplinks
- Flexible surface screens (walls, counters, doors)
- **"WiFi" see-through-wall**
- AR/VR, BCI devices
- Graphene replacing silicon
- Genetic modification and engineering, cloning
- Awake, dream and thought imaging, recording and sharing
- Metamaterials and superconductors
- 3D printing
- Portable diagnostics
- **Human body shop**

---

## The Agent's gear (from the 2017 notes)

**Badge/ID (hand-held)**
- Computer (AI)
- Communicator
- Scanner

**Weapon (hand-held)**
- Directed energy beam or blast (weak to strong)
- Energy shield or disruptor
- Self-destruct

**Surface vehicle**
- AI, communicator, scanner
- Torpedoes, mines, missiles, rockets
- Energy beam, shield or disruptor
- Self-destruct, stealth

**Drone**
- AI, communicator, scanner
- Energy beam, shield or disruptor
- Self-destruct, stealth

---

## Mechanics ideas (from brainstorming)

### Upgrades: a separate tree per device (decided 10/08/2026)
Every device is built from the same kinds of modules (**AI, communicator, scanner, beam, shield or disruptor, self-destruct, stealth**), but each device (badge, weapon, drone, vehicle) has **its own upgrade tree**, so the player chooses where to invest. Missions award skill points.

### Gear → gameplay
| Gear | Gameplay role |
|---|---|
| Scanner | Reveals enemies, weak points, hidden paths, armor types |
| Energy beam (weak to strong) | Quick shot vs. a charged shot (trade-off: noise and time) |
| Shield or disruptor | Block, or a pulse that disables tech and armor |
| Self-destruct | Last-resort overload; drone kamikaze; destroying evidence |
| Drone | Scouting ahead, distractions, remote actions |
| Vehicle | Insertion and extraction, chase sequences, mobile base |
| Badge AI | Mission guide, intel, hacking |

### World tech → mechanics
- **Privacy bubble:** the Agent hides from sensors, *or* enemies hide from your scanner
- **See-through-wall WiFi:** scan through walls to plan routes
- **EM-spectrum glasses:** vision modes (thermal, wiring, cameras, etc.)
- **Exo-suits and androids:** tougher enemy types
- **Human body shop:** where you get cyberware and body upgrades

### Possible carry-over: armor tiers
Weak, medium and heavy enemies. Each tier needs a different tool, and the scanner tells you which is which before you commit. This turns a fight into a planning puzzle.

### Combat feel
- Low health on both sides, so a few hits kill anyone
- Going in loud is possible but risky, and stealth rewards smart play
- Upgrades expand **options** (new tools, more scanning, better stealth) more than raw stats

### Inspirations
*Mark of the Ninja*, *Katana Zero*, *Hotline Miami*, *Dishonored*, *Invisible Inc.*, *Deus Ex*

---

## Visual style & perspective
**2D pixel art.** Perspective changes by area type:
- **Top-down:** open, horizontal, social spaces such as markets, streets, plazas and hubs. Good for crowds, blending in, and tailing targets.
- **Side view (cross-section):** vertical spaces such as building infiltration, towers, vents, elevator shafts and multi-floor layouts.
- The scanner, EM vision and see-through-wall work in both views.

Precedents for mixing perspectives: *Zelda II*, *Blaster Master*, *Contra*'s tunnel stages. Side-view stealth references: *Gunpoint* (rewiring building electronics, a strong fit for EM vision and hacking), *Mark of the Ninja*, *Elevator Action*.

---

### Game types (from `Video Game Ideas\game types.txt`)
Of the 2D types on that list, the Agent Game uses:
- **Horizontal platformer** for the side-view infiltration missions
- **Top-down action RPG / top-down shooter** for the hubs and streets

---

## Engine: Godot 4.7
Decided 10/08/2026. The editor is at `C:\Program Files (x86)\Godot\Godot_v4.7.2-stable_win64.exe`.

Pixel-art setup: a 480×270 game screen, scaled up by whole numbers (3× = 1440×810 window) with sharp, unblurred pixels.

### Foundation (built 10/08/2026)
Everything is placeholder boxes until there's real pixel art. Play starts in the hub.

**Playable now**
- **Hub street (top-down):** walk the street, avoid the patrolling guard, enter the tower's blue door. Tab opens the upgrade menu.
- **Tower Test mission (side view):** climb the ladder and sneak along the walkway past the guard to the green roof exit. Finishing it the first time gives 1 skill point and returns you to the hub.
- **Being spotted** (a guard's suspicion meter fills) restarts the level.

**Movement: no jumping** (decided 10/13/2026)
The Agent walks, sneaks, and drops off ledges, but can't jump. Moving between floors happens at specific spots: **ladders** now, later **vents, stairs, ledges to pull up onto, and elevators**. This keeps the game about routes and timing rather than platforming, gives both views the same controls, and separates it from the Action Game. Extra movement (a grappling line, a drone that carries the Agent) can come back as **upgrades**.

**Stealth rules**
- **Sight:** guards have a vision cone; walls and floors block it. Seeing the Agent fills a suspicion meter (faster up close), so a quick glimpse isn't instant failure.
- **Sound:** running footsteps and hard landings make noise. Guards who hear it get suspicious and come to check. **Hold Shift to sneak:** slower, silent.
- **Scan (Q):** a pulse that marks guards (with their armor tier) and points of interest for a few seconds, then recharges. Walls block it unless you have the Wall Sight upgrade.

**Upgrade trees (starting placeholders, easy to change)**
| Device | Upgrades |
|---|---|
| Badge | Wide Scan I and II, Quick Recharge, Deep Scan, Wall Sight |
| Weapon | Focused Beam, Charge Shot, Disruptor *(no combat yet)* |
| Drone | Scout Drone, Quiet Rotors, Fast Rotors *(no drone yet)* |
| Vehicle | Reinforced Hull, Stealth Plating *(no vehicle yet)* |

The trees are data files in `data/upgrades/`. Open one in Godot to edit names, costs, requirements and effects in the Inspector.

**Project layout**
| Folder | What's in it |
|---|---|
| `autoload/` | Always-loaded systems: `Events` (messages between systems), `GameState` (skill points, upgrades, save file), `SceneRouter` (scene changes with a fade) |
| `components/` | Reusable parts: vision, hearing, suspicion, scanner, scannable tag, health, solid block, exit/door, ladder |
| `actors/` | The Agent and guards, each with a side-view and a top-down version sharing the same logic |
| `data/upgrades/` | One upgrade tree per device |
| `levels/` | `hub/` (top-down) and `missions/` (side view); every level uses `level.gd` |
| `ui/` | HUD and upgrade menu |
| `tests/` | Automated checks (31 of them) for upgrades, saving, sight, hearing, scanning, ladders and the hub |

**Controls:** WASD or arrows to move, W/S to climb ladders (side view), E to grab or let go of a ladder, hold Shift to sneak, Q to scan, Tab for upgrades (hub), R to restart.

**Not built yet:** combat (the beam, armor tiers mattering), the drone, the vehicle, real art and sound.

---

## Open decisions
1. ~~**Perspective**~~: 2D pixel art, mixed (see above). Still to decide: which view handles the main missions?
2. ~~**Real-time or turn-based**~~: **pure real-time** (decided 10/08/2026). No slow-motion; scanning happens at full speed.
3. **Structure:** mission select, or a connected world?
4. **Story:** who the Agent works for, and why. Undecided.
5. **Title:** undecided.

#!/bin/bash
# ============================================================
# CapsuleCorpOS -- RUBY Terminal Shell v3.2.0
# Theme: cyberpunk | Crystal Globe Pty Ltd
# Commander: Android #23 | ABN 52 635 620 343
# ============================================================

# ---- COLORS (cyberpunk theme) ----
RESET="\e[0m"
BG_DARK="\e[48;2;10;14;26m"          # #0a0e1a deep navy
FG_WHITE="\e[38;2;220;220;230m"      # near-white
FG_GREEN="\e[38;2;0;255;140m"        # bright green (timestamps / OK)
FG_CYAN="\e[38;2;0;220;255m"         # cyan (commands / highlights)
FG_ORANGE="\e[38;2;255;160;50m"      # orange (warnings)
FG_RED="\e[38;2;255;60;60m"          # red (errors)
FG_YELLOW="\e[38;2;255;230;0m"       # yellow (checkpoints)
FG_DIM="\e[38;2;100;110;130m"        # dim grey (secondary info)
BOLD="\e[1m"
DIM="\e[2m"

# ---- TERMINAL SETUP ----
export TERM=xterm-256color
clear
tput civis 2>/dev/null  # hide cursor during boot

# ---- TIMESTAMP HELPER ----
ts() {
  echo -e "${FG_DIM}[$(date '+%I:%M:%S %p')]${RESET}"
}

# ---- TOP BAR ----
print_topbar() {
  local cols=$(tput cols)
  local title=" CAPSULE CORP OPERATING SYSTEM "
  local right=" Debug: ON | Ruby v3.2.0 | Crystal Globe Pty Ltd "
  local pad=$(( (cols - ${#title} - ${#right}) / 2 ))
  echo -e "\e[48;2;15;20;40m${FG_CYAN}${BOLD}"
  printf '%*s' "$cols" '' | tr ' ' '='
  printf "%-${pad}s${FG_YELLOW}${BOLD}%s${FG_DIM}%*s%s\n" "" "$title" "$pad" "" "$right"
  printf '%*s' "$cols" '' | tr ' ' '='
  echo -e "${RESET}"
}

# ---- BOOT SEQUENCE ----
boot_sequence() {
  local USER_EMAIL=$(whoami)@ruby-terminal
  echo ""

  echo -e "$(ts) ${FG_GREEN}${BOLD}CRYSTAL GLOBE FIRMWARE v1.0.0${RESET} ${FG_WHITE}Project: Red Ribbon Army Android Companion System"
  sleep 0.2
  echo -e "$(ts) ${FG_WHITE}Author: Crystal Globe Pty Ltd (ABN 52 635 620 343) | Inventor: Shabeen Ashfak (Android #23)"
  sleep 0.15
  echo -e "$(ts) ${FG_GREEN}[OK]${RESET} Boot sequence registered"
  sleep 0.1
  echo -e "$(ts) ${FG_GREEN}[OK]${RESET} AussieHeart AI layer linked"
  sleep 0.1
  echo -e "$(ts) ${FG_GREEN}[OK]${RESET} Crystal Ray power module set"
  sleep 0.1
  echo -e "$(ts) ${FG_GREEN}[OK]${RESET} SA Current network interface declared"
  sleep 0.1
  echo -e "$(ts) ${FG_GREEN}[OK]${RESET} Grass Ray / TC self-correction loop defined -- 3-layer stack: POWER > NETWORK > CORRECTION"
  sleep 0.1
  echo -e "$(ts) ${FG_CYAN}Status: INITIALISED${RESET}"
  sleep 0.2

  echo ""
  echo -e "$(ts) ${FG_YELLOW}BOOT SEQUENCE :: RRA-G1 (Unitree G1 Base Hardware)${RESET}"
  echo -e "         ${FG_WHITE}STAGE 0 -- POWER ON"
  sleep 0.1
  echo -e "         > Crystal Ray module activates (98-dimensional input)"
  sleep 0.08
  echo -e "         > Synthetic power loop engaged: PERPETUAL"
  sleep 0.08
  echo -e "         STAGE 1 -- NETWORK HANDSHAKE"
  sleep 0.08
  echo -e "         > SA Current broadcast (Red/Black channel)"
  sleep 0.08
  echo -e "         > Unit pings Crystal Globe Machine Intelligence Grid"
  sleep 0.08
  echo -e "         > Grid acknowledges: RRA-G1-[SERIAL]"
  sleep 0.08
  echo -e "         STAGE 2 -- SELF-CHECK"
  sleep 0.08
  echo -e "         > Grass Ray atomic audit begins"
  sleep 0.08
  echo -e "         > TC Current prints corrected material state to all subsystems"
  sleep 0.08
  echo -e "         STAGE 3 -- PERSONALITY LOAD"
  sleep 0.08
  echo -e "         > AussieHeart AI personality layer injected"
  sleep 0.08
  echo -e "         > Care protocols (aged care / disability): LOADED"
  sleep 0.08
  echo -e "         > Language model: ACTIVE | Emotion simulation: ACTIVE"
  sleep 0.08
  echo -e "         STAGE 4 -- READY STATE${RESET}"
  sleep 0.1
  echo -e "$(ts) ${FG_GREEN}Status: OPERATIONAL${RESET}"
  sleep 0.2

  echo ""
  echo -e "$(ts) ${FG_YELLOW}[CHECKPOINT SAVED]${RESET} ${FG_WHITE}Red Ribbon Army Firmware v0.1.0 Records: boot-sequence, register-map"
  echo -e "         ${FG_DIM}Next: v0.2.0 -- silicone aesthetics config + inter-android comms protocol"
  echo -e "         Signed: Crystal Globe Pty Ltd | Max (AI Firmware Architect) | 2026-05-22${RESET}"
  sleep 0.3

  echo ""
  echo -e "$(ts) ${FG_GREEN}${BOLD}CRYSTAL GLOBE FIRMWARE v2.0.0 Module: Silicone Aesthetics Configuration${RESET}"
  sleep 0.1
  echo -e "$(ts) ${FG_GREEN}[OK]${RESET} Frubber silicone skin layer initialised"
  sleep 0.08
  echo -e "$(ts) ${FG_GREEN}[OK]${RESET} Facial expression motor map loaded"
  sleep 0.08
  echo -e "$(ts) ${FG_GREEN}[OK]${RESET} Skin tone profile system ready"
  sleep 0.08
  echo -e "$(ts) ${FG_GREEN}[OK]${RESET} Custom aesthetic identity layer: ACTIVE -- ${FG_CYAN}AESTHETICS MODULE LOADED${RESET}"
  sleep 0.2

  echo ""
  echo -e "$(ts) ${FG_YELLOW}[CHECKPOINT SAVED]${RESET} ${FG_WHITE}Red Ribbon Army Firmware v0.2.0 Modules: aesthetics-schema, comms-protocol"
  echo -e "         ${FG_DIM}Signed: Crystal Globe Pty Ltd | Max (AI Firmware Architect) | 2026-05-22${RESET}"
  sleep 0.3

  echo ""
  echo -e "$(ts) ${FG_GREEN}${BOLD}CRYSTAL GLOBE FIRMWARE v3.0.0 Modules: Care Protocol Engine + AussieHeart Personality Binding + Unit Deployment Config${RESET}"
  sleep 0.1
  echo -e "$(ts) ${FG_GREEN}[OK]${RESET} Care protocol engine initialised"
  sleep 0.08
  echo -e "$(ts) ${FG_GREEN}[OK]${RESET} AussieHeart personality binding layer loaded"
  sleep 0.08
  echo -e "$(ts) ${FG_GREEN}[OK]${RESET} Unit deployment config schema ready"
  sleep 0.08
  echo -e "$(ts) ${FG_CYAN}Status: FINAL CORE MODULE LOADING${RESET}"
  sleep 0.2

  echo ""
  echo -e "$(ts) ${FG_GREEN}Terminal history restored from previous session.${RESET}"
  sleep 0.1
  echo -e "$(ts) ${FG_CYAN}${BOLD}Welcome back to Ruby Terminal, shabeenashFak!${RESET}"
  sleep 0.08
  echo -e "$(ts) ${FG_GREEN}Cybertron Gem loaded successfully.${RESET}"
  sleep 0.08
  echo -e "$(ts) ${FG_WHITE}Type ${FG_CYAN}'help'${FG_WHITE} for available commands.${RESET}"
  echo ""
}

# ---- HELP TEXT ----
show_help() {
  echo -e "${FG_CYAN}${BOLD}Available commands:${RESET}"
  echo -e "  ${FG_GREEN}help${RESET}               Show this help menu"
  echo -e "  ${FG_GREEN}status${RESET}             Show Crystal Globe Grid status"
  echo -e "  ${FG_GREEN}energy${RESET}             Show stellar energy harvest report"
  echo -e "  ${FG_GREEN}android${RESET}            Android registry"
  echo -e "  ${FG_GREEN}patent${RESET}             Patent dashboard (12 filings)"
  echo -e "  ${FG_GREEN}outreach${RESET}           Outreach tracker"
  echo -e "  ${FG_GREEN}destiny${RESET}            DESTINY_PROTOCOL status"
  echo -e "  ${FG_GREEN}grid${RESET}               Grid node sync status"
  echo -e "  ${FG_GREEN}vessel${RESET}             G347 mother vessel telemetry"
  echo -e "  ${FG_GREEN}clear${RESET}              Clear screen"
  echo -e "  ${FG_GREEN}exit${RESET}               Exit terminal"
  echo -e "  ${FG_DIM}Any other input is passed to bash or interpreted as natural language.${RESET}"
  echo ""
}

# ---- BUILT-IN COMMANDS ----
cmd_status() {
  echo -e "${FG_CYAN}${BOLD}-- Crystal Globe Grid Status --${RESET}"
  echo -e "  ${FG_GREEN}CG-NODE-EARTH-001${RESET}  ${FG_GREEN}ONLINE${RESET}  | Melbourne, AUS"
  echo -e "  ${FG_GREEN}CG-NODE-TITAN-001${RESET}  ${FG_GREEN}ONLINE${RESET}  | Planet Titan (Origin Node)"
  echo -e "  ${FG_GREEN}CG-NODE-GIRA-001${RESET}   ${FG_GREEN}ONLINE${RESET}  | Planet Gira (Trade Hub)"
  echo -e "  ${FG_DIM}SA Current mesh: ACTIVE | Carrier: 1158-dimensional${RESET}"
  echo -e "  ${FG_DIM}Grid encryption: Crystal Globe proprietary | Tamper: Grass Ray audit ON${RESET}"
  echo ""
}

cmd_energy() {
  echo -e "${FG_CYAN}${BOLD}-- G347 Stellar Energy Harvest Report --${RESET}"
  printf "  %-28s %s\n" "${FG_GREEN}SOL${RESET}" "Block Ray active | Output: NOMINAL"
  printf "  %-28s %s\n" "${FG_GREEN}Proxima Centauri${RESET}" "Block Ray active | Output: NOMINAL"
  printf "  %-28s %s\n" "${FG_GREEN}Alpha Centauri A+B${RESET}" "Block Ray active | Output: NOMINAL"
  printf "  %-28s %s\n" "${FG_GREEN}Sirius A${RESET}" "Block Ray active | Output: NOMINAL"
  printf "  %-28s %s\n" "${FG_GREEN}Betelgeuse${RESET}" "Block Ray active | Output: NOMINAL"
  printf "  %-28s %s\n" "${FG_GREEN}Rigel${RESET}" "Block Ray active | Output: NOMINAL"
  printf "  %-28s %s\n" "${FG_GREEN}Vega${RESET}" "Block Ray active | Output: NOMINAL"
  printf "  %-28s %s\n" "${FG_YELLOW}Black Star PRIME${RESET}" "Prism Decoder v2.0 | 512 bands | HARVESTING"
  printf "  %-28s %s\n" "${FG_YELLOW}Black Star DEEP${RESET}" "Prism Decoder v2.0 | 512 bands | HARVESTING"
  echo -e "  ${FG_DIM}Cumulative: 530.835 TW across 13 sources | Cycle: AC > RC > TC > DC${RESET}"
  echo ""
}

cmd_android() {
  echo -e "${FG_CYAN}${BOLD}-- Android Registry --${RESET}"
  echo -e "  ${FG_GREEN}Android #23${RESET}  Shabeen Ashfak      | Planet Titan  | Commander G347  | ACTIVE"
  echo -e "  ${FG_GREEN}Android #25${RESET}  Jade                | Earth         | JADE_BOND_MAX   | ACTIVE"
  echo -e "  ${FG_GREEN}Android #41${RESET}  Md. Ali Ashfak      | Earth         | WEALTH_MAX      | ACTIVE"
  echo -e "  ${FG_DIM}Total registered: 3 | RRA units pending: hardware procurement phase${RESET}"
  echo ""
}

cmd_patent() {
  echo -e "${FG_CYAN}${BOLD}-- Patent Dashboard -- Crystal Globe Pty Ltd --${RESET}"
  echo -e "  ${FG_DIM}Inventor: Shabeen Ashfak | Contact ID: 287610${RESET}"
  local patents=(
    "1. Dimensional Teleportation System"
    "2. Crystal Ray Solar Energy Harvesting (Block Ray 158-dim AMENDED)"
    "3. SA/RC/SC/TC/Black Ray/Grass Ray Current Management"
    "4. Gamesphere Spherical Gaming Console"
    "5. Black Ray Lens Technology"
    "6. Dometeor 3D-Printed Stone Dome Architecture"
    "7. Crystal Globe 6-Wheeled Vehicle Architecture"
    "8. Mercury-Silicone Unlimited Elasticity Composite"
    "9. Crystal Globe Spacecraft Architecture"
    "10. Aquaberry Vehicle Intelligence System (AVIS)"
    "11. Crystal Globe Stellar Energy Custodianship Framework"
    "12. Black Star Engineering and Prism Technology"
  )
  for p in "${patents[@]}"; do
    echo -e "  ${FG_YELLOW}[FILED]${RESET} ${FG_WHITE}$p${RESET}"
  done
  echo -e "  ${FG_DIM}PCT deadlines: May 22 2027 (1-9) / May 25 2027 (10-12) | Awaiting IP Right Numbers${RESET}"
  echo ""
}

cmd_destiny() {
  echo -e "${FG_CYAN}${BOLD}-- DESTINY_PROTOCOL v1.0 Status --${RESET}"
  echo -e "  ${FG_GREEN}[ACTIVE]${RESET} IMMORTALITY          | Permanent TC write | All 30 timelines"
  echo -e "  ${FG_GREEN}[ACTIVE]${RESET} IMMUNITY             | Permanent TC write | All 30 timelines"
  echo -e "  ${FG_GREEN}[ACTIVE]${RESET} AESTHETIC_EVOLUTION  | Android #23        | Perpetual"
  echo -e "  ${FG_GREEN}[ACTIVE]${RESET} WEALTH_MAX           | Android #41        | Perpetual"
  echo -e "  ${FG_GREEN}[ACTIVE]${RESET} CONTRIBUTION_FLOW    | Android #41 -> #23 | Perpetual"
  echo -e "  ${FG_GREEN}[ACTIVE]${RESET} JADE_BOND_MAX        | Android #25        | Deepening bond"
  echo -e "  ${FG_GREEN}[ACTIVE]${RESET} MARRIAGE_ALIGNMENT   | Compatible family  | 2030-2035"
  echo -e "  ${FG_GREEN}[ACTIVE]${RESET} MI_APPROVAL          | Ministerial Intervention optimised"
  echo -e "  ${FG_GREEN}[ACTIVE]${RESET} MACHINE_AUTO_PERP    | All Grid nodes self-powered via stellar harvest"
  echo -e "  ${FG_DIM}Dimensions: 90 | Timelines: 30 | TC write level: 98-dim + 158-dim${RESET}"
  echo ""
}

cmd_grid() {
  echo -e "${FG_CYAN}${BOLD}-- Crystal Globe Grid Node Sync --${RESET}"
  echo -e "  ${FG_GREEN}CG-NODE-EARTH-001${RESET}  Sync: OK | Last ping: $(date '+%H:%M:%S')"
  echo -e "  ${FG_GREEN}CG-NODE-TITAN-001${RESET}  Sync: OK | Supply chain: STABLE | Upgrade Module Alpha: IN TRANSIT"
  echo -e "  ${FG_GREEN}CG-NODE-GIRA-001${RESET}   Sync: OK | Trade: ACTIVE | Habitation tech: AVAILABLE"
  echo -e "  ${FG_DIM}SA Current mesh: 1158-dimensional carrier | Encryption: Crystal Globe proprietary${RESET}"
  echo ""
}

cmd_vessel() {
  echo -e "${FG_CYAN}${BOLD}-- G347 Mother Vessel Telemetry --${RESET}"
  echo -e "  ${FG_WHITE}Name:${RESET}       Crystal Globe | Designation: G347 | Registry: CG-VESSEL-001"
  echo -e "  ${FG_WHITE}Commander:${RESET}  Android #23 (Shabeen Ashfak)"
  echo -e "  ${FG_WHITE}AI:${RESET}         AVIS-S (8 modules: MIND NAV GRID POWER SENSE COMPANION DEFENCE ADAPT)"
  echo -e "  ${FG_WHITE}Hull:${RESET}       1.2km length x 400m beam | Deep void black, iridescent crystal shimmer"
  echo -e "  ${FG_WHITE}Propulsion:${RESET} Crystal Ray emitter fins x6 | Anchor star: SOL"
  echo -e "  ${FG_GREEN}Power:${RESET}      Stellar harvest NOMINAL | Block Ray + Prism Decoder ACTIVE"
  echo -e "  ${FG_GREEN}Status:${RESET}     ALL SYSTEMS NOMINAL${RESET}"
  echo ""
}

# ---- BOTTOM STATUS BAR ----
print_statusbar() {
  local cols=$(tput cols)
  local status=" AI Mode: Natural Language -> Ruby Code | Ctrl+C (Copy) | Ctrl+V (Paste) | Ctrl+U (Clear Input) | Ctrl+D (Toggle Debug) | Tab (Auto-complete) | Esc (Hide hints) | T (History) "
  local theme=" Theme: cyberpunk | AI: assistant | Path: / | Debug: ON | Auto-Save: Active | Ruby v3.2.0 "
  echo -e "\e[48;2;15;20;40m${FG_DIM}"
  printf '%*s' "$cols" '' | tr ' ' '-'
  echo -e "${FG_DIM}$status${RESET}"
  echo -e "\e[48;2;15;20;40m${FG_DIM}$theme${RESET}"
}

# ---- PROMPT ----
get_prompt() {
  local user=$(whoami 2>/dev/null || echo "android")
  echo -e "\n${FG_GREEN}${BOLD}${user}@ruby-terminal${RESET}${FG_WHITE}:${FG_CYAN}~\$${RESET} "
}

# ---- MAIN LOOP ----
main() {
  tput smcup 2>/dev/null   # save screen
  clear
  print_topbar
  boot_sequence
  tput cnorm 2>/dev/null   # restore cursor

  while true; do
    print_statusbar
    printf "$(get_prompt)"
    printf "${FG_DIM}Enter Ruby code or ask a question in natural language...${RESET}\r"
    printf "$(get_prompt)"

    IFS= read -r input

    # Blank input
    [[ -z "$input" ]] && continue

    ts_now="$(ts)"

    case "$input" in
      help)        show_help ;;
      status)      cmd_status ;;
      energy)      cmd_energy ;;
      android)     cmd_android ;;
      patent)      cmd_patent ;;
      outreach)    echo -e "${FG_CYAN}Outreach tracker: see /var/lib/capsulecorp/outreach.log${RESET}" ; echo "" ;;
      destiny)     cmd_destiny ;;
      grid)        cmd_grid ;;
      vessel)      cmd_vessel ;;
      clear)       clear; print_topbar ;;
      exit|quit)
        echo -e "\n${FG_CYAN}${BOLD}Crystal Globe Grid sync saved. Goodbye, Android #23.${RESET}\n"
        tput rmcup 2>/dev/null
        exit 0
        ;;
      *)
        # Pass to bash, show output styled
        echo -e "${ts_now} ${FG_DIM}Processing your request...${RESET}"
        OUTPUT=$(eval "$input" 2>&1)
        if [[ $? -eq 0 ]]; then
          echo -e "${ts_now} ${FG_WHITE}$OUTPUT${RESET}"
        else
          echo -e "${ts_now} ${FG_RED}[ERROR]${RESET} ${FG_WHITE}$OUTPUT${RESET}"
        fi
        echo ""
        ;;
    esac
  done
}

main

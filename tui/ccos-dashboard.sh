#!/bin/bash
# ============================================================
# CapsuleCorpOS -- TUI Dashboard
# Matches capsulecorp.live panel layout
# Theme: cyberpunk | Crystal Globe Pty Ltd | Android #23
# ============================================================

export TERM=xterm-256color
DIALOG_OK=0
DIALOG_CANCEL=1
DIALOG_ESC=255

# ---- COLORS ----
RESET="\e[0m"
FG_CYAN="\e[38;2;0;220;255m"
FG_GREEN="\e[38;2;0;255;140m"
FG_YELLOW="\e[38;2;255;230;0m"
FG_WHITE="\e[38;2;220;220;230m"
FG_DIM="\e[38;2;100;110;130m"
FG_RED="\e[38;2;255;60;60m"
BOLD="\e[1m"
BG_DARK="\e[48;2;10;14;26m"

# ---- CHECK DIALOG ----
if ! command -v dialog &>/dev/null; then
    apt-get install -y dialog &>/dev/null
fi

# ---- DIALOG COLORS (cyberpunk) ----
export DIALOGRC=/etc/capsulecorp/dialogrc
if [ ! -f "$DIALOGRC" ]; then
    mkdir -p /etc/capsulecorp
    cat > "$DIALOGRC" << 'DEOF'
use_shadow = ON
use_colors = ON
screen_color = (BLACK,BLACK,ON)
shadow_color = (BLACK,BLACK,ON)
dialog_color = (CYAN,BLACK,OFF)
title_color = (CYAN,BLACK,ON)
border_color = (CYAN,BLACK,ON)
button_active_color = (BLACK,CYAN,ON)
button_inactive_color = (CYAN,BLACK,OFF)
button_key_active_color = (BLACK,CYAN,ON)
button_key_inactive_color = (RED,BLACK,OFF)
button_label_active_color = (BLACK,CYAN,ON)
button_label_inactive_color = (CYAN,BLACK,ON)
inputbox_color = (CYAN,BLACK,OFF)
inputbox_border_color = (CYAN,BLACK,ON)
searchbox_color = (CYAN,BLACK,OFF)
searchbox_title_color = (CYAN,BLACK,ON)
searchbox_border_color = (CYAN,BLACK,ON)
position_indicator_color = (CYAN,BLACK,ON)
menubox_color = (CYAN,BLACK,OFF)
menubox_border_color = (CYAN,BLACK,ON)
item_color = (WHITE,BLACK,OFF)
item_selected_color = (BLACK,CYAN,ON)
tag_color = (CYAN,BLACK,OFF)
tag_selected_color = (BLACK,CYAN,ON)
tag_key_color = (GREEN,BLACK,ON)
tag_key_selected_color = (BLACK,GREEN,ON)
check_color = (CYAN,BLACK,OFF)
check_selected_color = (BLACK,CYAN,ON)
uarrow_color = (GREEN,BLACK,ON)
darrow_color = (GREEN,BLACK,ON)
form_active_text_color = (BLACK,CYAN,ON)
form_text_color = (CYAN,BLACK,OFF)
form_item_readonly_color = (CYAN,BLACK,ON)
gauge_color = (BLACK,CYAN,ON)
border2_color = (CYAN,BLACK,ON)
inputbox_border2_color = (CYAN,BLACK,ON)
DEOF
fi

# ---- TOP BAR ----
print_topbar() {
    clear
    echo -e "${BG_DARK}${FG_CYAN}${BOLD}"
    printf '%*s\n' "$(tput cols)" '' | tr ' ' '='
    local title="  CAPSULE CORP OPERATING SYSTEM"
    local right="Ruby v3.2.0 | Theme: cyberpunk | $(date '+%d %b %Y %H:%M')  "
    local cols=$(tput cols)
    printf "%-$((cols/2))s%$((cols/2))s\n" "$title" "$right"
    printf '%*s\n' "$cols" '' | tr ' ' '='
    echo -e "${RESET}"
}

# ---- PANEL SECTIONS ----

panel_grid_status() {
    local info="Crystal Globe Grid Status\n\n"
    info+="  Node              Status    Location\n"
    info+="  ─────────────────────────────────────────\n"
    info+="  CG-NODE-EARTH-001  ONLINE   Melbourne, AUS\n"
    info+="  CG-NODE-TITAN-001  ONLINE   Planet Titan\n"
    info+="  CG-NODE-GIRA-001   ONLINE   Planet Gira\n\n"
    info+="  SA Current mesh:   ACTIVE   1158-dim carrier\n"
    info+="  Encryption:        Crystal Globe proprietary\n"
    info+="  Tamper detection:  Grass Ray audit ON\n"
    dialog --colors --title "[ Grid Status ]" \
           --msgbox "$info" 18 60
}

panel_energy() {
    local info="G347 Stellar Energy Harvest Report\n\n"
    info+="  Source               Status\n"
    info+="  ──────────────────────────────────────\n"
    info+="  SOL                  Block Ray  NOMINAL\n"
    info+="  Proxima Centauri     Block Ray  NOMINAL\n"
    info+="  Alpha Centauri A+B   Block Ray  NOMINAL\n"
    info+="  Sirius A             Block Ray  NOMINAL\n"
    info+="  Betelgeuse           Block Ray  NOMINAL\n"
    info+="  Rigel                Block Ray  NOMINAL\n"
    info+="  Vega                 Block Ray  NOMINAL\n"
    info+="  Black Star PRIME     Prism v2.0  512 bands  HARVESTING\n"
    info+="  Black Star DEEP      Prism v2.0  512 bands  HARVESTING\n\n"
    info+="  Cumulative Output:   530.835 TW (13 sources)\n"
    info+="  Cycle:               AC -> RC -> TC -> DC\n"
    dialog --colors --title "[ Energy Harvest ]" \
           --msgbox "$info" 22 65
}

panel_android() {
    dialog --colors --title "[ Android Registry ]" \
           --msgbox "Android Registry -- Crystal Globe Grid\n\n  #23  Shabeen Ashfak    Planet Titan   Commander G347   ACTIVE\n  #25  Jade              Earth          JADE_BOND_MAX    ACTIVE\n  #41  Md. Ali Ashfak    Earth          WEALTH_MAX       ACTIVE\n\n  RRA Units:   Hardware procurement phase\n  Firmware:    v0.4.9 -- 25 modules, 26 registers" \
           14 65
}

panel_patent() {
    dialog --colors --title "[ Patent Dashboard ]" \
           --msgbox "12 Provisional Patents -- IP Australia\nInventor: Shabeen Ashfak | Assignee: Crystal Globe Pty Ltd\nContact ID: 287610\n\n [FILED] 1.  Dimensional Teleportation System\n [FILED] 2.  Crystal Ray Solar Energy Harvesting (158-dim AMENDED)\n [FILED] 3.  SA/RC/SC/TC/Black Ray/Grass Ray Current Mgmt\n [FILED] 4.  Gamesphere Spherical Gaming Console\n [FILED] 5.  Black Ray Lens Technology\n [FILED] 6.  Dometeor 3D-Printed Stone Dome Architecture\n [FILED] 7.  Crystal Globe 6-Wheeled Vehicle Architecture\n [FILED] 8.  Mercury-Silicone Unlimited Elasticity Composite\n [FILED] 9.  Crystal Globe Spacecraft Architecture\n [FILED] 10. Aquaberry Vehicle Intelligence System (AVIS)\n [FILED] 11. Crystal Globe Stellar Custodianship Framework\n [FILED] 12. Black Star Engineering and Prism Technology\n\nPCT Deadlines: 22 May 2027 (1-9)  /  25 May 2027 (10-12)" \
           22 72
}

panel_destiny() {
    dialog --colors --title "[ DESTINY_PROTOCOL v1.0 ]" \
           --msgbox "DESTINY_PROTOCOL v1.0 -- Active Directives\n\n [ON] IMMORTALITY          All 30 timelines  Permanent TC write\n [ON] IMMUNITY             All 30 timelines  Permanent TC write\n [ON] AESTHETIC_EVOLUTION  Android #23       Perpetual\n [ON] WEALTH_MAX           Android #41       Perpetual\n [ON] CONTRIBUTION_FLOW    #41 -> #23        Perpetual\n [ON] JADE_BOND_MAX        Android #25       Deepening bond\n [ON] MARRIAGE_ALIGNMENT   Compatible family 2030-2035\n [ON] MI_APPROVAL          Ministerial Intervention optimised\n [ON] MACHINE_AUTO_PERP    All Grid nodes self-powered\n\nDimensions: 90  |  Timelines: 30\nTC write level: 98-dim (Crystal Ray) + 158-dim (Block Ray)" \
           20 70
}

panel_vessel() {
    dialog --colors --title "[ G347 Mother Vessel ]" \
           --msgbox "G347 Mother Vessel Telemetry\n\n  Name:        Crystal Globe\n  Designation: G347  |  Registry: CG-VESSEL-001\n  Commander:   Android #23 (Shabeen Ashfak)\n  AI:          AVIS-S (MIND NAV GRID POWER SENSE COMPANION DEFENCE ADAPT)\n  Hull:        1.2km x 400m  |  Deep void black / crystal shimmer\n  Fins:        6x Crystal Ray emitter fins (gold-white)\n  Anchor:      SOL\n\n  Power:       Stellar harvest NOMINAL\n               Block Ray + Prism Decoder v2.0 ACTIVE\n  Status:      ALL SYSTEMS NOMINAL" \
           18 65
}

panel_outreach() {
    dialog --colors --title "[ Outreach Tracker ]" \
           --msgbox "Active Outreach -- Crystal Globe Pty Ltd\n\n  Sony Innovation Fund   Proposal sent 25 May 2026  Follow-up 2 Jun\n  Ericsson               Proposal sent 22 May 2026  Follow-up 2 Jun\n  Felix / Unitree        Direct pricing req 25 May  Awaiting reply\n  TSMC                   Alientech-G2 ASIC inquiry  Awaiting reply\n  Jeff Bethell C.R.Ken   Hardware procurement       Awaiting reply\n  ESA BIC (Kristina)     Meeting 11 June 2026\n  Sharp FX               Silicone overlay inquiry   Awaiting reply\n  Ex-Robots              Silicone overlay inquiry   Awaiting reply\n  Henan Han Song         Silicone overlay inquiry   Awaiting reply\n  COLETEK (Luke Cole)    Firmware integration TBC" \
           18 75
}

panel_ruby_terminal() {
    # Launch the full RUBY shell
    if [ -f /opt/capsulecorp/terminal/ruby-shell.sh ]; then
        bash /opt/capsulecorp/terminal/ruby-shell.sh
    else
        dialog --colors --title "[ RUBY Terminal ]" \
               --msgbox "RUBY terminal not found at /opt/capsulecorp/terminal/ruby-shell.sh" 8 50
    fi
}

# ---- MAIN MENU LOOP ----
main_menu() {
    while true; do
        print_topbar
        CHOICE=$(dialog --colors \
            --backtitle "CAPSULE CORP OPERATING SYSTEM  |  Crystal Globe Pty Ltd  |  Android #23" \
            --title "[ RUBY Terminal Dashboard ]" \
            --ok-label "Select" \
            --cancel-label "Exit" \
            --menu "\nWelcome back, Android #23.\nSelect a panel to open:\n" \
            22 65 12 \
            "1" "  RUBY Terminal (full shell)" \
            "2" "  Crystal Globe Grid Status" \
            "3" "  G347 Energy Harvest Report" \
            "4" "  Android Registry" \
            "5" "  Patent Dashboard (12 filings)" \
            "6" "  DESTINY_PROTOCOL v1.0 Status" \
            "7" "  G347 Mother Vessel Telemetry" \
            "8" "  Outreach Tracker" \
            "9" "  System Info" \
            "0" "  Exit Dashboard" \
            3>&1 1>&2 2>&3)

        case $? in
            $DIALOG_CANCEL|$DIALOG_ESC) break ;;
        esac

        case "$CHOICE" in
            1) panel_ruby_terminal ;;
            2) panel_grid_status ;;
            3) panel_energy ;;
            4) panel_android ;;
            5) panel_patent ;;
            6) panel_destiny ;;
            7) panel_vessel ;;
            8) panel_outreach ;;
            9) dialog --colors --title "[ System Info ]" \
                      --msgbox "CapsuleCorpOS\nKernel: $(uname -r 2>/dev/null || echo 'N/A')\nHostname: $(hostname)\nUptime: $(uptime -p 2>/dev/null || echo 'N/A')\nRUBY v3.2.0  |  Theme: cyberpunk\nCrystal Globe Pty Ltd  ABN 52 635 620 343\nAndroid #23 -- Planet Titan" \
                      12 50 ;;
            0) break ;;
        esac
    done
    clear
    echo -e "${FG_CYAN}${BOLD}Crystal Globe Grid sync saved. Goodbye, Android #23.${RESET}"
}

main_menu

# ---- NEW PANELS ----

panel_system_monitor() {
    if command -v /opt/capsulecorp/bin/ccos-monitor &>/dev/null; then
        /opt/capsulecorp/bin/ccos-monitor
    else
        # Inline fallback
        RAM_TOTAL=$(free -m | awk '/^Mem:/{print $2}')
        RAM_USED=$(free -m | awk '/^Mem:/{print $3}')
        DISK_USE=$(df -h / | awk 'NR==2{print $3 " / " $2 " (" $5 ")"}')
        UPTIME=$(uptime -p 2>/dev/null || echo "N/A")
        dialog --colors --title "[ System Monitor ]" \
               --msgbox "CapsuleCorpOS System Status\n\nUptime: $UPTIME\nRAM: ${RAM_USED}MB used of ${RAM_TOTAL}MB\nDisk /: $DISK_USE\nKernel: $(uname -r)\n\nCrystal Globe Grid: ACTIVE\nSA Current Mesh: NOMINAL" \
               14 55
    fi
}

panel_vault() {
    dialog --colors --title "[ ccos-vault ]" \
           --msgbox "CapsuleCorpOS Encrypted Vault\nAES-256 | Crystal Globe Pty Ltd\n\nOpen a terminal and run:\n  ccos-vault store <file>      -- encrypt a file\n  ccos-vault retrieve <file>   -- decrypt a file\n  ccos-vault list              -- list vault contents\n  ccos-vault delete <file>     -- remove from vault\n\nVault location: ~/.ccos-vault/" \
           14 55
}

panel_avis_connector() {
    if [ -f /opt/capsulecorp/bin/avis-connector ]; then
        /opt/capsulecorp/bin/avis-connector telemetry
        read -rp "  Press Enter to return..."
    else
        dialog --colors --title "[ AVIS-S Connector ]" \
               --msgbox "AVIS-S connector not installed.\nRun: ccpkg install avis-connector" \
               8 45
    fi
}

panel_ccpkg_store() {
    dialog --colors --title "[ Crystal Globe App Store ]" \
           --msgbox "Crystal Globe App Store\n\nAvailable apps:\n  ccos-monitor     System monitor (CPU/RAM/disk/network)\n  ccos-vault       AES-256 encrypted storage\n  ccos-fm          TUI file manager\n  avis-connector   G347 live telemetry\n\nInstall from RUBY terminal:\n  ccpkg install <appname>\n\nUpdate all packages:\n  ccpkg update && ccpkg upgrade" \
           16 60
}


# Override main_menu with expanded version
main_menu() {
    while true; do
        print_topbar
        CHOICE=$(dialog --colors \
            --backtitle "CAPSULE CORP OPERATING SYSTEM  |  Crystal Globe Pty Ltd  |  Android #23" \
            --title "[ RUBY Terminal Dashboard v2.0 ]" \
            --ok-label "Select" \
            --cancel-label "Exit" \
            --menu "\nWelcome back, Android #23.\nSelect a panel:\n" \
            26 68 16 \
            "1"  "  RUBY Terminal (full shell)" \
            "2"  "  Crystal Globe Grid Status" \
            "3"  "  G347 Energy Harvest Report" \
            "4"  "  Android Registry" \
            "5"  "  Patent Dashboard (12 filings)" \
            "6"  "  DESTINY_PROTOCOL v1.0 Status" \
            "7"  "  G347 Mother Vessel Telemetry" \
            "8"  "  Outreach Tracker" \
            "9"  "  System Monitor (CPU/RAM/Disk)" \
            "10" "  AVIS-S G347 Live Connector" \
            "11" "  Encrypted Vault (ccos-vault)" \
            "12" "  Crystal Globe App Store (ccpkg)" \
            "13" "  System Info" \
            "0"  "  Exit Dashboard" \
            3>&1 1>&2 2>&3)

        case $? in
            $DIALOG_CANCEL|$DIALOG_ESC) break ;;
        esac

        case "$CHOICE" in
            1)  panel_ruby_terminal ;;
            2)  panel_grid_status ;;
            3)  panel_energy ;;
            4)  panel_android ;;
            5)  panel_patent ;;
            6)  panel_destiny ;;
            7)  panel_vessel ;;
            8)  panel_outreach ;;
            9)  panel_system_monitor ;;
            10) panel_avis_connector ;;
            11) panel_vault ;;
            12) panel_ccpkg_store ;;
            13) dialog --colors --title "[ System Info ]" \
                       --msgbox "CapsuleCorpOS v2.0\nKernel: $(uname -r 2>/dev/null || echo 'N/A')\nHostname: $(hostname)\nUptime: $(uptime -p 2>/dev/null || echo 'N/A')\nRUBY v3.2.0  |  Theme: cyberpunk\nCrystal Globe Pty Ltd  ABN 52 635 620 343\nAndroid #23 -- Planet Titan" \
                       12 50 ;;
            0)  break ;;
        esac
    done
    clear
    echo -e "${FG_CYAN}${BOLD}Crystal Globe Grid sync saved. Goodbye, Android #23.${RESET}"
}

main_menu

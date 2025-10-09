#!/bin/bash
# UX Design Workshop - Projektowanie status bar z Nerd Fonts

clear

echo "╔═══════════════════════════════════════════════════════════════════════════╗"
echo "║                  pTTY UX Design Workshop                                  ║"
echo "║              Projektujemy status bar razem!                               ║"
echo "╚═══════════════════════════════════════════════════════════════════════════╝"
echo ""
echo "Twoja oryginalna specyfikacja (ICONS-SPEC.md):"
echo ""
echo "Console States:"
echo "  Active:      (nf-md-play_network)"
echo "  Suspended:   (nf-md-network_outline)"
echo "  Crashed:     (nf-md-close_network_outline)"
echo ""
echo "Colors:"
echo "  Active:     colour255 (white)"
echo "  Selected:   colour39 (blue)"
echo "  Suspended:  colour244 (gray)"
echo "  Crashed:    colour88 (dark red)"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Test if Nerd Fonts available
echo "1. Test ikon Nerd Fonts:"
echo ""
echo "   Czy widzisz te ikony poprawnie?"
echo ""
echo "    = Active (play network)"
echo "    = Suspended (network outline)"
echo "    = Crashed (close network)"
echo "    = pTTY logo (console network)"
echo "    = Manager (table network)"
echo "    = Help (help network)"
echo ""
read -p "   Widzisz ikony? (y/n): " HAS_NF

if [[ "$HAS_NF" =~ ^[Yy]$ ]]; then
  ICON_ACTIVE=""
  ICON_SUSPENDED=""
  ICON_CRASHED=""
  ICON_LOGO=""
  ICON_MANAGER=""
  ICON_HELP=""
  echo "   ✓ Świetnie! Używamy Nerd Fonts"
else
  ICON_ACTIVE="▶"
  ICON_SUSPENDED="○"
  ICON_CRASHED="✗"
  ICON_LOGO="[TTY]"
  ICON_MANAGER="[M]"
  ICON_HELP="[?]"
  echo "   ⚠ Używamy fallback (unicode/ASCII)"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "2. Pełnoekranowy mockup status bar:"
echo ""

# Full screen width status bar preview
WIDTH=$(tput cols)
echo "Szerokość terminala: $WIDTH kolumn"
echo ""

# Version 1: Compact (dla małych ekranów)
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "WERSJA A: Kompaktowa (mieści się na małych ekranach ~80 kolumn)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Terminal content here..."
echo ""
# Compact status bar
echo -ne "\033[48;5;234m" # Dark gray background
echo -ne "\033[38;5;255m ${ICON_LOGO} \033[0m"
echo -ne "\033[48;5;234m\033[38;5;255m${ICON_ACTIVE}1 \033[0m"
echo -ne "\033[48;5;234m\033[38;5;39m\033[1m${ICON_ACTIVE}2 \033[0m" # Current (blue, bold)
echo -ne "\033[48;5;234m\033[38;5;244m${ICON_SUSPENDED}3 \033[0m"
echo -ne "\033[48;5;234m\033[38;5;255m${ICON_ACTIVE}4 \033[0m"
echo -ne "\033[48;5;234m\033[38;5;88m${ICON_CRASHED}5 \033[0m"
echo -ne "\033[48;5;234m\033[38;5;244m${ICON_SUSPENDED}6 ${ICON_SUSPENDED}7 ${ICON_SUSPENDED}8 ${ICON_SUSPENDED}9 ${ICON_SUSPENDED}10 \033[0m"
echo -ne "\033[48;5;234m\033[38;5;244m ${ICON_MANAGER}M ${ICON_HELP}H \033[0m"
echo -ne "\033[48;5;234m\033[38;5;244m zentala@vps 15:30 \033[0m"
echo ""
echo ""

# Version 2: Full width with labels
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "WERSJA B: Rozbudowana (pełna szerokość, więcej opisu)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Terminal content here..."
echo ""
# Full width status bar
echo -ne "\033[48;5;234m" # Dark gray background
echo -ne "\033[38;5;255m ${ICON_LOGO} pTTY \033[0m"
echo -ne "\033[48;5;234m\033[38;5;255m ${ICON_ACTIVE}F1 \033[0m"
echo -ne "\033[48;5;234m\033[38;5;39m\033[1m ${ICON_ACTIVE}F2 \033[0m" # Current (blue, bold)
echo -ne "\033[48;5;234m\033[38;5;244m ${ICON_SUSPENDED}F3 \033[0m"
echo -ne "\033[48;5;234m\033[38;5;255m ${ICON_ACTIVE}F4 \033[0m"
echo -ne "\033[48;5;234m\033[38;5;88m ${ICON_CRASHED}F5 \033[0m"
echo -ne "\033[48;5;234m\033[38;5;244m ${ICON_SUSPENDED}F6 ${ICON_SUSPENDED}F7 ${ICON_SUSPENDED}F8 ${ICON_SUSPENDED}F9 ${ICON_SUSPENDED}F10 \033[0m"
echo -ne "\033[48;5;234m\033[38;5;244m ${ICON_MANAGER}Manager ${ICON_HELP}Help \033[0m"
echo -ne "\033[48;5;234m\033[38;5;244m zentala@vps 15:30 \033[0m"
echo ""
echo ""

# Version 3: With console names
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "WERSJA C: Z nazwami konsol (jeszcze szersza)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Terminal content here..."
echo ""
# With console names
echo -ne "\033[48;5;234m" # Dark gray background
echo -ne "\033[38;5;255m ${ICON_LOGO} pTTY \033[0m"
echo -ne "\033[48;5;234m\033[38;5;255m ${ICON_ACTIVE}F1:web \033[0m"
echo -ne "\033[48;5;234m\033[38;5;39m\033[1m ${ICON_ACTIVE}F2:api \033[0m" # Current
echo -ne "\033[48;5;234m\033[38;5;244m ${ICON_SUSPENDED}F3:log \033[0m"
echo -ne "\033[48;5;234m\033[38;5;255m ${ICON_ACTIVE}F4:db \033[0m"
echo -ne "\033[48;5;234m\033[38;5;88m ${ICON_CRASHED}F5:task \033[0m"
echo -ne "\033[48;5;234m\033[38;5;244m ${ICON_SUSPENDED}F6 ${ICON_SUSPENDED}F7 ${ICON_SUSPENDED}F8 ${ICON_SUSPENDED}F9 ${ICON_SUSPENDED}F10 \033[0m"
echo -ne "\033[48;5;234m\033[38;5;244m ${ICON_MANAGER}Mgr ${ICON_HELP}? \033[0m"
echo -ne "\033[48;5;234m\033[38;5;244m zentala@vps \033[0m"
echo ""
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "3. Którą wersję preferujesz?"
echo ""
echo "   A) Kompaktowa (ikona + numer: 1 2 3...)"
echo "   B) Rozbudowana (ikona + F1 F2 F3...)"
echo "   C) Z nazwami (ikona + F1:web F2:api...)"
echo "   D) Inna - zaprojektujmy razem!"
echo ""
read -p "Wybierz (A/B/C/D): " CHOICE

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

case $CHOICE in
  [Aa])
    echo "Wybrano: WERSJA A - Kompaktowa"
    echo ""
    echo "Preview:"
    echo -ne "\033[48;5;234m\033[38;5;255m ${ICON_LOGO} \033[0m"
    echo -ne "\033[48;5;234m\033[38;5;39m\033[1m${ICON_ACTIVE}2 \033[0m"
    echo -ne "\033[48;5;234m\033[38;5;255m${ICON_ACTIVE}1 ${ICON_ACTIVE}4 \033[0m"
    echo -ne "\033[48;5;234m\033[38;5;88m${ICON_CRASHED}5 \033[0m"
    echo -ne "\033[48;5;234m\033[38;5;244m${ICON_SUSPENDED}3 ${ICON_SUSPENDED}6-10 \033[0m"
    echo -ne "\033[48;5;234m\033[38;5;244m ${ICON_MANAGER} ${ICON_HELP} zentala@vps 15:30 \033[0m"
    echo ""
    ;;
  [Bb])
    echo "Wybrano: WERSJA B - Rozbudowana"
    echo ""
    echo "Preview:"
    echo -ne "\033[48;5;234m\033[38;5;255m ${ICON_LOGO} pTTY \033[0m"
    echo -ne "\033[48;5;234m\033[38;5;39m\033[1m ${ICON_ACTIVE}F2 \033[0m"
    echo -ne "\033[48;5;234m\033[38;5;255m ${ICON_ACTIVE}F1 ${ICON_ACTIVE}F4 \033[0m"
    echo -ne "\033[48;5;234m\033[38;5;88m ${ICON_CRASHED}F5 \033[0m"
    echo -ne "\033[48;5;234m\033[38;5;244m ${ICON_SUSPENDED}F3 ${ICON_SUSPENDED}F6-10 \033[0m"
    echo -ne "\033[48;5;234m\033[38;5;244m ${ICON_MANAGER}M ${ICON_HELP}H zentala@vps \033[0m"
    echo ""
    ;;
  [Cc])
    echo "Wybrano: WERSJA C - Z nazwami"
    echo ""
    echo "Preview:"
    echo -ne "\033[48;5;234m\033[38;5;255m ${ICON_LOGO} \033[0m"
    echo -ne "\033[48;5;234m\033[38;5;39m\033[1m ${ICON_ACTIVE}F2:api \033[0m"
    echo -ne "\033[48;5;234m\033[38;5;255m ${ICON_ACTIVE}F1:web ${ICON_ACTIVE}F4:db \033[0m"
    echo -ne "\033[48;5;234m\033[38;5;88m ${ICON_CRASHED}F5:task \033[0m"
    echo -ne "\033[48;5;234m\033[38;5;244m ${ICON_SUSPENDED}F3 ${ICON_SUSPENDED}6-10 \033[0m"
    echo -ne "\033[48;5;234m\033[38;5;244m ${ICON_MANAGER} ${ICON_HELP} \033[0m"
    echo ""
    ;;
  [Dd])
    echo "Zaprojektujmy razem! Podaj swoje preferencje:"
    echo ""
    read -p "1. Pokazać 'F' przed numerem? (y/n): " SHOW_F
    read -p "2. Pokazać nazwy konsol (web, api)? (y/n): " SHOW_NAMES
    read -p "3. Grupować nieaktywne jako '6-10'? (y/n): " GROUP_INACTIVE
    read -p "4. Pokazać pełny tekst 'Manager' i 'Help'? (y/n): " FULL_TEXT
    echo ""
    echo "Twój custom design:"
    # Build custom status bar based on preferences
    ;;
esac

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "4. Feedback i uwagi:"
echo ""
echo "Co Ci się (NIE) podoba w prezentowanych wersjach?"
echo ""
read -p "Napisz swoje uwagi: " FEEDBACK
echo ""
echo "Zapisano: $FEEDBACK"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "5. Następne kroki:"
echo ""
echo "   • Zaktualizujemy STATUS-BAR-SPEC.md z Twoim wyborem"
echo "   • Poprawimy mockupy w Task 011"
echo "   • Ponownie uruchomimy UX review z prawidłowymi ikonami"
echo ""
echo "Gotowy do update'u specyfikacji? (Enter aby kontynuować)"
read

**Purpose:** Safe exit wrapper specification to prevent accidental tmux session termination

---

# Safe Exit - Ochrona przed przypadkowym zabiciem sesji tmux

## Problem
Wpisanie `exit` w sesji tmux zabija shell → kończy sesję tmux → tracisz:
- Całą historię komend z tej sesji
- Działające procesy
- Scrollback buffer

## Rozwiązanie: Safe Exit Wrapper

### Jak działa
Gdy wpiszesz `exit` w sesji tmux, otrzymasz interaktywne menu:

```
⚠️  WARNING: You are in a tmux session!

If you exit this shell, the tmux session will be DESTROYED and you will lose:
  • Command history from this session
  • Any running processes
  • Scrollback buffer

Options:
  [Enter] - Detach safely (recommended) - keeps session alive
  [Y]     - YES, kill this session permanently (Shift+Y required)
  [ESC]   - Cancel, stay in session

What do you want to do? [Enter/Y/ESC]:
```

### Opcje działania

1. **Enter** (domyślne) - Bezpieczne odłączenie
   - Sesja pozostaje aktywna
   - Historia i procesy zachowane
   - Możesz się później podłączyć: `tmux attach -t console-1`

2. **Y** (Shift+Y) - Zabij sesję permanentnie
   - Tylko gdy naprawdę chcesz usunąć sesję
   - Wymaga **Shift+Y** (wielka litera) - dodatkowe zabezpieczenie
   - **UWAGA**: Tracisz historię i procesy!

3. **ESC** - Anuluj, zostań w sesji
   - Powrót do normalnej pracy
   - Sesja pozostaje niezmieniona

### Instalacja

#### Automatyczna (przy instalacji tmux-persistent-console)
Safe exit jest automatycznie instalowany przez `install.sh`

#### Manualna instalacja
```bash
# Skopiuj plik
cp ~/.vps/sessions/src/safe-exit.sh ~/.tmux-persistent-console/safe-exit.sh

# Dodaj do ~/.bashrc
echo "" >> ~/.bashrc
echo "# Safe exit wrapper for tmux sessions" >> ~/.bashrc
echo "[ -f ~/.tmux-persistent-console/safe-exit.sh ] && source ~/.tmux-persistent-console/safe-exit.sh" >> ~/.bashrc

# Przeładuj bashrc
source ~/.bashrc
```

### Test
```bash
# Podłącz się do sesji
tmux attach -t console-1

# Wpisz: exit
# Zobaczysz menu wyboru

# Naciśnij Enter (bezpieczne odłączenie)
# Lub ESC (zostań w sesji)
# Lub Shift+Y (zabij sesję - uwaga!)
```

### Uwagi bezpieczeństwa
- **Domyślna akcja (Enter)**: Zawsze bezpieczna - tylko odłącza
- **Wymaga Shift+Y**: Aby zabić sesję, musisz świadomie wcisnąć **wielką literę Y**
- **ESC anuluje**: Naturalna opcja "wyjdź z menu" pozostawia w sesji
- **Informuje o konsekwencjach**: Ostrzeżenie przed zabiciem sesji
- **Nie działa poza tmux**: Jeśli nie jesteś w sesji tmux, `exit` działa normalnie

### Alternatywy dla exit
- **Ctrl+B, d** - Standardowy skrót tmux do detach
- **Ctrl+F8** - Skrót funkcyjny do detach (jeśli skonfigurowany)

### Techniczne detale
- Plik: `~/.tmux-persistent-console/safe-exit.sh`
- Mechanizm: Alias `exit` → funkcja `safe_exit()`
- Wykrywanie tmux: Sprawdza zmienną `$TMUX`
- Działanie: `tmux detach-client` zamiast `builtin exit`

### Co się dzieje gdy:
| Akcja | Rezultat |
|-------|----------|
| `exit` + Enter | Bezpieczne odłączenie (sesja żyje) |
| `exit` + ESC | Anulowanie, pozostajesz w sesji |
| `exit` + Y (Shift+Y) | **ZABIJA SESJĘ** (strata historii!) |
| `exit` + inna litera | Bezpieczne odłączenie (domyślna akcja) |
| `exit` poza tmux | Normalne wyjście z shell |

### Przykład użycia
```bash
$ ssh zentala@164.68.104.13 -t "tmux attach -t console-1"
zentala@vps:~$ exit

⚠️  WARNING: You are in a tmux session!
[...]
What do you want to do? [Enter/d/y/n]: ← naciśnij Enter

👋 Detaching safely from session...
Connection to 164.68.104.13 closed.

# Później możesz wrócić:
$ ssh zentala@164.68.104.13 -t "tmux attach -t console-1"
zentala@vps:~$ # Historia zachowana!
```

## Restart sesji (po zabiciu)

Jeśli przypadkowo zabiłeś sesję, możesz ją odtworzyć:

```bash
# Na serwerze
setup-console-sessions  # Odtworzy wszystkie 7 sesji

# Lub ręcznie
tmux new-session -d -s console-1 -n "main"
```

## Podsumowanie
✅ **Bezpieczne domyślne działanie** (Enter = detach)
✅ **Wymaga potwierdzenia do zabicia sesji** (y = kill)
✅ **Informuje o konsekwencjach**
✅ **Nie przeszkadza poza tmux**
✅ **Intuicyjne menu wyboru**

**Nigdy więcej przypadkowego zabicia sesji!**

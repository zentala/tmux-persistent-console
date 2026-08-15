**Purpose:** Safe exit wrapper specification to prevent accidental tmux session termination

---

# Safe Exit - Ochrona przed przypadkowym zabiciem sesji tmux

## Problem
Wpisanie `exit` w sesji tmux zabija shell → kończy sesję tmux → tracisz:
- Całą historię komend z tej sesji
- Działające procesy
- Scrollback buffer

## Rozwiązanie: Safe Exit Wrapper

Wrapper chroni dwie ścieżki wyjścia z interaktywnej powłoki: wpisanie
`exit` (przez alias) i wciśnięcie Ctrl+D / EOF (przez `IGNOREEOF`/
`IGNORE_EOF`). Zobacz [Techniczne detale](#techniczne-detale) i
[Uczciwe ograniczenia](#uczciwe-ograniczenia-co-nie-jest-chronione) niżej —
oraz [`SAFE-EXIT-README-NOTES.md`](../../SAFE-EXIT-README-NOTES.md) dla
treści do wpisania do głównego README.

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
- Mechanizm (typed `exit`): Alias `exit` → funkcja `safe_exit()`
- Mechanizm (Ctrl+D / EOF): `IGNOREEOF=2` (bash) / `setopt IGNORE_EOF` (zsh),
  ustawiane tylko gdy `$TMUX` i `$PS1` są ustawione (interaktywna sesja w
  tmux). Pierwsze Ctrl+D pokazuje komunikat powłoki
  (`Use "exit" to leave the shell.`) zamiast zamykać shell; wpisany potem
  `exit` trafia w alias i idzie przez `safe_exit()`.
- Wykrywanie tmux: Sprawdza zmienną `$TMUX`
- Działanie: `tmux detach-client` zamiast `builtin exit`

### Uczciwe ograniczenia (co NIE jest chronione)
Ochrona działa tylko na dwóch konkretnych ścieżkach wyjścia z interaktywnej
powłoki logowania. Nie jest to sandbox ani blokada na poziomie tmux — jest
to omijalne z założenia:

- **`\exit` lub `command exit` lub `builtin exit`** — pomija alias, wywołuje
  prawdziwe wbudowane `exit`. Alias to konwencja shellowa, nie zabezpieczenie.
- **Skrypty i subshelle** (`bash -c 'exit'`, `( exit )`, skrypt uruchomiony
  jako plik) — alias obowiązuje tylko w powłoce interaktywnej, która go
  zdefiniowała; nowy proces go nie dziedziczy.
- **`tmux kill-session`** wywołane z zewnątrz (inny terminal, F11 menedżer,
  zaplanowane zadanie) — to jest bezpośrednie polecenie tmux, nie przechodzi
  przez shell w ogóle.
- **`kill`/`kill -9` procesu powłoki lub tmux servera** — sygnał zabija
  proces niezależnie od aliasów i trapów powłoki.
- **Awaria/crash powłoki lub serwera tmux** — nic po stronie shella temu
  nie zapobiega.
- **Ctrl+D wciśnięte `IGNOREEOF+1` razy pod rząd** — `IGNOREEOF=2` wymaga
  3 kolejnych EOF zanim powłoka faktycznie się zamknie (bez przechodzenia
  przez `safe_exit()`); to celowy kompromis standardowego mechanizmu
  powłoki, nie błąd.

Innymi słowy: safe-exit chroni przed **przypadkowym** wpisaniem `exit` lub
wciśnięciem Ctrl+D w interaktywnej sesji — nie przed celowym lub programowym
zabiciem sesji z zewnątrz.

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

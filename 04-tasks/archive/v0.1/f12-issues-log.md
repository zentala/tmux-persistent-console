# F12 Help Menu - Problemy i Rozwiązania

## Problem: F12 Help Window się zamyka natychmiast

### Próby rozwiązań:

1. **Pierwotnie**: `bind-key -n C-F12 new-window -n "Help" "console-help.sh"`
   - **Problem**: Skrypt kończy się, okno zamyka
   - **Przyczyna**: Interactive script nie działa w tmux new-window

2. **Próba 2**: `console-help.sh` z `tmux kill-window` w środku
   - **Problem**: kill-window zabija okno w którym skrypt się wykonuje
   - **Przyczyna**: Błędne koło - skrypt zabija swoje własne okno

3. **Próba 3**: `bash ~/.vps/sessions/src/console-help.sh`
   - **Problem**: Nadal się zamyka
   - **Przyczyna**: Bash kończy po wykonaniu skryptu

4. **Próba 4**: `new-window \; send-keys "script" Enter`
   - **Problem**: Komendy wykonują się w bieżącym oknie
   - **Przyczyna**: Składnia tmux bind-key

5. **Próba 5**: Multi-line heredoc w tmux.conf
   - **Problem**: Syntax error w tmux
   - **Przyczyna**: tmux nie obsługuje multi-line w bind-key

6. **Próba 6**: Długi echo + read
   - **Problem**: read nie działa w new-window
   - **Przyczyna**: Brak interaktywnego stdin w tmux window

7. **Próba 7**: echo + bash
   - **Problem**: Ładuje się pełny zshrc/bashrc
   - **Przyczyna**: Shell loading overhead

## Rozwiązanie: Dedykowana minimalna konsola
Otworzyć okno z prostym, minimalnym środowiskiem bez ładowania profili użytkownika.

## Lekcje:
- tmux new-window + interactive scripts = problemy
- Prostsze rozwiązania często lepsze
- Unikać complex shell scripts w bind-key
- Minimalne środowisko lepsze niż pełny shell loading
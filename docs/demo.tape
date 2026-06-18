# VHS tape for the cchat "surface" demo (install → layout → recall).
# Renders docs/demo.gif deterministically — no live Claude session needed,
# because it runs against the committed fixture under docs/demo-home/.
#
# Regenerate:  vhs docs/demo.tape      (needs: vhs, ffmpeg, ttyd)
# Run from the repository root.

Output docs/demo.gif

Set Shell "bash"
Set FontSize 18
Set Width 1200
Set Height 760
Set Padding 24
Set Theme "Catppuccin Mocha"

# Put cchat on PATH and point it at the demo fixture (reproducible, no live API).
Hide
Type `export PATH="$PWD:$PATH"; export CHAT_HOME="$PWD/docs/demo-home"; clear`
Enter
Show

Type "# 1. A ChatGPT-style Q&A tool that lives in your terminal"
Enter
Type "cchat --help"
Enter
Sleep 3s

Type "clear"
Enter
Type "# 2. Every conversation is a self-contained folder"
Enter
Type `ls -R "$CHAT_HOME"`
Enter
Sleep 3s

Type "clear"
Enter
Type "# 3. Transcripts are plain, greppable markdown"
Enter
Type `cat "$CHAT_HOME"/*/transcript.md`
Enter
Sleep 4s

Type "clear"
Enter
Type "# 4. Recall a fact from any past chat — free, local, instant"
Enter
Type `cchat search "Form 4868"`
Enter
Sleep 4s

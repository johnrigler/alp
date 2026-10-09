"""Exercise a.h in an actual interactive Bash history environment."""
import os
import pathlib
import shlex
import subprocess

root = pathlib.Path(__file__).resolve().parent.parent
commands = f'''HISTFILE=/dev/null
PS1=''
PS2=''
. {shlex.quote(str(root / 'alp2.bash'))}
. {shlex.quote(str(root / 'core.bash'))}
HISTTIMEFORMAT='%F %T '
HISTCONTROL=''
history -c
CAPTURE_RUNS=0
CAPTURE_RUNS=$((CAPTURE_RUNS + 1)); printf '%s\\n' 'a  b' 'literal $value' | tr a-z A-Z
a.h d.captured
[[ $CAPTURE_RUNS == 1 ]] || exit 21
result=$(d.captured)
[[ "$result" == $'A  B\\nLITERAL $VALUE' ]] || exit 22
printf 'HISTORY_QUOTING_OK\\n'
cat <<'END_CAPTURE'
two  spaces
literal $variable
END_CAPTURE
a.h d.multiline
[[ $(d.multiline) == $'two  spaces\\nliteral $variable' ]] || exit 23
printf 'HISTORY_MULTILINE_OK\\n'
a.h 'bad;name' >/dev/null 2>&1 && exit 24
printf 'HISTORY_NAME_OK\\n'
exit 0
'''
env = os.environ.copy()
env['HISTFILE'] = '/dev/null'
run = subprocess.run(['bash', '--noprofile', '--norc', '-i'], input=commands,
                     text=True, capture_output=True, env=env)
expected = ['HISTORY_QUOTING_OK', 'HISTORY_MULTILINE_OK', 'HISTORY_NAME_OK']
if run.returncode or not all(marker in run.stdout for marker in expected):
    raise SystemExit(f'History checks failed ({run.returncode})\n{run.stdout}\n{run.stderr}')
print('All interactive history checks passed.')

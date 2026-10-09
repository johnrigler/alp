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

edge_cases = {
    'empty history': '''history -c
a.h absent.function 2>/dev/null && exit 31
declare -F absent.function >/dev/null && exit 32
''',
    'repeated capture': '''history -c
printf '%s\\n' 'original command'
a.h retained.function
a.h retained.function 2>/dev/null && exit 33
[[ $(retained.function) == 'original command' ]] || exit 34
''',
    'single name argument': '''a.h one.name 123 2>/dev/null && exit 35
declare -F one.name >/dev/null && exit 36
''',
    'failed history command': '''UNEXPECTED_EXECUTION=0
history -s '}; UNEXPECTED_EXECUTION=1; unrelated.function () {'
a.h invalid.function 2>/dev/null && exit 37
[[ $UNEXPECTED_EXECUTION == 0 ]] || exit 38
declare -F invalid.function >/dev/null && exit 39
''',
    'ignored capture invocation': '''HISTCONTROL=ignorespace
history -c
printf '%s\\n' 'recorded command'
 a.h spaced.function
[[ $(spaced.function) == 'recorded command' ]] || exit 40
''',
}
prefix = f'''HISTFILE=/dev/null
PS1=''
PS2=''
. {shlex.quote(str(root / 'core.bash'))}
HISTCONTROL=''
'''
for name, case in edge_cases.items():
    run = subprocess.run(['bash', '--noprofile', '--norc', '-i'],
                         input=prefix + case + 'exit 0\n', text=True,
                         capture_output=True, env=env)
    if run.returncode:
        raise SystemExit(f'{name} failed ({run.returncode})\n{run.stdout}\n{run.stderr}')
print('All minimal history-capture edge checks passed.')

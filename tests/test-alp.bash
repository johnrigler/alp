#!/usr/bin/env bash
set -euo pipefail
test_root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)
test_work=$(mktemp -d)
trap 'rm -rf -- "$test_work"' EXIT
fail () { printf 'FAIL: %s\n' "$*" >&2; exit 1; }
library_dir="$test_work/library space"
mkdir -p "$library_dir"
cp -R -- "$test_root/alp.bash" "$test_root/alp2.bash" "$test_root/core.bash" "$test_root/functions" "$test_root/web" "$library_dir/"
unset _ALP_
start_directory=$PWD
. "$library_dir/alp.bash"
[[ $_ALP_ == "$library_dir" && $PWD == "$start_directory" ]] || fail 'bootstrap path or current directory'
declare -F alp2 a.h a.fs a.S >/dev/null || fail 'bootstrap helpers'
a.f a.h | grep -q 'builtin fc' || fail 'legacy files replaced the corrected history helper'

fixture_dir="$test_work/function directory"
mkdir -p "$fixture_dir"
printf 'first.loaded () { printf "first\\n"; }\nLOADED_STATE=retained\n' > "$fixture_dir/first one.bash"
printf 'second.loaded () { first.loaded; }\n' > "$fixture_dir/second.bash"
printf 'Not Bash.\n' > "$fixture_dir/notes.txt"
printf 'raise Exception("should not run while loading")\n' > "$fixture_dir/never.py"
printf 'function main() { return 1; }\n' > "$fixture_dir/tools.js-02345678"
file='caller file'; path='caller path'; __T='caller tag'; _FS='caller save'; t='caller t'; sum='caller sum'
alp2 "$fixture_dir"
[[ $(second.loaded) == first && $LOADED_STATE == retained ]] || fail 'definitions or state did not survive loading'
[[ $file == 'caller file' && $path == 'caller path' && $__T == 'caller tag' && $_FS == 'caller save' && $t == 'caller t' && $sum == 'caller sum' ]] || fail 'loader changed caller scratch variables'
[[ $PWD == "$start_directory" ]] || fail 'loader changed working directory'
grep -q $'view\tnotes.txt' "$fixture_dir/.files.txt" || fail 'text classification'
grep -q $'script\tnever.py' "$fixture_dir/.files.txt" || fail 'Python classification'
grep -q $'script\ttools.js-02345678' "$fixture_dir/.files.txt" || fail 'hashed JavaScript classification'

# Manifest order, legacy paths, CRLF, comments, and a last line without a newline.
printf 'LOAD_ORDER+=a\n' > "$fixture_dir/first one.bash"
printf 'LOAD_ORDER+=b\n' > "$fixture_dir/second.bash"
printf '# custom order\r\nsource\tsecond.bash\r\n\nfirst one.bash' > "$fixture_dir/.files.txt"
LOAD_ORDER=''
manifest_before=$(cat "$fixture_dir/.files.txt")
alp2 "$fixture_dir"
[[ $LOAD_ORDER == ba && $(cat "$fixture_dir/.files.txt") == "$manifest_before" ]] || fail 'manifest order or preservation'
printf 'source\tmissing.bash\nsource\tsecond.bash\n' > "$fixture_dir/.files.txt"
if alp2 "$fixture_dir" 2> "$test_work/error"; then fail 'missing source returned success'; fi
grep -q 'missing' "$test_work/error" || fail 'missing source diagnostic'
printf 'function broken( {\n' > "$fixture_dir/broken.bash"
printf 'source\tbroken.bash\n' > "$fixture_dir/.files.txt"
if alp2 "$fixture_dir" 2> "$test_work/error"; then fail 'invalid Bash accepted'; fi
printf 'source\t../outside.bash\n' > "$fixture_dir/.files.txt"
if alp2 "$fixture_dir" 2> "$test_work/error"; then fail 'parent traversal accepted'; fi

# Saving a Daisy-named function has no dependency on a d.* copy of each tool.
save_dir="$test_work/save directory"
mkdir "$save_dir"
cd "$save_dir"
d.example () { printf '%s\n' 'two  spaces' 'quoted $literal'; }
saved=$(a.fs d.example)
[[ -f $saved ]] || fail 'save output'
expected_body=$(declare -f d.example)
[[ $(cat "$saved") == "$expected_body" ]] || fail 'saved definition changed'
[[ $(a.f "$saved") == "$expected_body" ]] || fail 'snapshot-name resolution'
sum_parts=$(sum < "$saved")
read -r checksum blocks <<< "$sum_parts"
[[ $saved == "d.example-$checksum.$blocks" ]] || fail 'BSD sum filename compatibility'
[[ $(a.fs d.example) == "$saved" ]] || fail 'identical save changed filename'
unset -f d.example
. "./$saved"
[[ $(d.example) == $'two  spaces\nquoted $literal' ]] || fail 'saved function reload'
before_count=$(find . -maxdepth 1 -type f | wc -l)
if a.fs does.not.exist 2> "$test_work/error"; then fail 'missing function saved'; fi
[[ $(find . -maxdepth 1 -type f | wc -l) == "$before_count" ]] || fail 'empty snapshot written'
constant.hash () { printf '11111.1\n'; }
a.save d.example . constant.hash >/dev/null
d.example () { printf 'different\n'; }
if a.save d.example . constant.hash 2> "$test_work/error"; then fail 'checksum collision overwritten'; fi
grep -q 'collision' "$test_work/error" || fail 'collision diagnostic'
[[ $__T == 'caller tag' && $_FS == 'caller save' && $t == 'caller t' && $sum == 'caller sum' ]] || fail 'saver changed caller variables'

# Compare the unchanged hash format to the original implementation, not a copy.
expected_sha=$(printf 'hello' | bash -c '. "$1"; - () { printf "%s\n" "$*"; }; a.ss' bash "$test_root/functions/a.ss-47390.1")
[[ $(printf 'hello' | a.ss) == "$expected_sha" ]] || fail 'short SHA format changed'
[[ $(printf 'hello' | a.s) == "$(printf 'hello' | bash -c '. "$1"; - () { printf "%s\n" "$*"; }; a.s' bash "$test_root/functions/a.s-43637.1")" ]] || fail 'BSD sum format changed'
[[ $(printf '8\n' | a.shoctal) == 32 ]] || fail 'shifted octal conversion'
a.fS d.example >/dev/null
a.fss d.example >/dev/null

scripts_dir="$test_work/script directory"
mkdir "$scripts_dir"
printf 'printf "%%s" "$1" > result.txt\ncd /\nSCRIPT_GLOBAL=child\n' > "$scripts_dir/write.sh"
printf 'import pathlib, sys\npathlib.Path("python-result.txt").write_text(sys.argv[1])\n' > "$scripts_dir/ingest.py-02345678"
alp2 "$scripts_dir" scripts
[[ ! -f "$scripts_dir/result.txt" ]] || fail 'script ran during indexing/loading'
a.run "$scripts_dir" write.sh 'argument with spaces'
[[ $(cat "$scripts_dir/result.txt") == 'argument with spaces' && $PWD == "$save_dir" && ${SCRIPT_GLOBAL-unset} == unset ]] || fail 'explicit script behavior'
a.run "$scripts_dir" ingest.py-02345678 'hashed Python argument'
[[ $(cat "$scripts_dir/python-result.txt") == 'hashed Python argument' ]] || fail 'hashed Python script interpreter'
if a.run "$scripts_dir" result.txt 2> "$test_work/error"; then fail 'view file ran as script'; fi

# Live editing validates before replacing the running function.
edit_tool="$test_work/editor with spaces"
printf '#!/bin/bash\nprintf '\''d.example () { printf "edited\\n"; }\\n'\'' > "$1"\n' > "$edit_tool"
chmod +x "$edit_tool"
VISUAL="$edit_tool" a.v d.example >/dev/null
[[ $(d.example) == edited ]] || fail 'edited definition not loaded'
printf '#!/bin/bash\nprintf "invalid ( {\\n" > "$1"\n' > "$edit_tool"
mkdir "$test_work/editor temporary"
if TMPDIR="$test_work/editor temporary" VISUAL="$edit_tool" a.v d.example 2> "$test_work/error"; then fail 'invalid edit accepted'; fi
[[ $(d.example) == edited ]] || fail 'invalid edit replaced live function'
grep -q 'definition unchanged' "$test_work/error" || fail 'invalid edit recovery diagnostic'

a.web "$scripts_dir" >/dev/null
[[ -f "$scripts_dir/alp-view.html" ]] || fail 'web viewer copy'
a.index "$scripts_dir" scripts >/dev/null
if grep -q 'alp-view.html' "$scripts_dir/.files.txt"; then fail 'viewer indexed itself'; fi
printf 'All ALP shell checks passed.\n'

# Curated helpers. Historical checksum-named snapshots remain unchanged.

a.name ()
{
    local _alp_name=${1:-};
    [[ -n "$_alp_name" ]] || { printf 'usage: a.name function-or-snapshot\n' >&2; return 2; };
    if ! declare -F -- "$_alp_name" >/dev/null; then
        _alp_name=${_alp_name##*/};
        if [[ "$_alp_name" =~ ^(.+)-[0-9]+(\.[0-9]+)?$ ]]; then
            _alp_name=${BASH_REMATCH[1]};
        fi;
    fi;
    declare -F -- "$_alp_name" >/dev/null || { printf 'ALP: no function: %s\n' "$_alp_name" >&2; return 1; };
    printf '%s\n' "$_alp_name";
}

a.f () { local _alp_f_name; _alp_f_name=$(a.name "${1:-}") || return; declare -f -- "$_alp_f_name"; }
a.F () { if [[ $# == 0 ]]; then declare -F; else declare -F -- "$@"; fi; }
a.l () { declare -F | while read -r _alp_l_declare _alp_l_flag _alp_l_name; do [[ "$_alp_l_name" == a.* ]] && printf '%s\n' "$_alp_l_name"; :; done; }
a.dir () { cd -- "${_ALP_:?source alp.bash first}"; }

a.s ()
{
    : : BSD sum checksum and block count, preserving the existing format;
    local _alp_sum _alp_blocks;
    read -r _alp_sum _alp_blocks < <(LC_ALL=C sum) || return;
    printf '%s.%s\n' "$_alp_sum" "$_alp_blocks";
}

a.shoctal ()
{
    local _alp_octal_line;
    while IFS= read -r _alp_octal_line || [[ -n "$_alp_octal_line" ]]; do
        [[ "$_alp_octal_line" =~ ^[0-9]+$ ]] || return 2;
        printf '%o\n' "$((10#$_alp_octal_line))" | tr '01234567' '23456789';
    done;
}

a.S ()
{
    : : Shifted octal cksum and byte length, without the old a.sho dependency;
    local _alp_crc _alp_bytes;
    read -r _alp_crc _alp_bytes < <(cksum) || return;
    printf '%o.%o\n' "$_alp_crc" "$_alp_bytes" | tr '01234567' '23456789';
}

a.ss ()
{
    : : Preserve the original short SHA-1 shifted-octal format;
    local _alp_sha _alp_digest;
    _alp_sha=$(shasum) || return;
    _alp_digest=${_alp_sha:0:4};
    printf '02';
    printf '%o\n' "$((16#$_alp_digest))" | tr '01234567' '23456789';
}

a.Sh ()
{
    : : Preserve the existing seven-character shifted cksum format;
    local _alp_short_crc _alp_short_bytes;
    read -r _alp_short_crc _alp_short_bytes < <(cksum) || return;
    printf '.0';
    printf '%s\n' "$_alp_short_crc" | tr '01234567' '23456789' | cut -c 1-7;
}

a.save ()
{
    : : Save any function namespace using a selected checksum function;
    local _alp_save_name _alp_save_dir _alp_save_hash _alp_save_tmp _alp_save_file;
    _alp_save_name=$(a.name "${1:-}") || return;
    [[ "$_alp_save_name" != *[!A-Za-z0-9_.-]* ]] || { printf 'a.save: unsupported filename: %s\n' "$_alp_save_name" >&2; return 2; };
    _alp_save_dir=$(cd -- "${2:-.}" && pwd -P) || return;
    declare -F -- "${3:-a.s}" >/dev/null || { printf 'a.save: no checksum function: %s\n' "${3:-a.s}" >&2; return 1; };
    _alp_save_tmp=$(mktemp "$_alp_save_dir/.alp-save.XXXXXX") || return;
    if ! declare -f -- "$_alp_save_name" > "$_alp_save_tmp"; then
        rm -f -- "$_alp_save_tmp"; return 1;
    fi;
    _alp_save_hash=$("${3:-a.s}" < "$_alp_save_tmp") || { rm -f -- "$_alp_save_tmp"; return 1; };
    [[ "$_alp_save_hash" =~ ^[0-9]+(\.[0-9]+)?$ ]] || { printf 'a.save: invalid checksum\n' >&2; rm -f -- "$_alp_save_tmp"; return 1; };
    _alp_save_file="$_alp_save_name-$_alp_save_hash";
    if [[ -e "$_alp_save_dir/$_alp_save_file" ]]; then
        if ! cmp -s -- "$_alp_save_tmp" "$_alp_save_dir/$_alp_save_file"; then
            printf 'a.save: checksum collision: %s\n' "$_alp_save_file" >&2;
            rm -f -- "$_alp_save_tmp"; return 1;
        fi;
        rm -f -- "$_alp_save_tmp";
    else
        mv -- "$_alp_save_tmp" "$_alp_save_dir/$_alp_save_file" || { rm -f -- "$_alp_save_tmp"; return 1; };
    fi;
    if [[ "${2:-.}" == . ]]; then printf '%s\n' "$_alp_save_file"; else printf '%s\n' "$_alp_save_dir/$_alp_save_file"; fi;
}

a.fs () { a.save "${1:-}" "${2:-.}" a.s; }
a.fS () { a.save "${1:-}" "${2:-.}" a.S; }
a.fss () { a.save "${1:-}" "${2:-.}" a.ss; }

a.h ()
{
    : : Capture the previous history command as a function without running it;
    local _alp_history_name=${1:-} _alp_history_body _alp_history_definition;
    [[ $# == 1 && "$_alp_history_name" =~ ^[A-Za-z_.-][A-Za-z0-9_.-]*$ ]] || { printf 'usage: a.h function.name\n' >&2; return 2; };
    _alp_history_body=$(builtin fc -ln -1 -1) || return;
    if [[ -z "$_alp_history_body" || "$_alp_history_body" =~ ^[[:space:]]*a\.h([[:space:]]|$) ]]; then
        printf 'a.h: no preceding command to capture\n' >&2;
        return 1;
    fi;
    printf '%s\n' "$_alp_history_body" | bash -n || return;
    _alp_history_definition=$(printf '%s ()\n{\n%s\n}\n' "$_alp_history_name" "$_alp_history_body");
    eval "$_alp_history_definition";
}

a.v ()
{
    : : 'Edit a live definition; only reload after Bash syntax validation';
    local _alp_edit_name _alp_edit_tmp _alp_edit_editor=${VISUAL:-${EDITOR:-vi}};
    _alp_edit_name=$(a.name "${1:-}") || return;
    _alp_edit_tmp=$(mktemp "${TMPDIR:-/tmp}/alp-edit.XXXXXX") || return;
    declare -f -- "$_alp_edit_name" > "$_alp_edit_tmp" || { rm -f -- "$_alp_edit_tmp"; return 1; };
    if ! "$_alp_edit_editor" "$_alp_edit_tmp"; then rm -f -- "$_alp_edit_tmp"; return 1; fi;
    if ! bash -n -- "$_alp_edit_tmp"; then
        printf 'a.v: definition unchanged; edited text is in %s\n' "$_alp_edit_tmp" >&2;
        return 1;
    fi;
    if . "$_alp_edit_tmp"; then
        rm -f -- "$_alp_edit_tmp";
        printf '%s\n' "$_alp_edit_name";
    else
        printf 'a.v: source failed; edited text is in %s\n' "$_alp_edit_tmp" >&2;
        return 1;
    fi;
}

a.eval ()
{
    : : Reload ALP functions or a module, then restore the curated helpers;
    local _alp_eval_dir;
    if [[ $# == 0 ]]; then
        _alp_eval_dir="$_ALP_/functions";
    elif [[ -d "$1" ]]; then
        _alp_eval_dir=$1;
    else
        _alp_eval_dir="$_ALP_/$1/functions";
    fi;
    local _alp_eval_status=0;
    alp2 "$_alp_eval_dir" || _alp_eval_status=$?;
    . "$_ALP_/core.bash" || return;
    return "$_alp_eval_status";
}

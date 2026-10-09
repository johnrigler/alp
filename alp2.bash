# Source this file to define the directory tools. Nothing is loaded until called.

a.index ()
{
    : : Index a directory without executing its contents;
    local _alp_index_dir _alp_index_mode _alp_index_tmp _alp_index_path;
    local _alp_index_name _alp_index_base _alp_index_action LC_ALL=C;
    _alp_index_dir=$(cd -- "${1:-.}" && pwd -P) || return;
    _alp_index_mode=${2:-functions};
    case "$_alp_index_mode" in
        functions|scripts|view) ;;
        *) printf 'a.index: mode must be functions, scripts, or view\n' >&2; return 2 ;;
    esac;
    _alp_index_tmp=$(mktemp "$_alp_index_dir/.files.txt.XXXXXX") || return;
    {
        printf '# ALP mode: %s\n' "$_alp_index_mode";
        printf '# action<TAB>relative path; legacy plain paths mean source\n';
        for _alp_index_path in "$_alp_index_dir"/*; do
            [[ -e "$_alp_index_path" ]] || continue;
            _alp_index_name=${_alp_index_path##*/};
            _alp_index_base=$_alp_index_name;
            if [[ "$_alp_index_base" =~ ^(.+)-[0-9]+(\.[0-9]+)?$ ]]; then _alp_index_base=${BASH_REMATCH[1]}; fi;
            [[ "$_alp_index_name" == alp-view.html ]] && continue;
            case "$_alp_index_name" in
                *$'\t'*|*$'\n'*|*$'\r'*)
                    printf 'a.index: unsupported filename: %q\n' "$_alp_index_name" >&2;
                    continue ;;
            esac;
            _alp_index_action=view;
            if [[ -d "$_alp_index_path" ]]; then
                _alp_index_action=directory;
            elif [[ -f "$_alp_index_path" ]]; then
                case "$_alp_index_mode" in
                    scripts)
                        case "$_alp_index_base" in
                            *.sh|*.bash|*.py|*.js|*.mjs) _alp_index_action=script ;;
                            *) [[ -x "$_alp_index_path" ]] && _alp_index_action=script ;;
                        esac ;;
                    functions)
                        case "$_alp_index_base" in
                            *.sh|*.bash) _alp_index_action=source ;;
                            *.py|*.js|*.mjs) _alp_index_action=script ;;
                            README|LICENSE|*.md|*.txt|*.json|*.html|*.css|*.transactions|*.png|*.jpg|*.jpeg|*.gif|*.pdf|*.sqlite) ;;
                            *)
                                # ALP snapshots have numeric checksum suffixes; extensionless
                                # libraries such as FioNA are recognized by a function header.
                                if [[ "$_alp_index_name" =~ ^.+-[0-9]+(\.[0-9]+)?$ ]]; then
                                    _alp_index_action=source;
                                elif LC_ALL=C grep -Eq '^[[:space:]]*(function[[:space:]]+)?[A-Za-z_.-][A-Za-z0-9_.-]*[[:space:]]*\([[:space:]]*\)' "$_alp_index_path"; then
                                    _alp_index_action=source;
                                fi ;;
                        esac ;;
                esac;
            else
                continue;
            fi;
            printf '%s\t%s\n' "$_alp_index_action" "$_alp_index_name";
        done;
    } > "$_alp_index_tmp";
    if ! mv -- "$_alp_index_tmp" "$_alp_index_dir/.files.txt"; then
        rm -f -- "$_alp_index_tmp";
        return 1;
    fi;
    printf '%s\n' "$_alp_index_dir/.files.txt";
}

alp2 ()
{
    : : Load manifest source entries into the calling shell;
    local _alp_load_dir _alp_load_manifest _alp_load_line _alp_load_action;
    local _alp_load_name _alp_load_path _alp_load_status=0;
    _alp_load_dir=$(cd -- "${1:-${_ALP2_:-${HOME}/alp2}}" && pwd -P) || return;
    _alp_load_manifest="$_alp_load_dir/.files.txt";
    if [[ ! -f "$_alp_load_manifest" ]]; then
        a.index "$_alp_load_dir" "${2:-functions}" >/dev/null || return;
    elif [[ $# -gt 1 ]]; then
        printf 'alp2: .files.txt already exists; use a.index to change its mode\n' >&2;
        return 2;
    fi;
    _ALP2_=$_alp_load_dir;
    while IFS= read -r _alp_load_line || [[ -n "$_alp_load_line" ]]; do
        _alp_load_line=${_alp_load_line%$'\r'};
        [[ "$_alp_load_line" =~ ^[[:space:]]*$ || "$_alp_load_line" =~ ^[[:space:]]*# ]] && continue;
        _alp_load_action=source;
        _alp_load_name=$_alp_load_line;
        if [[ "$_alp_load_line" == *$'\t'* ]]; then
            _alp_load_action=${_alp_load_line%%$'\t'*};
            _alp_load_name=${_alp_load_line#*$'\t'};
        fi;
        case "$_alp_load_action" in
            view|script|directory) continue ;;
            source) ;;
            *) printf 'alp2: unknown action: %s\n' "$_alp_load_action" >&2; _alp_load_status=1; continue ;;
        esac;
        case "$_alp_load_name" in
            ''|/*|..|../*|*/../*|*/..)
                printf 'alp2: invalid relative path: %s\n' "$_alp_load_name" >&2;
                _alp_load_status=1; continue ;;
        esac;
        _alp_load_path="$_alp_load_dir/$_alp_load_name";
        if [[ ! -f "$_alp_load_path" ]]; then
            printf 'alp2: missing %s\n' "$_alp_load_path" >&2;
            _alp_load_status=1;
        elif ! bash -n -- "$_alp_load_path"; then
            printf 'alp2: invalid Bash: %s\n' "$_alp_load_path" >&2;
            _alp_load_status=1;
        elif . "$_alp_load_path"; then
            :;
        else
            printf 'alp2: source failed: %s\n' "$_alp_load_path" >&2;
            _alp_load_status=1;
        fi;
    done < "$_alp_load_manifest";
    return "$_alp_load_status";
}

a.run ()
{
    : : Run one script entry explicitly, with arguments;
    local _alp_run_dir _alp_run_name _alp_run_base _alp_run_line _alp_run_found=0;
    [[ $# -ge 2 ]] || { printf 'usage: a.run directory script [arguments...]\n' >&2; return 2; };
    _alp_run_dir=$(cd -- "$1" && pwd -P) || return;
    _alp_run_name=$2;
    _alp_run_base=$_alp_run_name;
    if [[ "$_alp_run_base" =~ ^(.+)-[0-9]+(\.[0-9]+)?$ ]]; then _alp_run_base=${BASH_REMATCH[1]}; fi;
    shift 2;
    [[ -f "$_alp_run_dir/.files.txt" ]] || { printf 'a.run: index this directory first\n' >&2; return 1; };
    while IFS= read -r _alp_run_line || [[ -n "$_alp_run_line" ]]; do
        _alp_run_line=${_alp_run_line%$'\r'};
        [[ "$_alp_run_line" == "script"$'\t'"$_alp_run_name" ]] && _alp_run_found=1;
    done < "$_alp_run_dir/.files.txt";
    [[ $_alp_run_found == 1 ]] || { printf 'a.run: not a script entry: %s\n' "$_alp_run_name" >&2; return 1; };
    case "$_alp_run_name" in
        ''|/*|..|../*|*/../*|*/..) printf 'a.run: invalid relative path\n' >&2; return 2 ;;
    esac;
    # Script working-directory changes and variables stay in a separate process.
    (
        cd -- "$_alp_run_dir" || exit;
        if [[ -x "$_alp_run_name" ]]; then
            "./$_alp_run_name" "$@";
        else
            case "$_alp_run_base" in
                *.sh|*.bash) bash -- "$_alp_run_name" "$@" ;;
                *.py) python3 -- "$_alp_run_name" "$@" ;;
                *.js|*.mjs)
                    printf 'a.run: add a shebang and executable permission to choose the JavaScript runtime\n' >&2;
                    exit 2 ;;
                *) printf 'a.run: script needs a shebang and executable permission\n' >&2; exit 2 ;;
            esac;
        fi;
    );
}

a.web ()
{
    : : Copy the static source viewer into an indexed directory;
    local _alp_web_dir _alp_web_template;
    _alp_web_dir=$(cd -- "${1:-.}" && pwd -P) || return;
    _alp_web_template="${_ALP_:-}/web/alp-view.html";
    [[ -f "$_alp_web_template" ]] || { printf 'a.web: source alp.bash first\n' >&2; return 1; };
    [[ -f "$_alp_web_dir/.files.txt" ]] || a.index "$_alp_web_dir" "${2:-functions}" >/dev/null || return;
    if [[ "$_alp_web_dir/alp-view.html" != "$_alp_web_template" ]]; then
        cp -- "$_alp_web_template" "$_alp_web_dir/alp-view.html" || return;
    fi;
    [[ -e "$_alp_web_dir/.nojekyll" ]] || : > "$_alp_web_dir/.nojekyll" || return;
    printf '%s\n' "$_alp_web_dir/alp-view.html";
}

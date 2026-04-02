#!/bin/sh
# semver — POSIX-compliant semantic versioning tool
# https://github.com/thesmart/semver-tool-posix
#
# Copyright (c) John Smart. Licensed under the Apache License 2.0.
# Original work Copyright (c) François Saint-Jacques (fsaintjacques/semver-tool).
#
# Bump, compare, diff, get, and validate semver 2.0.0 version strings.
# See: https://semver.org
set -eu


# Load getoptions library
# --- getoptions (inlined) ---

# shellcheck shell=sh disable=SC2016,SC2317
# [getoptions] License: Creative Commons Zero v1.0 Universal
getoptions() {
	_error="" _on=1 _no="" _export="" _plus="" _mode="" _alt="" _rest="" _def=""
	_flags="" _nflags="" _opts="" _help="" _abbr="" _cmds="" _init=@empty IFS=" "
	[ $# -lt 2 ] && set -- "${1:?No parser definition}" -
	[ "$2" = - ] && _def=getoptions_parse

	i="					"
	while eval "_${#i}() { echo \"$i\$@\"; }" && [ "$i" ]; do i=${i#?}; done

	quote() {
		q="$2'" r=""
		while [ "$q" ]; do r="$r${q%%\'*}'\''" && q=${q#*\'}; done
		q="'${r%????}'" && q=${q#\'\'} && q=${q%\'\'}
		eval "$1=\${q:-\"''\"}"
	}
	code() {
		[ "${1#:}" = "$1" ] && c=3 || c=4
		eval "[ ! \${$c:+x} ] || $2 \"\$$c\""
	}
	sw() { sw="$sw${sw:+|}$1"; }
	kv() { eval "${2-}${1%%:*}=\${1#*:}"; }
	loop() { [ $# -gt 1 ] && [ "$2" != -- ]; }

	invoke() { eval '"_$@"'; }
	prehook() { invoke "$@"; }
	for i in setup flag param option disp msg; do
		eval "$i() { prehook $i \"\$@\"; }"
	done

	args() {
		on=$_on no=$_no export=$_export init=$_init _hasarg=$1 && shift
		while loop "$@" && shift; do
			case $1 in
				-?) [ "$_hasarg" ] && _opts="$_opts${1#-}" || _flags="$_flags${1#-}" ;;
				+?) _plus=1 _nflags="$_nflags${1#+}" ;;
				[!-+]*) kv "$1"
			esac
		done
	}
	defvar() {
		case $init in
			@none) : ;;
			@export) code "$1" _0 "export $1" ;;
			@empty) code "$1" _0 "${export:+export }$1=''" ;;
			@unset) code "$1" _0 "unset $1 ||:" "unset OPTARG ||:; ${1#:}" ;;
			*)
				case $init in @*) eval "init=\"=\${${init#@}}\""; esac
				case $init in [!=]*) _0 "$init"; return 0; esac
				quote init "${init#=}"
				code "$1" _0 "${export:+export }$1=$init" "OPTARG=$init; ${1#:}"
		esac
	}
	_setup() {
		[ "${1#-}" ] && _rest=$1
		while loop "$@" && shift; do kv "$1" _; done
	}
	_flag() { args "" "$@"; defvar "$@"; }
	_param() { args 1 "$@"; defvar "$@"; }
	_option() { args 1 "$@"; defvar "$@"; }
	_disp() { args "" "$@"; }
	_msg() { args "" _ "$@"; }

	cmd() { _mode=@ _cmds="$_cmds${_cmds:+|}'$1'"; }
	"$@"
	cmd() { :; }
	_0 "${_rest:?}=''"

	_0 "${_def:-$2}() {"
	_1 'OPTIND=$(($#+1))'
	_1 "while OPTARG= && [ \"\${$_rest}\" != x ] && [ \$# -gt 0 ]; do"
	[ "$_abbr" ] && getoptions_abbr "$@"

	args() {
		sw="" validate="" pattern="" counter="" on=$_on no=$_no export=$_export
		while loop "$@" && shift; do
			case $1 in
				--\{no-\}*) i=${1#--?no-?}; sw "'--$i'|'--no-$i'" ;;
				--with\{out\}-*) i=${1#--*-}; sw "'--with-$i'|'--without-$i'" ;;
				[-+]? | --*) sw "'$1'" ;;
				*) kv "$1"
			esac
		done
		quote on "$on"
		quote no "$no"
	}
	setup() { :; }
	_flag() {
		args "$@"
		[ "$counter" ] && on=1 no=-1 v="\$((\${$1:-0}+\$OPTARG))" || v=""
		_3 "$sw)"
		_4 '[ "${OPTARG:-}" ] && OPTARG=${OPTARG#*\=} && set "noarg" "$1" && break'
		_4 "eval '[ \${OPTARG+x} ] &&:' && OPTARG=$on || OPTARG=$no"
		valid "$1" "${v:-\$OPTARG}"
		_4 ";;"
	}
	_param() {
		args "$@"
		_3 "$sw)"
		_4 '[ $# -le 1 ] && set "required" "$1" && break'
		_4 'OPTARG=$2'
		valid "$1" '$OPTARG'
		_4 "shift ;;"
	}
	_option() {
		args "$@"
		_3 "$sw)"
		_4 'set -- "$1" "$@"'
		_4 '[ ${OPTARG+x} ] && {'
		_5 'case $1 in --no-*|--without-*) set "noarg" "${1%%\=*}"; break; esac'
		_5 '[ "${OPTARG:-}" ] && { shift; OPTARG=$2; } ||' "OPTARG=$on"
		_4 "} || OPTARG=$no"
		valid "$1" '$OPTARG'
		_4 "shift ;;"
	}
	valid() {
		set -- "$validate" "$pattern" "$1" "$2"
		[ "$1" ] && _4 "$1 || { set -- ${1%% *}:\$? \"\$1\" $1; break; }"
		[ "$2" ] && {
			_4 "case \$OPTARG in $2) ;;"
			_5 '*) set "pattern:'"$2"'" "$1"; break'
			_4 "esac"
		}
		code "$3" _4 "${export:+export }$3=\"$4\"" "${3#:}"
	}
	_disp() {
		args "$@"
		_3 "$sw)"
		code "$1" _4 "echo \"\${$1}\"" "${1#:}"
		_4 "exit 0 ;;"
	}
	_msg() { :; }

	[ "$_alt" ] && _2 'case $1 in -[!-]?*) set -- "-$@"; esac'
	_2 'case $1 in'
	_wa() { _4 "eval 'set -- $1' \${1+'\"\$@\"'}"; }
	_op() {
		_3 "$1) OPTARG=\$1; shift"
		_wa '"${OPTARG%"${OPTARG#??}"}" '"$2"'"${OPTARG#??}"'
		_4 "${4:-}$3"
	}
	_3 '--?*=*) OPTARG=$1; shift'
	_wa '"${OPTARG%%\=*}" "${OPTARG#*\=}"'
	_4 ";;"
	_3 "--no-*|--without-*) unset OPTARG ;;"
	[ "$_alt" ] || {
		[ "$_opts" ] && _op "-[$_opts]?*" "" ";;"
		[ ! "$_flags" ] || _op "-[$_flags]?*" - "OPTARG= ;;" \
			'case $2 in --*) set -- "$1" unknown "$2" && '"$_rest=x; esac;"
	}
	[ "$_plus" ] && {
		[ "$_nflags" ] && _op "+[$_nflags]?*" + "unset OPTARG ;;"
		_3 "+*) unset OPTARG ;;"
	}
	_2 "esac"
	_2 'case $1 in'
	"$@"
	rest() {
		_4 'while [ $# -gt 0 ]; do'
		_5 "$_rest=\"\${$_rest}" '\"\${$(($OPTIND-$#))}\""'
		_5 "shift"
		_4 "done"
		_4 "break ;;"
	}
	_3 "--)"
	[ "$_mode" = @ ] || _4 "shift"
	rest
	_3 "[-${_plus:++}]?*)" 'set "unknown" "$1"; break ;;'
	_3 "*)"
	case $_mode in
		@)
			_4 "case \$1 in ${_cmds:-*}) ;;"
			_5 '*) set "notcmd" "$1"; break'
			_4 "esac"
			rest ;;
		+) rest ;;
		*) _4 "$_rest=\"\${$_rest}" '\"\${$(($OPTIND-$#))}\""'
	esac
	_2 "esac"
	_2 "shift"
	_1 "done"
	_1 '[ $# -eq 0 ] && { OPTIND=1; unset OPTARG; return 0; }'
	_1 'case $1 in'
	_2 'unknown) set "Unrecognized option: $2" "$@" ;;'
	_2 'noarg) set "Does not allow an argument: $2" "$@" ;;'
	_2 'required) set "Requires an argument: $2" "$@" ;;'
	_2 'pattern:*) set "Does not match the pattern (${1#*:}): $2" "$@" ;;'
	_2 'notcmd) set "Not a command: $2" "$@" ;;'
	_2 '*) set "Validation error ($1): $2" "$@"'
	_1 "esac"
	[ "$_error" ] && _1 "$_error" '"$@" >&2 || exit $?'
	_1 'echo "$1" >&2'
	_1 "exit 1"
	_0 "}"

	[ "$_help" ] && eval "shift 2; getoptions_help $1 $_help" ${3+'"$@"'}
	[ "$_def" ] && _0 "eval $_def \${1+'\"\$@\"'}; eval set -- \"\${$_rest}\""
	_0 "# Do not execute" # exit 1
}
# shellcheck shell=sh disable=SC2016,SC2317
# [getoptions_abbr] License: Creative Commons Zero v1.0 Universal
getoptions_abbr() {
	abbr() {
		_3 "case '$1' in"
		_4 '"$1") OPTARG=; break ;;'
		_4 '$1*) OPTARG="$OPTARG '"$1"'"'
		_3 "esac"
	}
	args() {
		abbr=1
		shift
		[ $# -gt 0 ] || return 0
		for i in "$@"; do
			case $i in
				--) break ;;
				[!-+]*) eval "${i%%:*}=\${i#*:}"
			esac
		done
		[ "$abbr" ] || return 0

		for i in "$@"; do
			case $i in
				--) break ;;
				--\{no-\}*) abbr "--${i#--\{no-\}}"; abbr "--no-${i#--\{no-\}}" ;;
				--*) abbr "$i"
			esac
		done
	}
	setup() { :; }
	for i in flag param option disp; do
		eval "_$i()" '{ args "$@"; }'
	done
	msg() { :; }
	_2 'set -- "${1%%\=*}" "${1#*\=}" "$@"'
	[ "$_alt" ] && _2 'case $1 in -[!-]?*) set -- "-$@"; esac'
	_2 'while [ ${#1} -gt 2 ]; do'
	_3 'case $1 in (*[!a-zA-Z0-9_-]*) break; esac'
	"$@"
	_3 "break"
	_2 "done"
	_2 'case ${OPTARG# } in'
	_3 "*\ *)"
	_4 'eval "set -- $OPTARG $1 $OPTARG"'
	_4 'OPTIND=$((($#+1)/2)) OPTARG=$1; shift'
	_4 'while [ $# -gt "$OPTIND" ]; do OPTARG="$OPTARG, $1"; shift; done'
	_4 'set "Ambiguous option: $1 (could be $OPTARG)" ambiguous "$@"'
	[ "$_error" ] && _4 "$_error" '"$@" >&2 || exit $?'
	_4 'echo "$1" >&2'
	_4 "exit 1 ;;"
	_3 "?*)"
	_4 '[ "$2" = "$3" ] || OPTARG="$OPTARG=$2"'
	_4 "shift 3; eval 'set -- \"\${OPTARG# }\"' \${1+'\"\$@\"'}; OPTARG= ;;"
	_3 "*) shift 2"
	_2 "esac"
}
# shellcheck shell=sh disable=SC2016,SC2317
# [getoptions_help] License: Creative Commons Zero v1.0 Universal
getoptions_help() {
	_width="30,12" _plus="" _leading="  "

	pad() { p=$2; while [ ${#p} -lt "$3" ]; do p="$p "; done; eval "$1=\$p"; }
	kv() { eval "${2-}${1%%:*}=\${1#*:}"; }
	sw() { pad sw "$sw${sw:+, }" "$1"; sw="$sw$2"; }

	args() {
		_type=$1 var=${2%% *} sw="" label="" hidden="" && shift 2
		while [ $# -gt 0 ] && i=$1 && shift && [ "$i" != -- ]; do
			case $i in
				--*) sw $((${_plus:+4}+4)) "$i" ;;
				-?) sw 0 "$i" ;;
				+?) [ ! "$_plus" ] || sw 4 "$i" ;;
				*) [ "$_type" = setup ] && kv "$i" _; kv "$i"
			esac
		done
		[ "$hidden" ] && return 0 || len=${_width%,*}

		[ "$label" ] || case $_type in
			setup | msg) label="" len=0 ;;
			flag | disp) label="$sw " ;;
			param) label="$sw $var " ;;
			option) label="${sw}[=$var] "
		esac
		[ "$_type" = cmd ] && label=${label:-$var } len=${_width#*,}
		pad label "${label:+$_leading}$label" "$len"
		[ ${#label} -le "$len" ] && [ $# -gt 0 ] && label="$label$1" && shift
		echo "$label"
		pad label "" "$len"
		[ $# -gt 0 ] || return 0
		for i in "$@"; do echo "$label$i"; done
	}

	for i in setup flag param option disp "msg -" cmd; do
		eval "${i% *}() { args $i \"\$@\"; }"
	done

	echo "$2() {"
	echo "cat<<'GETOPTIONSHERE'"
	"$@"
	echo "GETOPTIONSHERE"
	echo "}"
}

# --- end getoptions ---

# Load sub-components
# --- semver_validate.sh (inlined) ---
# semver_validate.sh — POSIX semver validation and part extraction
#
# Provides:
#   validate_version <version>         — prints normalized version or exits with error
#   validate_version_parts <version>   — sets _V_MAJOR _V_MINOR _V_PATCH _V_PREREL _V_BUILD
#   is_nat <string>                    — returns 0 if non-negative integer (no leading zeros)
#   is_null <string>                   — returns 0 if empty string
#
# Uses _sv_ prefix for internal variables.

# --- regex building blocks ---
_SV_NAT='0|[1-9][0-9]*'
_SV_ALPHANUM='[0-9]*[A-Za-z-][0-9A-Za-z-]*'
_SV_IDENT="${_SV_NAT}|${_SV_ALPHANUM}"
_SV_FIELD='[0-9A-Za-z-][0-9A-Za-z-]*'

# Full semver regex for expr (BRE syntax — no alternation with |, so we use grep -E)
# We validate using grep -E with ERE.
SEMVER_REGEX="^[vV]?(${_SV_NAT})\.(${_SV_NAT})\.(${_SV_NAT})(\-(${_SV_IDENT})(\.(${_SV_IDENT}))*)?(\+${_SV_FIELD}(\.${_SV_FIELD})*)?$"

is_nat() {
  case "$1" in
    0) return 0 ;;
    [1-9]) return 0 ;;
    [1-9][0-9]|[1-9][0-9][0-9]|[1-9][0-9][0-9][0-9]|[1-9][0-9][0-9][0-9][0-9]|[1-9][0-9][0-9][0-9][0-9][0-9]|[1-9][0-9][0-9][0-9][0-9][0-9][0-9]|[1-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]|[1-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]) return 0 ;;
    *) return 1 ;;
  esac
}

is_null() {
  [ -z "$1" ]
}

# _sv_check_semver <version>
# Returns 0 if version matches SEMVER_REGEX, 1 otherwise.
_sv_check_semver() {
  printf '%s\n' "$1" | grep -Eq "$SEMVER_REGEX"
}

# validate_version <version>
# Prints the normalized version (v/V prefix stripped) to stdout.
# Exits with error if invalid.
validate_version() {
  if _sv_check_semver "$1"; then
    _sv_tmp="${1#[vV]}"
    printf '%s\n' "$_sv_tmp"
  else
    printf '%s\n' "version $1 does not match the semver scheme 'X.Y.Z(-PRERELEASE)(+BUILD)'. See help for more information." >&2
    exit 1
  fi
}

# validate_version_parts <version>
# Sets: _V_MAJOR _V_MINOR _V_PATCH _V_PREREL _V_BUILD
# _V_PREREL includes the leading "-" if present.
# _V_BUILD includes the leading "+" if present.
# Exits with error if invalid.
validate_version_parts() {
  _sv_check_semver "$1" || {
    printf '%s\n' "version $1 does not match the semver scheme 'X.Y.Z(-PRERELEASE)(+BUILD)'. See help for more information." >&2
    exit 1
  }

  _sv_ver="${1#[vV]}"

  # Extract build metadata (everything after +)
  case "$_sv_ver" in
    *+*) _V_BUILD="+${_sv_ver#*+}"; _sv_ver="${_sv_ver%%+*}" ;;
    *)   _V_BUILD="" ;;
  esac

  # Extract prerelease (everything after first - in remaining)
  # But we must be careful: the release part is X.Y.Z, then - starts prerelease
  _sv_release="${_sv_ver%%[-]*}"

  # Check if there actually is a prerelease part (release part must be X.Y.Z exactly)
  # We need to find the first '-' after the X.Y.Z portion
  case "$_sv_ver" in
    "${_sv_release}"-*)
      _V_PREREL="-${_sv_ver#"${_sv_release}"-}"
      ;;
    *)
      _V_PREREL=""
      ;;
  esac

  # Split release into major.minor.patch
  _V_MAJOR="${_sv_release%%.*}"
  _sv_rest="${_sv_release#*.}"
  _V_MINOR="${_sv_rest%%.*}"
  _V_PATCH="${_sv_rest#*.}"
}

# validate_version_parts2 <version>
# Same as validate_version_parts but sets _V2_* variables.
validate_version_parts2() {
  _sv_check_semver "$1" || {
    printf '%s\n' "version $1 does not match the semver scheme 'X.Y.Z(-PRERELEASE)(+BUILD)'. See help for more information." >&2
    exit 1
  }

  _sv_ver="${1#[vV]}"

  case "$_sv_ver" in
    *+*) _V2_BUILD="+${_sv_ver#*+}"; _sv_ver="${_sv_ver%%+*}" ;;
    *)   _V2_BUILD="" ;;
  esac

  _sv_release="${_sv_ver%%[-]*}"

  case "$_sv_ver" in
    "${_sv_release}"-*)
      _V2_PREREL="-${_sv_ver#"${_sv_release}"-}"
      ;;
    *)
      _V2_PREREL=""
      ;;
  esac

  _V2_MAJOR="${_sv_release%%.*}"
  _sv_rest="${_sv_release#*.}"
  _V2_MINOR="${_sv_rest%%.*}"
  _V2_PATCH="${_sv_rest#*.}"
}
# --- end semver_validate.sh ---
# --- semver_get.sh (inlined) ---
# semver_get.sh — extract parts from a semver version string
#
# Provides:
#   command_get <part> <version>
#
# Requires: semver_validate.sh sourced first.
# Uses _sg_ prefix for internal variables.

# normalize_part <part>
# Normalizes "prerelease" to "prerel".
normalize_part() {
  case "$1" in
    prerelease) printf '%s\n' "prerel" ;;
    *)          printf '%s\n' "$1" ;;
  esac
}

command_get() {
  if [ "$#" -ne 2 ] || [ -z "$1" ] || [ -z "$2" ]; then
    usage_help
  fi

  _sg_part="$1"
  _sg_version="$2"

  validate_version_parts "$_sg_version"
  _sg_major="$_V_MAJOR"
  _sg_minor="$_V_MINOR"
  _sg_patch="$_V_PATCH"
  _sg_prerel="${_V_PREREL#-}"
  _sg_build="${_V_BUILD#+}"
  _sg_release="${_sg_major}.${_sg_minor}.${_sg_patch}"

  _sg_part="$(normalize_part "$_sg_part")"

  case "$_sg_part" in
    major)   printf '%s\n' "$_sg_major" ;;
    minor)   printf '%s\n' "$_sg_minor" ;;
    patch)   printf '%s\n' "$_sg_patch" ;;
    prerel)  printf '%s\n' "$_sg_prerel" ;;
    build)   printf '%s\n' "$_sg_build" ;;
    release) printf '%s\n' "$_sg_release" ;;
    *)       usage_help ;;
  esac

  exit 0
}
# --- end semver_get.sh ---
# --- semver_diff.sh (inlined) ---
# semver_diff.sh — diff two semver versions
#
# Provides:
#   command_diff <version> <other_version>
#
# Requires: semver_validate.sh sourced first.
# Uses _sd_ prefix for internal variables.

command_diff() {
  validate_version_parts "$1"
  _sd_v1_major="$_V_MAJOR"
  _sd_v1_minor="$_V_MINOR"
  _sd_v1_patch="$_V_PATCH"
  _sd_v1_prerel="$_V_PREREL"
  _sd_v1_build="$_V_BUILD"

  validate_version_parts "$2"
  _sd_v2_major="$_V_MAJOR"
  _sd_v2_minor="$_V_MINOR"
  _sd_v2_patch="$_V_PATCH"
  _sd_v2_prerel="$_V_PREREL"
  _sd_v2_build="$_V_BUILD"

  if [ "$_sd_v1_major" != "$_sd_v2_major" ]; then
    printf '%s\n' "major"
  elif [ "$_sd_v1_minor" != "$_sd_v2_minor" ]; then
    printf '%s\n' "minor"
  elif [ "$_sd_v1_patch" != "$_sd_v2_patch" ]; then
    printf '%s\n' "patch"
  elif [ "$_sd_v1_prerel" != "$_sd_v2_prerel" ]; then
    printf '%s\n' "prerelease"
  elif [ "$_sd_v1_build" != "$_sd_v2_build" ]; then
    printf '%s\n' "build"
  fi
}
# --- end semver_diff.sh ---
# --- semver_compare.sh (inlined) ---
# semver_compare.sh — compare two semver versions
#
# Provides:
#   command_compare <version> <other_version>
#   compare_version <version> <other_version>
#
# Requires: semver_validate.sh sourced first.
# Uses _sc_ prefix for internal variables.

order_nat() {
  if [ "$1" -lt "$2" ]; then
    printf '%s\n' "-1"
  elif [ "$1" -gt "$2" ]; then
    printf '%s\n' "1"
  else
    printf '%s\n' "0"
  fi
}

order_string() {
  if [ "$1" = "$2" ]; then
    printf '%s\n' "0"
  elif [ "$(printf '%s\n%s\n' "$1" "$2" | sort | head -n1)" = "$1" ]; then
    printf '%s\n' "-1"
  else
    printf '%s\n' "1"
  fi
}

# _sc_compare_fields <left_fields> <right_fields>
# Fields are dot-separated strings (e.g., "rc.1.2" and "rc.1.3").
# Compares field by field per semver 2.0.0 spec.
_sc_compare_fields() {
  _sc_left="$1"
  _sc_right="$2"

  while :; do
    # Extract first field from each
    case "$_sc_left" in
      *.*) _sc_lf="${_sc_left%%.*}"; _sc_left="${_sc_left#*.}" ;;
      *)   _sc_lf="$_sc_left"; _sc_left="" ;;
    esac
    case "$_sc_right" in
      *.*) _sc_rf="${_sc_right%%.*}"; _sc_right="${_sc_right#*.}" ;;
      *)   _sc_rf="$_sc_right"; _sc_right="" ;;
    esac

    # Both exhausted
    if is_null "$_sc_lf" && is_null "$_sc_rf"; then
      printf '%s\n' "0"
      return
    fi
    # Left exhausted (shorter), right still has fields
    if is_null "$_sc_lf"; then
      printf '%s\n' "-1"
      return
    fi
    # Right exhausted (shorter), left still has fields
    if is_null "$_sc_rf"; then
      printf '%s\n' "1"
      return
    fi

    # Both are natural numbers — compare numerically
    if is_nat "$_sc_lf" && is_nat "$_sc_rf"; then
      _sc_ord="$(order_nat "$_sc_lf" "$_sc_rf")"
      if [ "$_sc_ord" -ne 0 ]; then
        printf '%s\n' "$_sc_ord"
        return
      fi
      # equal, continue to next field
    elif is_nat "$_sc_lf"; then
      # numeric < non-numeric
      printf '%s\n' "-1"
      return
    elif is_nat "$_sc_rf"; then
      # non-numeric > numeric
      printf '%s\n' "1"
      return
    else
      # Both non-numeric — compare lexically
      _sc_ord="$(order_string "$_sc_lf" "$_sc_rf")"
      if [ "$_sc_ord" -ne 0 ]; then
        printf '%s\n' "$_sc_ord"
        return
      fi
    fi

    # Fields equal, but check if one side is exhausted and other isn't
    if is_null "$_sc_left" && is_null "$_sc_right"; then
      # No more fields on either side, they're equal so far
      continue
    fi
  done
}

# compare_version <version> <other_version>
# Prints -1, 0, or 1.
compare_version() {
  validate_version_parts "$1"
  _sc_v1_major="$_V_MAJOR"
  _sc_v1_minor="$_V_MINOR"
  _sc_v1_patch="$_V_PATCH"
  _sc_v1_prerel="$_V_PREREL"

  validate_version_parts "$2"
  _sc_v2_major="$_V_MAJOR"
  _sc_v2_minor="$_V_MINOR"
  _sc_v2_patch="$_V_PATCH"
  _sc_v2_prerel="$_V_PREREL"

  # Compare major.minor.patch numerically
  _sc_ord="$(order_nat "$_sc_v1_major" "$_sc_v2_major")"
  if [ "$_sc_ord" -ne 0 ]; then printf '%s\n' "$_sc_ord"; return; fi

  _sc_ord="$(order_nat "$_sc_v1_minor" "$_sc_v2_minor")"
  if [ "$_sc_ord" -ne 0 ]; then printf '%s\n' "$_sc_ord"; return; fi

  _sc_ord="$(order_nat "$_sc_v1_patch" "$_sc_v2_patch")"
  if [ "$_sc_ord" -ne 0 ]; then printf '%s\n' "$_sc_ord"; return; fi

  # Strip leading "-" from prerelease
  _sc_pre1="${_sc_v1_prerel#-}"
  _sc_pre2="${_sc_v2_prerel#-}"

  # Both have no prerelease — equal
  if [ -z "$_sc_pre1" ] && [ -z "$_sc_pre2" ]; then
    printf '%s\n' "0"
    return
  fi
  # Only left has no prerelease — left is greater (release > prerelease)
  if [ -z "$_sc_pre1" ]; then
    printf '%s\n' "1"
    return
  fi
  # Only right has no prerelease — right is greater
  if [ -z "$_sc_pre2" ]; then
    printf '%s\n' "-1"
    return
  fi

  # Compare prerelease fields
  _sc_compare_fields "$_sc_pre1" "$_sc_pre2"
}

command_compare() {
  case $# in
    2) ;;
    *) usage_help ;;
  esac

  # Validate both versions (prints normalized, but we just need to check validity)
  validate_version "$1" >/dev/null
  validate_version "$2" >/dev/null

  compare_version "$1" "$2"
  exit 0
}
# --- end semver_compare.sh ---
# --- semver_bump.sh (inlined) ---
# semver_bump.sh — bump semver version components
#
# Provides:
#   command_bump <subcommand> [<arg>] <version>
#
# Requires: semver_validate.sh sourced first.
# Uses _sb_ prefix for internal variables.

# render_prerel <numeric> [<prefix>]
# Returns a prerelease field with a trailing numeric string.
render_prerel() {
  if [ -z "$2" ]; then
    printf '%s\n' "$1"
  else
    printf '%s\n' "${2}${1}"
  fi
}

# extract_prerel <prerel_string>
# Sets _sb_ep_prefix and _sb_ep_numeric.
# Extracts prefix and trailing numeric portions of a pre-release part.
extract_prerel() {
  _sb_ep_input="$1"

  # Try to match trailing digits
  # Use expr to extract trailing numeric part
  _sb_ep_numeric="$(expr "$_sb_ep_input" : '.*[.A-Za-z-]\([0-9][0-9]*\)$' 2>/dev/null)" || _sb_ep_numeric=""

  if [ -n "$_sb_ep_numeric" ]; then
    # prefix is everything before the trailing numeric
    _sb_ep_len=${#_sb_ep_numeric}
    _sb_ep_totallen=${#_sb_ep_input}
    _sb_ep_prefixlen=$((_sb_ep_totallen - _sb_ep_len))
    _sb_ep_prefix="$(printf '%s' "$_sb_ep_input" | cut -c1-"${_sb_ep_prefixlen}")"
  else
    # Check if it's purely numeric
    case "$_sb_ep_input" in
      [0-9]|[0-9][0-9]|[0-9][0-9][0-9]|[0-9][0-9][0-9][0-9]|[0-9][0-9][0-9][0-9][0-9]*)
        # Check if it's all digits
        _sb_ep_check="$(printf '%s' "$_sb_ep_input" | tr -d '0-9')"
        if [ -z "$_sb_ep_check" ]; then
          _sb_ep_numeric="$_sb_ep_input"
          _sb_ep_prefix=""
        else
          _sb_ep_prefix="$_sb_ep_input"
          _sb_ep_numeric=""
        fi
        ;;
      *)
        _sb_ep_prefix="$_sb_ep_input"
        _sb_ep_numeric=""
        ;;
    esac
  fi
}

# bump_prerel <proto> <previous_prerel>
# previous_prerel includes the leading "-" if present.
# Prints the new pre-release string (without leading "-").
bump_prerel() {
  _sb_proto="$1"
  _sb_prev="$2"

  # Case one: no trailing dot in prototype => simply replace
  case "$_sb_proto" in
    *.) ;;  # has trailing dot, continue below
    *)
      printf '%s\n' "$_sb_proto"
      return
      ;;
  esac

  # Discard trailing dot marker from prototype
  _sb_proto="${_sb_proto%.}"

  # Extract parts of previous pre-release (strip leading "-")
  _sb_prev_stripped="${_sb_prev#-}"
  extract_prerel "$_sb_prev_stripped"
  _sb_prev_prefix="$_sb_ep_prefix"
  _sb_prev_numeric="$_sb_ep_numeric"

  # Case two: dummy "+" indicates no prototype argument provided
  if [ "$_sb_proto" = "+" ]; then
    if [ -n "$_sb_prev_numeric" ]; then
      _sb_prev_numeric=$((_sb_prev_numeric + 1))
      render_prerel "$_sb_prev_numeric" "$_sb_prev_prefix"
    else
      render_prerel 1 "$_sb_prev_prefix"
    fi
    return
  fi

  # Case three: set, bump, or append using prototype prefix
  if [ "$_sb_prev_prefix" != "$_sb_proto" ]; then
    render_prerel 1 "$_sb_proto"
  elif [ -n "$_sb_prev_numeric" ]; then
    _sb_prev_numeric=$((_sb_prev_numeric + 1))
    render_prerel "$_sb_prev_numeric" "$_sb_prev_prefix"
  else
    render_prerel 1 "$_sb_prev_prefix"
  fi
}

command_bump() {
  _sb_command="$(normalize_part "$1")"

  case $# in
    2) case "$_sb_command" in
        major|minor|patch|prerel|release) _sb_sub_version="+."; _sb_version="$2" ;;
        *) usage_help ;;
       esac ;;
    3) case "$_sb_command" in
        prerel|build) _sb_sub_version="$2"; _sb_version="$3" ;;
        *) usage_help ;;
       esac ;;
    *) usage_help ;;
  esac

  validate_version_parts "$_sb_version"
  _sb_major="$_V_MAJOR"
  _sb_minor="$_V_MINOR"
  _sb_patch="$_V_PATCH"
  _sb_prerel="$_V_PREREL"
  _sb_build="$_V_BUILD"

  case "$_sb_command" in
    major) _sb_new="$((_sb_major + 1)).0.0" ;;
    minor) _sb_new="${_sb_major}.$((_sb_minor + 1)).0" ;;
    patch) _sb_new="${_sb_major}.${_sb_minor}.$((_sb_patch + 1))" ;;
    release) _sb_new="${_sb_major}.${_sb_minor}.${_sb_patch}" ;;
    prerel) _sb_new="$(validate_version "${_sb_major}.${_sb_minor}.${_sb_patch}-$(bump_prerel "$_sb_sub_version" "$_sb_prerel")")" ;;
    build) _sb_new="$(validate_version "${_sb_major}.${_sb_minor}.${_sb_patch}${_sb_prerel}+${_sb_sub_version}")" ;;
    *) usage_help ;;
  esac

  printf '%s\n' "$_sb_new"
  exit 0
}
# --- end semver_bump.sh ---

VERSION="3.4.0"

USAGE="\
Usage:
  semver bump major <version>
  semver bump minor <version>
  semver bump patch <version>
  semver bump prerel|prerelease [<prerel>] <version>
  semver bump build <build> <version>
  semver bump release <version>
  semver get major <version>
  semver get minor <version>
  semver get patch <version>
  semver get prerel|prerelease <version>
  semver get build <version>
  semver get release <version>
  semver compare <version> <other_version>
  semver diff <version> <other_version>
  semver validate <version>
  semver --help
  semver --version

Arguments:
  <version>  A version must match X.Y.Z[-PRERELEASE][+BUILD]
             where X, Y and Z are non-negative integers.
             PRERELEASE is a dot separated sequence of non-negative integers and/or
             identifiers composed of alphanumeric characters and hyphens (with
             at least one non-digit). Numeric identifiers must not have leading
             zeros. A hyphen (\"-\") introduces this optional part.
             BUILD is a dot separated sequence of identifiers composed of alphanumeric
             characters and hyphens. A plus (\"+\") introduces this optional part.

  <other_version>  See <version> definition.

  <prerel>  A string as defined by PRERELEASE above. Or, it can be a PRERELEASE
            prototype string followed by a dot.

  <build>   A string as defined by BUILD above.

Options:
  -v, --version          Print the version of this tool.
  -h, --help             Print this help message.

Commands:
  bump      Bump by one of major, minor, patch; zeroing or removing
            subsequent parts. \"bump prerel\" (or its synonym \"bump prerelease\")
            sets the PRERELEASE part and removes any BUILD part. A trailing dot
            in the <prerel> argument introduces an incrementing numeric field
            which is added or bumped. If no <prerel> argument is provided, an
            incrementing numeric field is introduced/bumped. \"bump build\" sets
            the BUILD part.  \"bump release\" removes any PRERELEASE or BUILD parts.
            The bumped version is written to stdout.

  get       Extract given part of <version>, where part is one of major, minor,
            patch, prerel (alternatively: prerelease), build, or release.

  compare   Compare <version> with <other_version>, output to stdout the
            following values: -1 if <other_version> is newer, 0 if equal, 1 if
            older. The BUILD part is not used in comparisons.

  diff      Compare <version> with <other_version>, output to stdout the
            difference between two versions by the release type (MAJOR, MINOR,
            PATCH, PRERELEASE, BUILD).

  validate  Validate if <version> follows the SEMVER pattern (see <version>
            definition). Print 'valid' to stdout if the version is valid, otherwise
            print 'invalid'.

See also:
  https://semver.org -- Semantic Versioning 2.0.0

Copyright (c) John Smart. Licensed under the Apache License 2.0.
  https://github.com/thesmart/semver-tool-posix
Original work Copyright (c) François Saint-Jacques.
  https://github.com/fsaintjacques/semver-tool"

usage_help() {
  printf '%s\n' "$USAGE" >&2
  exit 1
}

usage_version() {
  printf '%s\n' "semver: $VERSION"
  exit 0
}

command_validate() {
  if [ "$#" -ne 1 ]; then
    usage_help
  fi

  if _sv_check_semver "$1"; then
    printf '%s\n' "valid"
  else
    printf '%s\n' "invalid"
  fi

  exit 0
}

# --- main dispatch ---

case ${1:-} in
  "") printf '%s\n' "Unknown command: $*" >&2; usage_help ;;
  --help|-h) printf '%s\n' "$USAGE"; exit 0 ;;
  --version|-v) usage_version ;;
  bump) shift; command_bump "$@" ;;
  get) shift; command_get "$@" ;;
  compare) shift; command_compare "$@" ;;
  diff) shift; command_diff "$@" ;;
  validate) shift; command_validate "$@" ;;
  *) printf '%s\n' "Unknown arguments: $*" >&2; usage_help ;;
esac

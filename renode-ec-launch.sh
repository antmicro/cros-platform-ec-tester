#!/bin/bash
#
# Launch an EC image in renode.

DEFAULT_EC_ROOT="$HOME/chromiumos/src/platform/ec"
DEFAULT_BOARD="bloonchipper"
DEFAULT_PROJECT="ec"

SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
SCRIPT_PATH="$(dirname "${BASH_SOURCE[0]}")"

usage() {
	echo "Usage: ${SCRIPT_NAME} [ec-path] [board-name] [project-name]"
	echo ""
	echo "Launch an EC image in renode. This can be the actual firmware image"
	echo "or an on-board test image."
	echo ""
	echo "Environment Variables:"
	echo "  BOARD overrides board-name argument."
	echo "  PROJECT overrides project-name argument."
	echo ""
	echo "Args:"
	echo "  ec-path is the path to the EC source root dir [${DEFAULT_EC_ROOT}]"
	echo "  board-name is the name of the EC board [${DEFAULT_BOARD}]"
	echo "  project-name is the name of the EC project [${DEFAULT_PROJECT}]"
	echo "    This is normally ec for the main firmware image and the test"
	echo "    name for an on-board test image."
	echo ""
	echo "Examples:"
	echo "  ${SCRIPT_NAME}"
	echo "  ${SCRIPT_NAME} ${DEFAULT_EC_ROOT} bloonchipper abort"
	echo "  BOARD=dartmonkey ${SCRIPT_NAME}"
	echo "  PROJECT=always_memset ${SCRIPT_NAME}"
}

main() {
	local ec_root_dir="${1:-${DEFAULT_EC_ROOT}}"
	local board="${2:-${BOARD:-${DEFAULT_BOARD}}}"
	local project="${3:-${PROJECT:-${DEFAULT_PROJECT}}}"

	for arg; do
		case "${arg}" in
			--help|-h)
				usage
				return 0
				;;
		esac
	done

	# Since we are going to cd later, we need to capture the absolute path.
	local ec_dir="$(realpath "${ec_root_dir}")"
	local out="${ec_dir}/build/${board}"

	if [[ "${project}" != "ec" ]]; then
		out+="/${project}"
	fi

	local bin="${out}/${project}.bin"
	local elf_ro="${out}/RO/${project}.RO.elf"
	local elf_rw="${out}/RW/${project}.RW.elf"

	# We need to run the "include @${BOARD}.resc" from within the
	# cros-platform-ec-tester dir.
	cd "${SCRIPT_PATH}" || return 1

	EXECUTE=( )
	EXECUTE+=( "\$bin='${bin}';" )
	EXECUTE+=( "\$elf_ro='${elf_ro}';" )
	EXECUTE+=( "\$elf_rw='${elf_rw}';" )
	EXECUTE+=( "include @${board}.resc;" )
	EXECUTE+=( "start;" )

	CMD=( renode )
	CMD+=( --console )
	CMD+=( --execute "${EXECUTE[*]}" )

	echo "${CMD[@]}"
	exec "${CMD[@]}"
}

main "$@"

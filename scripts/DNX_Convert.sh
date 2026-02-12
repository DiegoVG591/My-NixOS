#!/usr/bin/env bash
# Reference: https://raw.githubusercontent.com/NapoleonWils0n/nixos-bin/master/dnxhd-pcm

#===============================================================================
# convert video to 60fps (native) dnxhd and audio to pcm for NixOS Resolve
#===============================================================================

usage()
{
[ -z "${1}" ] || echo "! ${1}"
echo "\
# convert video to dnxhd and audio to pcm (60fps optimized)

$(basename "$0") -i infile.(mp4|mkv|mov|m4v|webm) -o outfile.mov
-i infile.(mp4|mkv|mov|m4v|webm)
-o outfile.mov :optional argument # defaults to infile-name-dnxhd.mov"
exit 2
}

# Error messages
NOTFILE_ERR='not a file'
INVALID_OPT_ERR='Invalid option:'
REQ_ARG_ERR='requires an argument'
WRONG_ARGS_ERR='wrong number of arguments passed to script'

[ $# -gt 0 ] || usage "${WRONG_ARGS_ERR}"

while getopts ':i:o:h' opt
do
  case ${opt} in
     i) infile="${OPTARG}"
	[ -f "${infile}" ] || usage "${infile} ${NOTFILE_ERR}";;
     o) outfile="${OPTARG}";;
     h) usage;;
     \?) usage "${INVALID_OPT_ERR} ${OPTARG}" 1>&2;;
     :) usage "${INVALID_OPT_ERR} ${OPTARG} ${REQ_ARG_ERR}" 1>&2;;
  esac
done
shift $((OPTIND-1))

# Variables
infile_nopath="${infile##*/}"
infile_name="${infile_nopath%.*}"
outfile_default="${infile_name}-dnxhd.mov"

#===============================================================================
# Optimized dnx function: Preserves 60fps and native resolution
#===============================================================================
dnx () {
    ffmpeg \
    -hide_banner \
    -stats \
    -i "${infile}" \
    -c:v dnxhd \
    -b:v 290M \
    -pix_fmt yuv422p \
    -c:a pcm_s16le \
    -f mov \
    "${outfile:=${outfile_default}}"
}

# Run the function
dnx "${infile}"

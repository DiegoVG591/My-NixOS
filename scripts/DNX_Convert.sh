#!/usr/bin/env bash
# Reference: https://raw.githubusercontent.com/NapoleonWils0n/nixos-bin/master/dnxhd-pcm

#===============================================================================
# convert video to 60fps (native) dnxhd and audio to pcm for NixOS Resolve
# Supports both local files and YouTube URLs
#===============================================================================

usage()
{
[ -z "${1}" ] || echo "! ${1}"
echo "\
# convert video to dnxhd and audio to pcm (60fps optimized)

$(basename "$0") -i [infile|url] -o outfile.mov
-i infile.(mp4|mkv|mov|m4v|webm) or YouTube URL
-o outfile.mov :optional argument # defaults to infile-name-dnxhd.mov"
exit 2
}

# Error messages
NOTFILE_ERR='not a file or valid URL'
INVALID_OPT_ERR='Invalid option:'
REQ_ARG_ERR='requires an argument'
WRONG_ARGS_ERR='wrong number of arguments passed to script'

[ $# -gt 0 ] || usage "${WRONG_ARGS_ERR}"

while getopts ':i:o:h' opt
do
  case ${opt} in
     i) input="${OPTARG}" ;;
     o) outfile="${OPTARG}";;
     h) usage;;
     \?) usage "${INVALID_OPT_ERR} ${OPTARG}" 1>&2;;
     :) usage "${INVALID_OPT_ERR} ${OPTARG} ${REQ_ARG_ERR}" 1>&2;;
  esac
done
shift $((OPTIND-1))

#===============================================================================
# Variables & Logic Path
#===============================================================================
if [[ "$input" =~ ^http ]]; then
    # URL Logic
    infile_name="youtube-vod"
    is_url=true
else
    # Local File Logic
    [ -f "${input}" ] || usage "${input} ${NOTFILE_ERR}"
    infile_nopath="${input##*/}"
    infile_name="${infile_nopath%.*}"
    is_url=false
fi

outfile_default="${infile_name}-dnxhd.mov"
final_output="${outfile:=${outfile_default}}"

#===============================================================================
# Optimized dnx function: Preserves 60fps and native resolution
#===============================================================================
dnx () {
    if [ "$is_url" = true ]; then
        # Stream from yt-dlp directly into ffmpeg pipe
        yt-dlp -f 'bestvideo+bestaudio/best' "$input" -o - | \
        ffmpeg \
        -hide_banner \
        -stats \
        -i pipe:0 \
        -c:v dnxhd \
        -b:v 290M \
        -pix_fmt yuv422p \
        -c:a pcm_s16le \
        -f mov \
        "${final_output}"
    else
        # Process local file
        ffmpeg \
        -hide_banner \
        -stats \
        -i "${input}" \
        -c:v dnxhd \
        -b:v 290M \
        -pix_fmt yuv422p \
        -c:a pcm_s16le \
        -f mov \
        "${final_output}"
    fi
}

# Run the function
dnx

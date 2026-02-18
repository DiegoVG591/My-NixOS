#!/usr/bin/env bash

usage()
{
[ -z "${1}" ] || echo "! ${1}"
echo "\
# convert video to dnxhd and audio to pcm (60fps optimized)

$(basename "$0") -i [infile|url] -o outfile.mov [EXTRA_FLAGS]
-i infile.(mp4|mkv|mov|m4v|webm) or YouTube URL
-o outfile.mov :optional argument
Extra flags (like --vn) are passed to yt-dlp/ffmpeg"
exit 2
}

# Variable defaults
input=""
outfile=""

# Use a loop to grab -i and -o, but stop before extra flags
while [[ $# -gt 0 ]]; do
  case $1 in
    -i) input="$2"; shift 2 ;;
    -o) outfile="$2"; shift 2 ;;
    -h) usage ;;
    *) break ;; # Stop parsing at the first extra flag
  esac
done

[ -n "$input" ] || usage "Input is required"

#===============================================================================
# Variables & Logic Path
#===============================================================================
if [[ "$input" =~ ^http ]]; then
    infile_name="youtube-vod"
    is_url=true
else
    [ -f "${input}" ] || usage "${input} not a file or valid URL"
    infile_nopath="${input##*/}"
    infile_name="${infile_nopath%.*}"
    is_url=false
fi

outfile_default="${infile_name}-dnxhd.mov"
final_output="${outfile:=${outfile_default}}"

#===============================================================================
# dnx function: Now passes "$@" to tools
#===============================================================================
dnx () {
    if [ "$is_url" = true ]; then
        # Native Zen support now that you updated NixOS
        yt-dlp --cookies-from-browser brave -f 'bestvideo+bestaudio/best' "$input" -o - | \
        ffmpeg \
        -hide_banner \
        -stats \
        -i pipe:0 \
        -c:v dnxhd \
        -b:v 290M \
        -pix_fmt yuv422p \
        -c:a pcm_s16le \
        -f mov \
        "$@" \
        "${final_output}"
    else
        ffmpeg \
        -hide_banner \
        -stats \
        -i "${input}" \
        -c:v dnxhd \
        -b:v 290M \
        -pix_fmt yuv422p \
        -c:a pcm_s16le \
        -f mov \
        "$@" \
        "${final_output}"
    fi
}

# Run with remaining arguments (like --vn)
dnx "$@"

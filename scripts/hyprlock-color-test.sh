#!/usr/bin/env bash
# Cycles color combos on the hyprlock equalizer labels (top / text / bottom)
# Targets labels.conf, locating color lines dynamically — safe against edits.

WHITE="rgba(227, 217, 197, 1)"
PINK="rgba(255, 196, 234, 0.75)"
PURPLE="rgba(68, 0, 112, 1)"

LABELS_CONF="$HOME/.config/hypr/scripts/hyprlock-eq/labels.conf"

combinations=(
    "blanco/blanco/blanco:$WHITE:$WHITE:$WHITE"
    "rosa/rosa/rosa:$PINK:$PINK:$PINK"
    "morado/morado/morado:$PURPLE:$PURPLE:$PURPLE"
    "rosa/rosa/morado:$PINK:$PINK:$PURPLE"
    "rosa/morado/rosa:$PINK:$PURPLE:$PINK"
    "morado/morado/rosa:$PURPLE:$PURPLE:$PINK"
    "morado/rosa/morado:$PURPLE:$PINK:$PURPLE"
    "blanco/rosa/blanco:$WHITE:$PINK:$WHITE"
    "blanco/morado/blanco:$WHITE:$PURPLE:$WHITE"
    "blanco/rosa/rosa:$WHITE:$PINK:$PINK"
    "blanco/morado/morado:$WHITE:$PURPLE:$PURPLE"
    "rosa/morado/blanco:$PINK:$PURPLE:$WHITE"
    "morado/rosa/blanco:$PURPLE:$PINK:$WHITE"
    "blanco/rosa/morado:$WHITE:$PINK:$PURPLE"
    "blanco/morado/rosa:$WHITE:$PURPLE:$PINK"
)
total=${#combinations[@]}

apply_colors() {
    local top="$1" mid="$2" bot="$3"
    # Find the line numbers of the three 'color =' lines (order: eq, nowplaying, eq_inverted)
    mapfile -t color_lines < <(grep -n '^\s*color = ' "$LABELS_CONF" | cut -d: -f1)
    if (( ${#color_lines[@]} != 3 )); then
        echo "❌ Expected 3 'color =' lines in $LABELS_CONF, found ${#color_lines[@]}. Aborting."
        exit 1
    fi
    sed -i "${color_lines[0]}s|color = .*|color = $top # top|"    "$LABELS_CONF"
    sed -i "${color_lines[1]}s|color = .*|color = $mid # text|"   "$LABELS_CONF"
    sed -i "${color_lines[2]}s|color = .*|color = $bot # bottom|" "$LABELS_CONF"
}

for i in "${!combinations[@]}"; do
    IFS=':' read -r name top mid bot <<< "${combinations[$i]}"
    apply_colors "$top" "$mid" "$bot"
    echo ""
    echo "[$((i+1))/$total] $([ $i -gt 0 ] && echo '✅ anterior: '${combinations[$((i-1))]%%:*}'')"
    echo "👁  ahora: $name (arriba / texto / abajo)"
    hyprlock
done
echo ""
echo "✅ Todas las combinaciones probadas!"

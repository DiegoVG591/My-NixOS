#!/usr/bin/env bash

WHITE="rgba(227, 217, 197, 1)"
PINK="rgba(255, 196, 234, 0.75)"
PURPLE="rgba(68, 0, 112, 1)"

HYPRLOCK_CONF="$HOME/.config/hypr/hyprlock.conf"

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
    local top="$1"
    local mid="$2"
    local bot="$3"

    # This assumes the order in hyprlock.conf is: EQUALIZER, NOWPLAYING, EQUALIZER_INVERTED
    sed -i "159s/.*/     color = $top/" "$HYPRLOCK_CONF"
    sed -i "170s/.*/     color = $mid/" "$HYPRLOCK_CONF"  
    sed -i "181s/.*/     color = $bot/" "$HYPRLOCK_CONF"
    
    
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

#!/bin/bash
# Swordjin Nightly Dev Pipeline
# Runs at 03:00 CEST — builds, exports, generates next chapter template

set -euo pipefail

PROJECT_DIR="/home/kirk/.picoclaw/workspace/Swordjin_Godot"
BUILD_DIR="$PROJECT_DIR/builds"
LOG_DIR="$PROJECT_DIR/logs"
PROGRESS_FILE="$PROJECT_DIR/.dev_progress"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p "$BUILD_DIR" "$LOG_DIR"
LOG="$LOG_DIR/nightly_$DATE.log"

exec > >(tee -a "$LOG") 2>&1

echo "=== Swordjin Nightly Dev — $DATE ==="
echo "Working in: $PROJECT_DIR"

# ─── Read Progress ───
CURRENT_ACT=1
CURRENT_CHAPTER=1
CURRENT_PHASE="foundation"  # foundation | content | assets | polish | export
if [ -f "$PROGRESS_FILE" ]; then
    source "$PROGRESS_FILE"
fi

echo "Current state: Act $CURRENT_ACT, Chapter $CURRENT_CHAPTER, Phase: $CURRENT_PHASE"

# ─── Phase-based Work ───
case "$CURRENT_PHASE" in
    foundation)
        echo "--- Phase: Foundation ---"
        # Ensure PWA files exist
        if [ ! -f "$PROJECT_DIR/export_presets.cfg" ]; then
            echo "Creating HTML5 export preset..."
            cat > "$PROJECT_DIR/export_presets.cfg" << 'EOF'
preset.0.name="HTML5"
preset.0.platform="Web"
preset.0.runnable=true
preset.0.dedicated_server=false
preset.0.export_filter="all_resources"
preset.0.include_filter=""
preset.0.exclude_filter=""
preset.0.export_path="builds/web/index.html"
preset.0.encryption_include_filters=""
preset.0.encryption_exclude_filters=""
preset.0.encrypt_pck=false
preset.0.encrypt_directory=false
preset.0.script_export_mode=2
preset.0.script_encryption_key=""

preset.0.options.custom_template/debug=""
preset.0.options.custom_template/release=""
preset.0.options.variant/extensions_support=false
preset.0.options.variant/thread_support=false
preset.0.options.vram_texture_compression/for_desktop=true
preset.0.options.vram_texture_compression/for_mobile=false
preset.0.options.html/export_icon=true
preset.0.options.html/custom_html_shell=""
preset.0.options.html/head_include=""
preset.0.options.html/canvas_resize_policy=2
preset.0.options.html/focus_canvas_on_start=true
preset.0.options.html/experimental_virtual_keyboard=false
preset.0.options.progressive_web_app/enabled=true
preset.0.options.progressive_web_app/offline_page=""
preset.0.options.progressive_web_app/display=1
preset.0.options.progressive_web_app/orientation=0
preset.0.options.progressive_web_app/icon_144x144=""
preset.0.options.progressive_web_app/icon_180x180=""
preset.0.options.progressive_web_app/icon_512x512=""
preset.0.options.progressive_web_app/background_color=Color(0, 0, 0, 1)
EOF
        fi
        
        # Ensure PWA manifest and service worker
        mkdir -p "$PROJECT_DIR/builds/web"
        if [ ! -f "$PROJECT_DIR/builds/web/manifest.json" ]; then
            cat > "$PROJECT_DIR/builds/web/manifest.json" << 'EOF'
{
  "name": "Swordjin - Fantasy Action RPG",
  "short_name": "Swordjin",
  "start_url": ".",
  "display": "standalone",
  "background_color": "#0d1117",
  "theme_color": "#1a1a2e",
  "orientation": "landscape",
  "icons": [
    {
      "src": "icon_144.png",
      "sizes": "144x144",
      "type": "image/png"
    },
    {
      "src": "icon_512.png",
      "sizes": "512x512",
      "type": "image/png"
    }
  ]
}
EOF
        fi
        
        # Create chapter directory structure
        for act in {1..10}; do
            mkdir -p "$PROJECT_DIR/chapters/act$(printf %02d $act)"
        done
        
        # Advance to next phase after foundation is set
        CURRENT_PHASE="content"
        echo "Foundation complete. Advancing to content phase."
        ;;
        
    content)
        echo "--- Phase: Content Generation ---"
        # Generate next chapter template
        ACT_DIR="$PROJECT_DIR/chapters/act$(printf %02d $CURRENT_ACT)"
        CHAPTER_FILE="$ACT_DIR/chapter$(printf %03d $CURRENT_CHAPTER).md"
        
        if [ ! -f "$CHAPTER_FILE" ]; then
            # Create chapter template based on manhwa conversion rules
            cat > "$CHAPTER_FILE" << EOF
# Swordjin — Act $CURRENT_ACT, Chapter $CURRENT_CHAPTER

## Source
- Manhwa Chapter: [TODO: Map to specific manhwa chapter]
- Story Arc: [Arc name from manhwa]

## Game Adaptation
### Scene
- Location: [TODO]
- Time: [TODO]
- Weather/Lighting: [TODO]

### Characters Present
- [ ] Jin (Player)
- [ ] [Enemy/NPC names]

### Mechanics Introduced
- [ ] Any new combat mechanics
- [ ] New enemy types
- [ ] New abilities unlocked

### Level Design
- Layout: [TODO — ASCII or description]
- Enemies: [Count and types]
- Objectives: [Kill all / Survive / Escort / Boss]
- Reward: [XP, item, skill unlock]

### Dialogue/Story Beats
1. [Opening scene description]
2. [Combat trigger]
3. [Resolution / cliffhanger]

### Development Status
- [ ] Story scripted
- [ ] Level designed
- [ ] Enemies placed
- [ ] Dialogue written
- [ ] Tested

## Notes
[Freeform notes from manhwa → game translation]
EOF
            echo "Created chapter template: $CHAPTER_FILE"
        fi
        
        # Advance chapter counter
        CURRENT_CHAPTER=$((CURRENT_CHAPTER + 1))
        if [ "$CURRENT_CHAPTER" -gt 20 ]; then
            CURRENT_CHAPTER=1
            CURRENT_ACT=$((CURRENT_ACT + 1))
            if [ "$CURRENT_ACT" -gt 10 ]; then
                CURRENT_PHASE="assets"
                echo "All chapter templates created! Moving to assets phase."
            fi
        fi
        ;;
        
    assets)
        echo "--- Phase: Asset Pipeline ---"
        # Check for missing placeholder assets and create lists
        find "$PROJECT_DIR" -name "*.tscn" -exec grep -l "placeholder\|TODO_asset" {} \; > "$LOG_DIR/missing_assets_$DATE.txt" 2>/dev/null || true
        echo "Asset audit logged."
        CURRENT_PHASE="export"
        ;;
        
    export)
        echo "--- Phase: Build & Export ---"
        # Attempt HTML5 export if Godot is available
        if command -v godot &> /dev/null; then
            echo "Running Godot HTML5 export..."
            timeout 120 godot --headless --path "$PROJECT_DIR" --export-release "HTML5" "$BUILD_DIR/web/index.html" 2>&1 || echo "Export failed or timed out — will retry tomorrow"
            
            # Copy PWA files into build
            cp "$PROJECT_DIR/builds/web/manifest.json" "$BUILD_DIR/web/" 2>/dev/null || true
            
            # Create simple service worker
            cat > "$BUILD_DIR/web/sw.js" << 'EOF'
const CACHE_NAME = 'swordjin-v1';
const urlsToCache = [
  '.',
  './index.html',
  './Swordjin_Godot.pck',
  './Swordjin_Godot.wasm',
  './Swordjin_Godot.js',
  './Swordjin_Godot.side.wasm',
  './Swordjin_Godot.worker.js'
];

self.addEventListener('install', event => {
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then(cache => cache.addAll(urlsToCache))
  );
});

self.addEventListener('fetch', event => {
  event.respondWith(
    caches.match(event.request)
      .then(response => response || fetch(event.request))
  );
});
EOF
            echo "PWA service worker created."
        else
            echo "Godot not available — skipping export"
        fi
        CURRENT_PHASE="foundation"
        echo "Build cycle complete. Looping back to foundation checks."
        ;;
esac

# ─── Save Progress ───
cat > "$PROGRESS_FILE" << EOF
CURRENT_ACT=$CURRENT_ACT
CURRENT_CHAPTER=$CURRENT_CHAPTER
CURRENT_PHASE=$CURRENT_PHASE
LAST_RUN=$DATE
EOF

# ─── Git Commit (if repo exists) ───
if [ -d "$PROJECT_DIR/.git" ]; then
    cd "$PROJECT_DIR"
    git add -A 2>/dev/null || true
    git commit -m "[nightly] $DATE — $CURRENT_PHASE (Act $CURRENT_ACT, Ch $CURRENT_CHAPTER)" 2>/dev/null || echo "No changes to commit"
fi

echo "=== Nightly dev complete. Next: Act $CURRENT_ACT, Chapter $CURRENT_CHAPTER, Phase: $CURRENT_PHASE ==="

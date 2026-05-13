#!/usr/bin/env python3
"""Safely migrate Polygon2D to Sprite2D in Godot scenes with texture support."""
import sys, re, os

def migrate_scene(path, subdir, name, sprite_name):
    """
    Replace Polygon2D node with Sprite2D node + texture reference.
    Assumes script references $Polygon2D -> $Sprite2D needs update too.
    """
    with open(path, 'r') as f:
        content = f.read()
    
    # Check if already migrated
    if 'Sprite2D' in content and f'{name}.png' in content:
        print(f"SKIP (already migrated): {path}")
        return
    
    # Check if Polygon2D exists
    if 'Polygon2D' not in content:
        print(f"SKIP (no Polygon2D found): {path}")
        return
    
    # Build the texture ext_resource path
    texture_path = f"res://assets/art/{subdir}/{name}.png"
    
    # Find and replace Polygon2D node block
    # Match: [node name="Polygon2D" type="Polygon2D" parent="."]
    # up to next [node or [connection
    pattern = r'\[node name="Polygon2D" type="Polygon2D" parent="\."\]\n.*?(?=\n\[node |\n\[connection|\Z)'
    
    replacement = f'''[node name="Sprite2D" type="Sprite2D" parent="."]
texture = ExtResource("3_sprite")
'''
    
    new_content = re.sub(pattern, replacement, content, flags=re.DOTALL)
    
    if new_content == content:
        # Fallback simple replace for edge cases
        new_content = content.replace(
            '[node name="Polygon2D" type="Polygon2D" parent="."]',
            '[node name="Sprite2D" type="Sprite2D" parent="."]\ntexture = ExtResource("3_sprite")'
        )
        # Remove polygon line
        new_content = re.sub(r'\npolygon = PackedVector2Array\([^)]+\)', '', new_content)
    
    # Add ext_resource for texture after last ext_resource
    if '3_sprite' not in new_content:
        ext_line = f'[ext_resource type="Texture2D" path="{texture_path}" id="3_sprite"]\n'
        # Insert after last ext_resource line
        last_ext = new_content.rfind('[ext_resource')
        if last_ext >= 0:
            insert_after = new_content.find('\n', last_ext) + 1
            new_content = new_content[:insert_after] + ext_line + new_content[insert_after:]
    
    # Save
    with open(path, 'w') as f:
        f.write(new_content)
    print(f"MIGRATED: {path} -> {name}.png")

if __name__ == "__main__":
    base = "/home/kirk/.picoclaw/workspace/Swordjin_Godot"
    
    # Player
    migrate_scene(f"{base}/scenes/player.tscn", "characters", "player_idle", "player_idle")
    
    print("Scene migration done. Remember to update script references $Polygon2D -> $Sprite2D")

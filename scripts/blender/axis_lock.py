import bpy

bl_info = {
    "name": "Toggle Axis Lock (X/Y/Z)",
    "author": "Gemini",
    "version": (1, 6),
    "blender": (4, 0, 0),
    "location": "View3D > Keybindings",
    "description": "Transforms selection starting with 0 locks. Toggling Alt+X/Y/Z activates the system. Alt+C clears all locks.",
    "category": "3D View",
}

# Global runtime variables to track state
AXIS_LOCK_ACTIVE = False
LOCKED_AXES = set()

def clear_all_locks():
    global AXIS_LOCK_ACTIVE, LOCKED_AXES
    LOCKED_AXES.clear()
    AXIS_LOCK_ACTIVE = False
    return "All locks cleared. Global Axis Lock: DISABLED"

def toggle_single_axis(axis):
    global AXIS_LOCK_ACTIVE, LOCKED_AXES
    
    # Guard clause: Add axis if it is not present and exit immediately
    if axis not in LOCKED_AXES:
        LOCKED_AXES.add(axis)
        AXIS_LOCK_ACTIVE = True
        return f"Added {axis} -> Global Axis Lock ACTIVE: [{', '.join(sorted(list(LOCKED_AXES)))}]"
        
    # Standard flow: Handle removal safely
    LOCKED_AXES.remove(axis)
    
    # Guard clause: If removal emptied the set, disable tracking
    if not LOCKED_AXES:
        AXIS_LOCK_ACTIVE = False
        return "All locks cleared. Global Axis Lock: DISABLED"
        
    return f"Removed {axis} -> Global Axis Lock ACTIVE: [{', '.join(sorted(list(LOCKED_AXES)))}]"

def get_transformation_constraints():
    global AXIS_LOCK_ACTIVE, LOCKED_AXES
    # Guard clause: Return default free transformation if system is inactive
    if not AXIS_LOCK_ACTIVE or not LOCKED_AXES:
        return (False, False, False)
        
    return (
        "X" not in LOCKED_AXES, 
        "Y" not in LOCKED_AXES, 
        "Z" not in LOCKED_AXES
    )

def execute_translation(context, constraints):
    bpy.ops.transform.translate(
        'INVOKE_DEFAULT',
        constraint_axis=constraints,
        orient_type='GLOBAL',
        use_proportional_edit=context.scene.tool_settings.use_proportional_edit,
        proportional_edit_falloff=context.scene.tool_settings.proportional_edit_falloff,
        proportional_size=context.scene.tool_settings.proportional_size
    )

def execute_resize(context, constraints):
    bpy.ops.transform.resize(
        'INVOKE_DEFAULT',
        constraint_axis=constraints,
        orient_type='GLOBAL',
        use_proportional_edit=context.scene.tool_settings.use_proportional_edit,
        proportional_edit_falloff=context.scene.tool_settings.proportional_edit_falloff,
        proportional_size=context.scene.tool_settings.proportional_size
    )

class VIEW3D_OT_axis_lock_modify(bpy.types.Operator):
    """Toggle a specific axis or clear the entire lock list"""
    bl_idname = "view3d.axis_lock_modify"
    bl_label = "Modify Locked Axis List"
    bl_options = {'REGISTER'}

    target_axis: bpy.props.StringProperty(default="Y")

    def execute(self, context):
        # Guard clause: bypass logic if target is CLEAR
        if self.target_axis == "CLEAR":
            self.report({'INFO'}, clear_all_locks())
            return {'FINISHED'}
            
        msg = toggle_single_axis(self.target_axis.upper())
        self.report({'INFO'}, msg)
        return {'FINISHED'}

class VIEW3D_OT_transform_locked(bpy.types.Operator):
    """Translate or Scale respecting the global custom axis locks"""
    bl_idname = "view3d.transform_locked"
    bl_label = "Transform Locked"
    bl_options = {'REGISTER', 'UNDO'}

    mode: bpy.props.StringProperty(default="TRANSLATION")

    def execute(self, context):
        constraints = get_transformation_constraints()
        
        # Guard clause: redirect to translation handler
        if self.mode == "TRANSLATION":
            execute_translation(context, constraints)
            return {'FINISHED'}
            
        # Guard clause: redirect to resize handler
        if self.mode == "RESIZE":
            execute_resize(context, constraints)
            return {'FINISHED'}
            
        return {'FINISHED'}

# Keymap Registry Boilerplate (Flattened loops)
addon_keymaps = []

def register_keybinds(km):
    kmi_g = km.keymap_items.new(VIEW3D_OT_transform_locked.bl_idname, type='G', value='PRESS')
    kmi_g.properties.mode = "TRANSLATION"
    
    kmi_s = km.keymap_items.new(VIEW3D_OT_transform_locked.bl_idname, type='S', value='PRESS')
    kmi_s.properties.mode = "RESIZE"
    
    kmi_x = km.keymap_items.new(VIEW3D_OT_axis_lock_modify.bl_idname, type='X', value='PRESS', alt=True)
    kmi_x.properties.target_axis = "X"
    
    kmi_y = km.keymap_items.new(VIEW3D_OT_axis_lock_modify.bl_idname, type='Y', value='PRESS', alt=True)
    kmi_y.properties.target_axis = "Y"
    
    kmi_z = km.keymap_items.new(VIEW3D_OT_axis_lock_modify.bl_idname, type='Z', value='PRESS', alt=True)
    kmi_z.properties.target_axis = "Z"
    
    kmi_clear = km.keymap_items.new(VIEW3D_OT_axis_lock_modify.bl_idname, type='C', value='PRESS', alt=True)
    kmi_clear.properties.target_axis = "CLEAR"
    
    addon_keymaps.extend([
        (km, kmi_g), (km, kmi_s), (km, kmi_x), 
        (km, kmi_y), (km, kmi_z), (km, kmi_clear)
    ])

def register():
    bpy.utils.register_class(VIEW3D_OT_axis_lock_modify)
    bpy.utils.register_class(VIEW3D_OT_transform_locked)
    
    wm = bpy.context.window_manager
    kc = wm.keyconfigs.addon
    
    # Guard clause: prevent setup if keyconfig is missing
    if not kc:
        return
        
    km = kc.keymaps.new(name='Mesh', space_type='EMPTY')
    register_keybinds(km)

def unregister():
    for km, kmi in addon_keymaps:
        km.keymap_items.remove(kmi)
    addon_keymaps.clear()
    
    bpy.utils.unregister_class(VIEW3D_OT_transform_locked)
    bpy.utils.unregister_class(VIEW3D_OT_axis_lock_modify)

if __name__ == "__main__":
    register()

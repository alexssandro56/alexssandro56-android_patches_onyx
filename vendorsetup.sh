# Apply the patches in vendor/onyx-extras/patches/<project path>/ to the
# matching projects. repo sync drops them, so this runs on every envsetup
# and skips patches that are already applied.
onyx_extras_apply_patches() {
    local top=$(gettop)
    local base="$top/vendor/onyx-extras/patches"
    local dir patch project
    for dir in $(find "$base" -name '*.patch' -exec dirname {} \; | sort -u); do
        project=${dir#$base/}
        if [ ! -d "$top/$project" ]; then
            echo "onyx-extras: $project is missing, skipping its patches"
            continue
        fi
        for patch in "$dir"/*.patch; do
            if git -C "$top/$project" apply --reverse --check "$patch" >/dev/null 2>&1; then
                continue
            fi
            if git -C "$top/$project" -c user.name=onyx -c user.email=onyx@localhost \
                    am -q --3way "$patch"; then
                echo "onyx-extras: applied $(basename "$patch") to $project"
            else
                git -C "$top/$project" am --abort >/dev/null 2>&1
                echo "onyx-extras: failed to apply $(basename "$patch") to $project"
            fi
        done
    done
}
onyx_extras_apply_patches

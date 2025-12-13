# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased

### Added

-   Added optional `skip_result_coordinate_frames` parameter to `solve_animation` to bypass CFrame caching when not needed.

### Fixed

-   Fixed quanternion interpolation not taking the shortest path
-   Fixed edge case for `keyframe_holes` where it would not fill from the last keyframe for a limb, to the last keyframe of the animation

## 0.2.0

### Added

-   Constant Easing
-   Animations with Keyframe holes
-   Added more documentations

### Changed

-   Use native methods, math.lerp and vector.lerp
-   Keyframe nodes with .Weight = 0 is no longer animated
-   Exposed `crunchyroll.create_rig(...).limb_transforms`, `crunchyroll.create_rig(...).limbs` and `crunchyroll.create_rig(...).limb_name_to_index`

### Fixed

-   Fixed binary search between keyframes to correctly read the first and last frames

## 0.1.1

### Changed

-   Significant performance improvements:
    -   Switched to quanternion normalized interpolation over matrix linear interpolation
    -   Use binary search between keyframes
    -   Many misc. improvements

### Fixed

-   Fixed 0-length animations not working
-   Fix nan case with fade time being set to 0

## 0.1.0

-   Release

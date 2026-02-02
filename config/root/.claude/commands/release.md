# /release

Manage software releases with changelog and version updates.

## Description

Updates CHANGELOG.md with changes since the last version, checks README.md for necessary updates, and increases version number appropriately based on change scope.

## Usage

```
/release
```

## Process

1. **Analyze changes since last release**
   - Review git history since last version tag
   - Categorize changes by type
   - Determine version bump scope

2. **Update CHANGELOG.md**
   - Add new version section
   - List all changes categorized by:
     - Added
     - Changed
     - Deprecated
     - Removed
     - Fixed
     - Security

3. **Version bump decision**
   - **Patch** (x.x.1): Bug fixes, small changes
   - **Minor** (x.1.0): New features, backwards compatible
   - **Major** (1.0.0): Breaking changes

4. **Update version references**
   - package.json / setup.py / etc.
   - README.md version badges
   - Documentation references

5. **Final checks**
   - Ensure all tests pass
   - Verify documentation is current
   - Check for breaking changes

## Example CHANGELOG Entry

```markdown
## [1.2.0] - 2024-01-15

### Added

- New feature X for improved performance
- Support for Y configuration

### Changed

- Updated dependency Z to version 2.0

### Fixed

- Bug in feature A that caused B
```

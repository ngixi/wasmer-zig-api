# Section 2.3 Instance Improvements

## Overview

This document details the planned implementation of Section 2.3 from the wasmer-zig-api roadmap. Section 2.3 focuses on improving the Instance type with better export access methods, import validation, and enhanced error reporting.

## Current Status

**Status**: ❌ **NOT IMPLEMENTED** - Section 2.3 is currently pending implementation.

## What Should Be Implemented in Section 2.3

Section 2.3 aims to complete the Instance API with advanced functionality:

- [ ] Complete export access methods
- [ ] Add import validation
- [ ] Improve error reporting

## Planned Export Access Methods

### Enhanced Export Retrieval

Current implementation only provides basic `getExports()` method. Section 2.3 should add:

```zig
// Planned API (not yet implemented)
pub const Instance = opaque {
    // ... existing methods ...

    /// Get a specific export by name
    pub fn getExport(self: *Instance, name: []const u8) ?*Extern {
        // TODO: Implement export lookup by name
    }

    /// Get all exports as a map/dictionary
    pub fn getExportsMap(self: *Instance, allocator: Allocator) !std.StringHashMap(*Extern) {
        // TODO: Implement export enumeration with names
    }

    /// Check if an export exists
    pub fn hasExport(self: *Instance, name: []const u8) bool {
        // TODO: Implement export existence check
    }

    /// Get export names
    pub fn getExportNames(self: *Instance, allocator: Allocator) ![][]u8 {
        // TODO: Implement export name enumeration
    }
};
```

### Export Type Information

```zig
/// Get the type of a specific export
pub fn getExportType(self: *Instance, name: []const u8) ?*ExternType {
    // TODO: Implement export type retrieval
}

/// Get detailed export information
pub fn getExportInfo(self: *Instance, name: []const u8) ?ExportInfo {
    // TODO: Implement detailed export metadata
}

pub const ExportInfo = struct {
    name: []u8,
    extern_type: *ExternType,
    extern: *Extern,
};
```

## Import Validation

### Pre-Instantiation Validation

```zig
/// Validate that all required imports are provided
pub fn validateImports(module: *const Module, imports: ?*const ExternVec) !void {
    // TODO: Check that all module imports are satisfied
    // TODO: Validate import types match module requirements
    // TODO: Provide detailed error messages for missing/invalid imports
}

/// Get list of required imports
pub fn getRequiredImports(self: *const Module, allocator: Allocator) ![]ImportInfo {
    // TODO: Return detailed information about required imports
}

pub const ImportInfo = struct {
    module_name: []u8,
    name: []u8,
    extern_type: *ExternType,
};
```

### Import Resolution Helpers

```zig
/// Create import resolver from named externs
pub fn createImportResolver(named_externs: *const NamedExternVec) ImportResolver {
    // TODO: Implement import resolution helper
}

/// Resolve imports for instantiation
pub fn resolveImports(self: *const Module, resolver: *ImportResolver) !ExternVec {
    // TODO: Use resolver to create import vector
}

pub const ImportResolver = struct {
    named_externs: *const NamedExternVec,

    pub fn resolve(self: ImportResolver, module_name: []const u8, name: []const u8) ?*Extern {
        // TODO: Find matching extern by module and name
    }
};
```

## Enhanced Error Reporting

### Detailed Instantiation Errors

```zig
/// Enhanced instance creation with detailed error reporting
pub fn initWithDetailedErrors(store: *Store, module: *const Module, imports: ?*const ExternVec) !*Instance {
    // TODO: Provide more detailed error information
    // TODO: Include information about which import failed
    // TODO: Suggest fixes for common issues
}

pub const InstantiationError = error{
    MissingImport,      // Specific import not provided
    TypeMismatch,       // Import type doesn't match requirement
    InvalidImport,      // Import is malformed
    LinkError,          // Linking failed
    // ... with detailed context
};
```

### Error Context Information

```zig
pub const DetailedError = struct {
    error_type: InstantiationError,
    module_name: ?[]u8,      // Which module the error relates to
    import_name: ?[]u8,      // Which import caused the error
    expected_type: ?*ExternType,  // What type was expected
    provided_type: ?*ExternType,  // What type was provided
    suggestion: ?[]u8,       // Suggested fix
};
```

## Instance Introspection

### Runtime Information

```zig
/// Get runtime information about the instance
pub fn getRuntimeInfo(self: *const Instance) RuntimeInfo {
    // TODO: Return information about the instance's runtime state
}

pub const RuntimeInfo = struct {
    memory_usage: usize,     // Current memory usage
    table_size: u32,         // Current table size
    global_count: u32,       // Number of globals
    function_count: u32,     // Number of functions
};
```

### Module Information

```zig
/// Get information about the module this instance was created from
pub fn getModuleInfo(self: *const Instance) ModuleInfo {
    // TODO: Return module metadata
}

pub const ModuleInfo = struct {
    name: ?[]u8,             // Module name if available
    version: ?[]u8,          // Module version if available
    source_language: ?[]u8,  // Source language (WAT, Rust, etc.)
};
```

## Usage Examples (Planned)

### Enhanced Export Access

```zig
// Create instance
const instance = try Instance.init(&store, &module, imports);
defer instance.deinit();

// Get specific export by name
if (instance.getExport("main")) |main_func| {
    // Use the main function
} else {
    return error.ExportNotFound;
}

// Get all exports as a map
var exports = try instance.getExportsMap(allocator);
defer {
    var it = exports.iterator();
    while (it.next()) |entry| {
        allocator.free(entry.key_ptr.*);
    }
    exports.deinit();
}

// Use exports
if (exports.get("memory")) |memory_extern| {
    const memory = Extern.asMemory(memory_extern);
    // Use memory
}
```

### Import Validation

```zig
// Validate imports before instantiation
try Instance.validateImports(&module, imports);

// Get detailed import requirements
const required_imports = try module.getRequiredImports(allocator);
defer {
    for (required_imports) |import| {
        allocator.free(import.module_name);
        allocator.free(import.name);
    }
    allocator.free(required_imports);
}

// Check if all requirements are met
for (required_imports) |req| {
    if (!hasImport(imports, req.module_name, req.name)) {
        std.debug.print("Missing import: {s}:{s}\n", .{req.module_name, req.name});
        return error.MissingImport;
    }
}
```

### Detailed Error Reporting

```zig
// Attempt instantiation with detailed errors
const instance = Instance.initWithDetailedErrors(&store, &module, imports) catch |err| {
    switch (err) {
        InstantiationError.MissingImport => {
            std.debug.print("Missing import: {s}:{s}\n",
                .{err.module_name orelse "unknown", err.import_name orelse "unknown"});
        },
        InstantiationError.TypeMismatch => {
            std.debug.print("Type mismatch for import {s}:{s}\n",
                .{err.module_name orelse "unknown", err.import_name orelse "unknown"});
            if (err.suggestion) |suggestion| {
                std.debug.print("Suggestion: {s}\n", .{suggestion});
            }
        },
        else => return err,
    }
    return err;
};
```

## Implementation Strategy

### Phase 1: Core Export Access
1. Implement `getExport()` method
2. Add `hasExport()` and `getExportNames()` methods
3. Create `ExportInfo` structure

### Phase 2: Import Validation
1. Implement `validateImports()` function
2. Add `getRequiredImports()` method
3. Create `ImportInfo` and `ImportResolver` types

### Phase 3: Enhanced Error Reporting
1. Implement `initWithDetailedErrors()` method
2. Add `DetailedError` and `InstantiationError` types
3. Improve error context and suggestions

### Phase 4: Introspection Features
1. Add `getRuntimeInfo()` method
2. Implement `getModuleInfo()` method
3. Create supporting info structures

## Dependencies

### Required from Previous Sections
- **Section 1.1**: Core types and extern declarations
- **Section 1.2**: Error handling patterns
- **Section 1.3**: RAII memory management
- **Section 2.1**: Module name operations (for module info)

### C API Requirements
- Export enumeration functions
- Import introspection capabilities
- Enhanced error reporting in C API
- Runtime information queries

## Testing Strategy

### Unit Tests
- Export access method correctness
- Import validation accuracy
- Error reporting completeness
- Memory safety in all operations

### Integration Tests
- Full instance lifecycle with validation
- Error recovery and reporting
- Performance impact assessment

### Example Code
```zig
// Comprehensive instance usage example
const instance = try Instance.initWithDetailedErrors(&store, &module, imports);
defer instance.deinit();

// Verify exports
try std.testing.expect(instance.hasExport("memory"));
try std.testing.expect(instance.hasExport("_start"));

// Get runtime information
const info = instance.getRuntimeInfo();
std.debug.print("Memory usage: {} bytes\n", .{info.memory_usage});
std.debug.print("Table size: {}\n", .{info.table_size});
```

## Future Extensions

Section 2.3 enables advanced instance management features:

- **Hot reloading**: Instance replacement with state preservation
- **Debugging support**: Enhanced introspection for debuggers
- **Profiling**: Runtime performance information
- **Serialization**: Instance state capture and restoration

## Implementation Status

**Status**: ❌ **PENDING** - Instance improvements not yet implemented.

**Next Steps**:
1. Implement core export access methods
2. Add import validation functionality
3. Enhance error reporting with detailed context
4. Add runtime introspection capabilities

## Implementation Notes

- **Zig Version**: 0.15.2 (planned)
- **C API Coverage**: Requires additional extern declarations for introspection
- **Memory Safety**: Must follow RAII patterns established in Phase 1.3
- **Error Handling**: Should use error types established in Phase 1.1
- **Performance**: Introspection operations should be efficient</content>
<parameter name="filePath">v:\mannsion\ngixi\modules\wasmer-zig-api\docs\SECTION_2_3_INSTANCE_IMPROVEMENTS.md
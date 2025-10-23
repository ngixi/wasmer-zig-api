const std = @import("std");

// Core type definitions and extern declarations for Wasmer C API
// This file contains all opaque types and C function declarations
// to provide complete Zig bindings for the Wasmer runtime.

// =============================================================================
// ERROR TYPES
// =============================================================================

/// Comprehensive error set for all Wasmer operations
pub const Error = error{
    /// Configuration initialization failed
    ConfigInit,
    /// Engine initialization failed
    EngineInit,
    /// Store initialization failed
    StoreInit,
    /// Module initialization/compilation failed
    ModuleInit,
    /// Function initialization failed
    FuncInit,
    /// Instance initialization failed
    InstanceInit,
    /// Memory initialization failed
    MemoryInit,
    /// Table initialization failed
    TableInit,
    /// Global initialization failed
    GlobalInit,
    /// WASI configuration initialization failed
    WasiConfigInit,
    /// WASI environment initialization failed
    WasiEnvInit,
    /// Filesystem operation failed
    FilesystemInit,
    /// Metering initialization failed
    MeteringInit,
    /// Target initialization failed
    TargetInit,
    /// Triple initialization failed
    TripleInit,
    /// CPU features initialization failed
    CpuFeaturesInit,
    /// Features initialization failed
    FeaturesInit,
    /// Named extern operation failed
    NamedExternInit,
    /// FuncEnv initialization failed
    FuncEnvInit,
    /// Out of memory
    OutOfMemory,
    /// Invalid argument provided
    InvalidArgument,
    /// Operation not supported
    NotSupported,
    /// WASM trap occurred
    Trap,
    /// I/O operation failed
    IoError,
    /// Parsing failed (WAT, etc.)
    ParseError,
    /// Validation failed
    ValidationError,
    /// Export not found
    ExportNotFound,
    /// Import not found
    ImportNotFound,
    /// Type mismatch
    TypeMismatch,
    /// Link error
    LinkError,
    /// Runtime error
    RuntimeError,
};

// =============================================================================
// OPAQUE TYPES (matching C API)
// =============================================================================

// Core WASM types
pub const Config = opaque {};
pub const Engine = opaque {};
pub const Store = opaque {};
pub const Module = opaque {};
pub const Instance = opaque {};
pub const Func = opaque {};
pub const Memory = opaque {};
pub const Table = opaque {};
pub const Global = opaque {};
pub const Trap = opaque {};
pub const Extern = opaque {};
pub const ExternType = opaque {};

// WASI types
pub const WasiConfig = opaque {};
pub const WasiEnv = opaque {};
pub const WasiFilesystem = opaque {};

// Wasmer extension types
pub const Features = opaque {};
pub const CpuFeatures = opaque {};
pub const Metering = opaque {};
pub const Middleware = opaque {};
pub const Target = opaque {};
pub const Triple = opaque {};
pub const FuncEnv = opaque {};
pub const NamedExtern = opaque {};

// Vector types
pub const ByteVec = extern struct {
    size: usize,
    data: [*]u8,
};

pub const ValVec = extern struct {
    size: usize,
    data: [*]Value,
};

pub const ExternVec = extern struct {
    size: usize,
    data: [*]?*Extern,
};

pub const ExportTypeVec = extern struct {
    size: usize,
    data: [*]?*ExportType,
};

pub const NamedExternVec = extern struct {
    size: usize,
    data: [*]?*NamedExtern,
};

// Other supporting types
pub const NameVec = extern struct {
    size: usize,
    data: [*]const u8,
};

pub const Limits = extern struct {
    min: u32,
    max: u32,
};

pub const Value = extern struct {
    kind: Valkind,
    of: extern union {
        i32: i32,
        i64: i64,
        f32: f32,
        f64: f64,
        ref: ?*anyopaque,
    },
};

pub const Valkind = enum(u8) {
    i32 = 0,
    i64 = 1,
    f32 = 2,
    f64 = 3,
    anyref = 128,
    funcref = 129,
};

pub const ExternKind = std.wasm.ExternalKind;

// Enums
pub const WasiVersion = enum(c_int) {
    InvalidVersion = -1,
    Latest = 0,
    Snapshot0 = 1,
    Snapshot1 = 2,
    Wasix32v1 = 3,
    Wasix64v1 = 4,
};

pub const Backend = enum(c_int) {
    Universal = 0,
    // Add other backends as needed
};

pub const Compiler = enum(c_int) {
    Cranelift = 0,
    LLVM = 1,
    Singlepass = 2,
};

// =============================================================================
// EXTERN DECLARATIONS (Complete C API)
// =============================================================================

// -----------------------------------------------------------------------------
// Core WASM API
// -----------------------------------------------------------------------------

// Config
extern "c" fn wasm_config_new() ?*Config;
extern "c" fn wasm_config_delete(?*Config) void;
extern "c" fn wasm_config_push_middleware(?*Config, ?*Middleware) void;
extern "c" fn wasm_config_set_engine(?*Config, Backend) void;
extern "c" fn wasm_config_set_features(?*Config, ?*Features) void;
extern "c" fn wasm_config_set_target(?*Config, ?*Target) void;
extern "c" fn wasm_config_sys_canonicalize_nans(?*Config, bool) void;

// Engine
extern "c" fn wasm_engine_new() ?*Engine;
extern "c" fn wasm_engine_new_with_config(?*Config) ?*Engine;
extern "c" fn wasm_engine_delete(?*Engine) void;

// Store
extern "c" fn wasm_store_new(?*Engine) ?*Store;
extern "c" fn wasm_store_delete(?*Store) void;

// Module
extern "c" fn wasm_module_new(?*Store, ?*const ByteVec) ?*Module;
extern "c" fn wasm_module_delete(?*Module) void;
extern "c" fn wasm_module_validate(?*Store, ?*const ByteVec) bool;
extern "c" fn wasm_module_exports(?*const Module, ?*ExportTypeVec) void;
extern "c" fn wasm_module_imports(?*const Module, ?*ImportTypeVec) void;
extern "c" fn wasm_module_share(?*const Module) ?*Module;
extern "c" fn wasm_module_obtain(?*Store, ?*const Module) ?*Module;
extern "c" fn wasmer_module_name(?*const Module, ?*NameVec) void;
extern "c" fn wasmer_module_set_name(?*Module, ?*const NameVec) bool;

// Instance
extern "c" fn wasm_instance_new(?*Store, ?*const Module, ?*const ExternVec, ?*?*Trap) ?*Instance;
extern "c" fn wasm_instance_delete(?*Instance) void;
extern "c" fn wasm_instance_exports(?*Instance, ?*ExternVec) void;

// Func
extern "c" fn wasm_func_new(?*Store, ?*anyopaque, ?*const Callback) ?*Func;
extern "c" fn wasm_func_delete(?*Func) void;
extern "c" fn wasm_func_new_with_env(?*Store, ?*anyopaque, ?*CallbackWithEnv, ?*anyopaque, ?*anyopaque) ?*Func;
extern "c" fn wasm_func_as_extern(?*Func) ?*Extern;
extern "c" fn wasm_func_copy(?*const Func) ?*Func;
extern "c" fn wasm_func_call(?*Func, ?*const ValVec, ?*ValVec) ?*Trap;
extern "c" fn wasm_func_result_arity(?*Func) usize;
extern "c" fn wasm_func_param_arity(?*Func) usize;

// Memory
extern "c" fn wasm_memory_new(?*Store, ?*const MemoryType) ?*Memory;
extern "c" fn wasm_memory_delete(?*Memory) void;
extern "c" fn wasm_memory_copy(?*const Memory) ?*Memory;
extern "c" fn wasm_memory_same(?*const Memory, ?*const Memory) bool;
extern "c" fn wasm_memory_type(?*const Memory) ?*MemoryType;
extern "c" fn wasm_memory_data(?*Memory) [*]u8;
extern "c" fn wasm_memory_data_size(?*const Memory) usize;
extern "c" fn wasm_memory_grow(?*Memory, u32) bool;
extern "c" fn wasm_memory_size(?*const Memory) u32;

// Table
extern "c" fn wasm_table_new(?*Store, ?*const TableType, ?*anyopaque) ?*Table;
extern "c" fn wasm_table_delete(?*Table) void;
extern "c" fn wasm_table_copy(?*const Table) ?*Table;
extern "c" fn wasm_table_same(?*const Table, ?*const Table) bool;
extern "c" fn wasm_table_type(?*const Table) ?*TableType;
extern "c" fn wasm_table_get(?*Table, u32) ?*anyopaque;
extern "c" fn wasm_table_set(?*Table, u32, ?*anyopaque) bool;
extern "c" fn wasm_table_size(?*const Table) u32;
extern "c" fn wasm_table_grow(?*Table, u32, ?*anyopaque) u32;

// Global
extern "c" fn wasm_global_new(?*Store, ?*const GlobalType, ?*const Value) ?*Global;
extern "c" fn wasm_global_delete(?*Global) void;
extern "c" fn wasm_global_copy(?*const Global) ?*Global;
extern "c" fn wasm_global_same(?*const Global, ?*const Global) bool;
extern "c" fn wasm_global_type(?*const Global) ?*GlobalType;
extern "c" fn wasm_global_get(?*const Global, ?*Value) void;
extern "c" fn wasm_global_set(?*Global, ?*const Value) void;

// Trap
extern "c" fn wasm_trap_new(?*Store, ?*const ByteVec) ?*Trap;
extern "c" fn wasm_trap_delete(?*Trap) void;
extern "c" fn wasm_trap_copy(?*const Trap) ?*Trap;
extern "c" fn wasm_trap_same(?*const Trap, ?*const Trap) bool;
extern "c" fn wasm_trap_message(?*const Trap, ?*?*ByteVec) void;
extern "c" fn wasm_trap_origin(?*const Trap) ?*Frame;
extern "c" fn wasm_trap_trace(?*const Trap, ?*FrameVec) void;

// Extern
extern "c" fn wasm_extern_delete(?*Extern) void;
extern "c" fn wasm_extern_copy(?*Extern) ?*Extern;
extern "c" fn wasm_extern_same(?*const Extern, ?*const Extern) bool;
extern "c" fn wasm_extern_type(?*const Extern) ?*ExternType;
extern "c" fn wasm_extern_kind(?*const Extern) ExternKind;
extern "c" fn wasm_extern_as_func(?*Extern) ?*Func;
extern "c" fn wasm_extern_as_memory(?*Extern) ?*Memory;
extern "c" fn wasm_extern_as_table(?*Extern) ?*Table;
extern "c" fn wasm_extern_as_global(?*Extern) ?*Global;

// Types
extern "c" fn wasm_functype_new(?*ValtypeVec, ?*ValtypeVec) ?*anyopaque;
extern "c" fn wasm_functype_delete(?*anyopaque) void;
extern "c" fn wasm_memorytype_new(?*const Limits) ?*MemoryType;
extern "c" fn wasm_memorytype_delete(?*MemoryType) void;
extern "c" fn wasm_tabletype_new(?*Valtype, ?*const Limits) ?*TableType;
extern "c" fn wasm_tabletype_delete(?*TableType) void;
extern "c" fn wasm_globaltype_new(?*Valtype, Mutability) ?*GlobalType;
extern "c" fn wasm_globaltype_delete(?*GlobalType) void;
extern "c" fn wasm_valtype_new(u8) ?*Valtype;
extern "c" fn wasm_valtype_delete(?*Valtype) void;
extern "c" fn wasm_valtype_kind(?*Valtype) u8;

// Vector operations
extern "c" fn wasm_byte_vec_new(?*ByteVec, usize, ?[*]const u8) void;
extern "c" fn wasm_byte_vec_new_uninitialized(?*ByteVec, usize) void;
extern "c" fn wasm_byte_vec_delete(?*ByteVec) void;
extern "c" fn wasm_val_vec_new(?*ValVec, usize, ?[*]Value) void;
extern "c" fn wasm_val_vec_new_uninitialized(?*ValVec, usize) void;
extern "c" fn wasm_val_vec_delete(?*ValVec) void;
extern "c" fn wasm_extern_vec_new(?*ExternVec, usize, ?[*]?*Extern) void;
extern "c" fn wasm_extern_vec_new_uninitialized(?*ExternVec, usize) void;
extern "c" fn wasm_extern_vec_delete(?*ExternVec) void;

// -----------------------------------------------------------------------------
// WASI API
// -----------------------------------------------------------------------------

// WASI Config
extern "c" fn wasi_config_new(?[*]const u8) ?*WasiConfig;
extern "c" fn wasi_config_delete(?*WasiConfig) void;
extern "c" fn wasi_config_inherit_argv(?*WasiConfig) void;
extern "c" fn wasi_config_inherit_env(?*WasiConfig) void;
extern "c" fn wasi_config_inherit_stdin(?*WasiConfig) void;
extern "c" fn wasi_config_inherit_stdout(?*WasiConfig) void;
extern "c" fn wasi_config_inherit_stderr(?*WasiConfig) void;
extern "c" fn wasi_config_arg(?*WasiConfig, ?[*]const u8) void;
extern "c" fn wasi_config_env(?*WasiConfig, ?[*]const u8, ?[*]const u8) void;
extern "c" fn wasi_config_preopen_dir(?*WasiConfig, ?[*]const u8) bool;
extern "c" fn wasi_config_mapdir(?*WasiConfig, ?[*]const u8, ?[*]const u8) bool;
extern "c" fn wasi_config_capture_stdout(?*WasiConfig) void;
extern "c" fn wasi_config_capture_stderr(?*WasiConfig) void;

// WASI Env
extern "c" fn wasi_env_new(?*Store, ?*WasiConfig) ?*WasiEnv;
extern "c" fn wasi_env_delete(?*WasiEnv) void;
extern "c" fn wasi_env_initialize_instance(?*WasiEnv, ?*Store, ?*Instance) bool;
extern "c" fn wasi_env_read_stdout(?*WasiEnv, ?[*]u8, usize) isize;
extern "c" fn wasi_env_read_stderr(?*WasiEnv, ?[*]u8, usize) isize;
extern "c" fn wasi_env_set_memory(?*WasiEnv, ?*Memory) void;
extern "c" fn wasi_env_with_filesystem(?*WasiConfig, ?*Store, ?*const Module, ?*const WasiFilesystem, ?*ExternVec, ?[*]const u8) ?*WasiEnv;

// WASI Filesystem
extern "c" fn wasi_filesystem_delete(?*WasiFilesystem) void;
extern "c" fn wasi_filesystem_init_static_memory(?*const ByteVec) ?*WasiFilesystem;

// WASI Utilities
extern "c" fn wasi_get_imports(?*Store, ?*WasiEnv, ?*const Module, ?*ExternVec) bool;
extern "c" fn wasi_get_start_function(?*Instance) ?*Func;
extern "c" fn wasi_get_unordered_imports(?*WasiEnv, ?*const Module, ?*NamedExternVec) bool;
extern "c" fn wasi_get_wasi_version(?*const Module) c_int;

// -----------------------------------------------------------------------------
// Wasmer Extensions
// -----------------------------------------------------------------------------

// Features
extern "c" fn wasmer_features_new() ?*Features;
extern "c" fn wasmer_features_delete(?*Features) void;
extern "c" fn wasmer_features_bulk_memory(?*Features, bool) bool;
extern "c" fn wasmer_features_memory64(?*Features, bool) bool;
extern "c" fn wasmer_features_module_linking(?*Features, bool) bool;
extern "c" fn wasmer_features_multi_memory(?*Features, bool) bool;
extern "c" fn wasmer_features_multi_value(?*Features, bool) bool;
extern "c" fn wasmer_features_reference_types(?*Features, bool) bool;
extern "c" fn wasmer_features_simd(?*Features, bool) bool;
extern "c" fn wasmer_features_tail_call(?*Features, bool) bool;
extern "c" fn wasmer_features_threads(?*Features, bool) bool;

// CPU Features
extern "c" fn wasmer_cpu_features_new() ?*CpuFeatures;
extern "c" fn wasmer_cpu_features_delete(?*CpuFeatures) void;
extern "c" fn wasmer_cpu_features_add(?*CpuFeatures, ?*const NameVec) bool;

// Metering
extern "c" fn wasmer_metering_new(u64, ?*const MeteringCostFunction) ?*Metering;
extern "c" fn wasmer_metering_delete(?*Metering) void;
extern "c" fn wasmer_metering_as_middleware(?*Metering) ?*Middleware;
extern "c" fn wasmer_metering_get_remaining_points(?*Instance) u64;
extern "c" fn wasmer_metering_points_are_exhausted(?*Instance) bool;
extern "c" fn wasmer_metering_set_remaining_points(?*Instance, u64) void;

// Target/Triple
extern "c" fn wasmer_triple_new(?*const NameVec) ?*Triple;
extern "c" fn wasmer_triple_new_from_host() ?*Triple;
extern "c" fn wasmer_triple_delete(?*Triple) void;
extern "c" fn wasmer_target_new(?*Triple, ?*CpuFeatures) ?*Target;
extern "c" fn wasmer_target_delete(?*Target) void;

// FuncEnv
extern "c" fn wasmer_funcenv_new(?*Store, ?*anyopaque) ?*FuncEnv;
extern "c" fn wasmer_funcenv_delete(?*FuncEnv) void;

// Named Extern
extern "c" fn wasmer_named_extern_module(?*const NamedExtern) ?*const NameVec;
extern "c" fn wasmer_named_extern_name(?*const NamedExtern) ?*const NameVec;
extern "c" fn wasmer_named_extern_unwrap(?*const NamedExtern) ?*Extern;
extern "c" fn wasmer_named_extern_vec_copy(?*NamedExternVec, ?*const NamedExternVec) void;
extern "c" fn wasmer_named_extern_vec_delete(?*NamedExternVec) void;
extern "c" fn wasmer_named_extern_vec_new(?*NamedExternVec, usize, ?[*]?*NamedExtern) void;
extern "c" fn wasmer_named_extern_vec_new_empty(?*NamedExternVec) void;
extern "c" fn wasmer_named_extern_vec_new_uninitialized(?*NamedExternVec, usize) void;

// Error Handling
extern "c" fn wasmer_last_error_length() c_int;
extern "c" fn wasmer_last_error_message(?[*]u8, c_int) c_int;

// Utilities
extern "c" fn wasmer_is_backend_available(Backend) bool;
extern "c" fn wasmer_is_headless() bool;
extern "c" fn wasmer_setup_tracing(c_int, c_int) void;
extern "c" fn wasmer_version() ?[*]const u8;
extern "c" fn wasmer_version_major() u8;
extern "c" fn wasmer_version_minor() u8;
extern "c" fn wasmer_version_patch() u8;
extern "c" fn wasmer_version_pre() ?[*]const u8;
extern "c" fn wat2wasm(?*const ByteVec, ?*ByteVec) void;

// -----------------------------------------------------------------------------
// Supporting Types (not in main headers but needed)
// -----------------------------------------------------------------------------

pub const MemoryType = opaque {};
pub const TableType = opaque {};
pub const GlobalType = opaque {};
pub const Valtype = opaque {};
pub const ValtypeVec = extern struct {
    size: usize,
    data: [*]?*Valtype,
};
pub const ImportTypeVec = extern struct {
    size: usize,
    data: [*]?*ImportType,
};
pub const Frame = opaque {};
pub const FrameVec = extern struct {
    size: usize,
    data: [*]?*Frame,
};
pub const ImportType = opaque {};
pub const ExportType = opaque {};
pub const Callback = fn (?*const Valtype, ?*Valtype) callconv(.C) ?*Trap;
pub const CallbackWithEnv = fn (?*anyopaque, ?*const Valtype, ?*Valtype) callconv(.C) ?*Trap;
pub const MeteringCostFunction = fn (u32) callconv(.C) u64;
pub const Mutability = enum(u8) {
    constant = 0,
    variable = 1,
};

// =============================================================================
// ALLOCATOR INTEGRATION
// =============================================================================

/// Allocator-aware wrapper for operations that need dynamic memory
pub const Allocator = std.mem.Allocator;

/// Helper function to get the last error message from Wasmer
pub fn getLastError(allocator: Allocator) ![]u8 {
    const length = wasmer_last_error_length();
    if (length <= 0) return error.NoError;

    const buffer = try allocator.alloc(u8, @as(usize, @intCast(length)));
    errdefer allocator.free(buffer);

    const written = wasmer_last_error_message(buffer.ptr, length);
    if (written != length) return error.ErrorReadFailed;

    return buffer;
}

/// Helper to create a ByteVec from a slice
pub fn byteVecFromSlice(slice: []const u8) ByteVec {
    return .{
        .size = slice.len,
        .data = slice.ptr,
    };
}

/// Helper to create a NameVec from a string
pub fn nameVecFromString(str: []const u8) NameVec {
    return .{
        .size = str.len,
        .data = str.ptr,
    };
}

// =============================================================================
// TYPE DEFINITIONS FOR MISSING TYPES
// =============================================================================

// These types are referenced in extern declarations but not defined in the main headers
// They may be internal or defined elsewhere

// Note: Some types like MemoryType, TableType, etc. are defined as opaque above
// but may need additional extern declarations if they have associated functions

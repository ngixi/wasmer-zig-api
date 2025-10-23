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
    /// Module set name operation failed
    ModuleSetName,
    /// Module deserialization failed
    ModuleDeserialize,
    /// Function initialization failed
    FuncInit,
    /// Function type initialization failed
    FuncTypeInit,
    /// Value type initialization failed
    ValtypeInit,
    /// Instance initialization failed
    InstanceInit,
    /// Memory initialization failed
    MemoryInit,
    /// Table initialization failed
    TableInit,
    /// Table set operation failed
    TableSet,
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
pub const Config = opaque {
    /// Create a new default configuration
    pub fn init() !*Config {
        return wasm_config_new() orelse return Error.ConfigInit;
    }

    /// Clean up configuration resources
    pub fn deinit(self: *Config) void {
        wasm_config_delete(self);
    }

    /// Set the compilation backend engine
    pub fn setEngine(self: *Config, engine: Backend) void {
        wasm_config_set_engine(self, engine);
    }

    /// Set the WASM features to enable/disable
    pub fn setFeatures(self: *Config, features: *Features) void {
        wasm_config_set_features(self, features);
    }

    /// Set the compilation target
    pub fn setTarget(self: *Config, target: *Target) void {
        wasm_config_set_target(self, target);
    }

    /// Add middleware to the compilation pipeline
    pub fn pushMiddleware(self: *Config, middleware: *Middleware) void {
        wasm_config_push_middleware(self, middleware);
    }

    /// Configure NaN canonicalization for floating point operations
    pub fn setCanonicalizeNans(self: *Config, enable: bool) void {
        wasm_config_sys_canonicalize_nans(self, enable);
    }

    /// Builder pattern for easy configuration
    pub const Builder = struct {
        config: *Config,

        pub fn init() !Builder {
            return Builder{
                .config = try Config.init(),
            };
        }

        pub fn deinit(self: Builder) void {
            self.config.deinit();
        }

        pub fn engine(self: Builder, backend: Backend) Builder {
            self.config.setEngine(backend);
            return self;
        }

        pub fn features(self: Builder, features_val: *Features) Builder {
            self.config.setFeatures(features_val);
            return self;
        }

        pub fn target(self: Builder, target_val: *Target) Builder {
            self.config.setTarget(target_val);
            return self;
        }

        pub fn middleware(self: Builder, middleware_val: *Middleware) Builder {
            self.config.pushMiddleware(middleware_val);
            return self;
        }

        pub fn canonicalizeNans(self: Builder, enable: bool) Builder {
            self.config.setCanonicalizeNans(enable);
            return self;
        }

        pub fn build(self: Builder) *Config {
            return self.config;
        }
    };
};
pub const Engine = opaque {
    /// Create a new default engine
    pub fn init() !*Engine {
        return wasm_engine_new() orelse return Error.EngineInit;
    }

    /// Create a new engine with the given configuration
    pub fn initWithConfig(config: *Config) !*Engine {
        return wasm_engine_new_with_config(config) orelse return Error.EngineInit;
    }

    /// Clean up engine resources
    pub fn deinit(self: *Engine) void {
        wasm_engine_delete(self);
    }
};
pub const Store = opaque {
    /// Create a new store with the given engine
    pub fn init(engine: *Engine) !*Store {
        return wasm_store_new(engine) orelse return Error.StoreInit;
    }

    /// Clean up store resources
    pub fn deinit(self: *Store) void {
        wasm_store_delete(self);
    }
};
pub const Module = opaque {
    /// Create a module from WASM bytes
    pub fn init(store: *Store, wasm_bytes: *const ByteVec) !*Module {
        return wasm_module_new(store, wasm_bytes) orelse return Error.ModuleInit;
    }

    /// Validate WASM bytes without creating a module
    pub fn validate(store: *Store, wasm_bytes: *const ByteVec) bool {
        return wasm_module_validate(store, wasm_bytes);
    }

    /// Get the name of the module
    pub fn getName(self: *const Module, allocator: Allocator) ![]u8 {
        var name_vec = NameVec{
            .size = 0,
            .data = undefined,
        };
        wasmer_module_name(self, &name_vec);

        if (name_vec.size == 0) return error.NoName;

        const name_slice = name_vec.data[0..name_vec.size];
        return try allocator.dupe(u8, name_slice);
    }

    /// Set the name of the module
    pub fn setName(self: *Module, name: []const u8) !void {
        const name_vec = nameVecFromString(name);
        if (!wasmer_module_set_name(self, &name_vec)) {
            return Error.ModuleSetName;
        }
    }

    /// Serialize the module to bytes
    pub fn serialize(self: *const Module) ByteVec {
        var byte_vec = ByteVec.init();
        wasm_module_serialize(self, &byte_vec);
        return byte_vec;
    }

    /// Deserialize a module from bytes
    pub fn deserialize(store: *Store, bytes: *const ByteVec) !*Module {
        return wasm_module_deserialize(store, bytes) orelse return Error.ModuleDeserialize;
    }

    /// Clean up module resources
    pub fn deinit(self: *Module) void {
        wasm_module_delete(self);
    }
};

pub const Instance = opaque {
    /// Create an instance from a module
    pub fn init(store: *Store, module: *const Module, imports: ?*const ExternVec) !*Instance {
        var trap: ?*Trap = null;
        const instance = wasm_instance_new(store, module, imports, &trap) orelse {
            if (trap) |t| {
                defer wasm_trap_delete(t);
                // Try to extract trap message
                var message_vec: ?*ByteVec = null;
                wasm_trap_message(t, &message_vec);
                if (message_vec) |msg_vec| {
                    defer wasm_byte_vec_delete(msg_vec);
                    const msg_slice = msg_vec.asSliceConst();
                    std.debug.print("Trap message: {s}\n", .{msg_slice});
                }
            }
            return Error.InstanceInit;
        };
        return instance;
    }

    /// Create an instance with detailed error reporting
    pub fn initWithDetailedErrors(store: *Store, module: *const Module, imports: ?*const ExternVec) !*Instance {
        var trap: ?*Trap = null;
        const instance = wasm_instance_new(store, module, imports, &trap) orelse {
            if (trap) |t| {
                defer wasm_trap_delete(t);
                // TODO: Extract trap message for detailed error
            }
            return Error.InstanceInit;
        };
        return instance;
    }

    /// Get exports from the instance
    pub fn getExports(self: *Instance, exports: *ExternVec) void {
        wasm_instance_exports(self, exports);
    }

    /// Get a specific export by name
    pub fn getExport(self: *Instance, name: []const u8) ?*Extern {
        // TODO: Implement proper export lookup by name
        // This requires access to the module's export types to match names
        // For now, return null
        _ = self;
        _ = name; // Suppress unused parameter warning
        return null;
    }

    /// Get all exports as a name->extern map
    pub fn getExportsMap(self: *Instance, allocator: Allocator) !std.StringHashMap(*Extern) {
        var exports = ExternVec.init();
        defer exports.deinit();

        self.getExports(&exports);

        var map = std.StringHashMap(*Extern).init(allocator);
        errdefer {
            var it = map.iterator();
            while (it.next()) |entry| {
                allocator.free(entry.key_ptr.*);
            }
            map.deinit();
        }

        // TODO: Need to get export names from module
        // This is a placeholder implementation
        const exports_slice = exports.asSlice();
        _ = exports_slice; // Suppress unused variable warning

        // Placeholder: return empty map for now
        return map;
    }

    /// Check if an export exists
    pub fn hasExport(self: *Instance, name: []const u8) bool {
        return self.getExport(name) != null;
    }

    /// Get all export names
    pub fn getExportNames(self: *Instance, allocator: Allocator) ![][]u8 {
        // TODO: Implement proper export name retrieval
        // This requires access to the module's export types
        _ = self;
        _ = allocator; // Suppress unused parameter warning
        return &[_][]u8{}; // Return empty slice for now
    }

    /// Clean up instance resources
    pub fn deinit(self: *Instance) void {
        wasm_instance_delete(self);
    }
};

pub const Memory = opaque {
    /// Create memory from a memory type
    pub fn init(store: *Store, memory_type: *const MemoryType) !*Memory {
        return wasm_memory_new(store, memory_type) orelse return Error.MemoryInit;
    }

    /// Get the memory data as a byte slice
    pub fn getData(self: *const Memory) []u8 {
        const size = wasm_memory_data_size(self);
        const data = wasm_memory_data(self);
        return data[0..size];
    }

    /// Grow the memory by the given number of pages
    pub fn grow(self: *Memory, pages: u32) !void {
        if (!wasm_memory_grow(self, pages)) return Error.MemoryGrow;
    }

    /// Get the current size in pages
    pub fn getSize(self: *const Memory) u32 {
        return wasm_memory_size(self);
    }

    /// Clean up memory resources
    pub fn deinit(self: *Memory) void {
        wasm_memory_delete(self);
    }
};

pub const Table = opaque {
    /// Create a table from a table type
    pub fn init(store: *Store, table_type: *const TableType, init_value: ?*anyopaque) !*Table {
        return wasm_table_new(store, table_type, init_value) orelse return Error.TableInit;
    }

    /// Get the current table size
    pub fn getSize(self: *const Table) u32 {
        return wasm_table_size(self);
    }

    /// Grow the table by the given number of elements
    pub fn grow(self: *Table, delta: u32, init_value: ?*anyopaque) u32 {
        return wasm_table_grow(self, delta, init_value);
    }

    /// Get the value at the specified index
    pub fn get(self: *const Table, index: u32) ?*anyopaque {
        return wasm_table_get(self, index);
    }

    /// Set the value at the specified index
    pub fn set(self: *Table, index: u32, value: ?*anyopaque) !void {
        if (!wasm_table_set(self, index, value)) {
            return Error.TableSet;
        }
    }

    /// Clean up table resources
    pub fn deinit(self: *Table) void {
        wasm_table_delete(self);
    }
};

pub const Global = opaque {
    /// Create a global from a global type and initial value
    pub fn init(store: *Store, global_type: *const GlobalType, init_value: *const Value) !*Global {
        return wasm_global_new(store, global_type, init_value) orelse return Error.GlobalInit;
    }

    /// Get the current value of the global
    pub fn get(self: *const Global) Value {
        var value: Value = undefined;
        wasm_global_get(self, &value);
        return value;
    }

    /// Set a new value for the global
    pub fn set(self: *Global, value: *const Value) void {
        wasm_global_set(self, value);
    }

    /// Clean up global resources
    pub fn deinit(self: *Global) void {
        wasm_global_delete(self);
    }
};

pub const Trap = opaque {
    /// Create a trap with a message
    pub fn init(store: *Store, message: *const ByteVec) !*Trap {
        return wasm_trap_new(store, message) orelse return Error.TrapInit;
    }

    /// Clean up trap resources
    pub fn deinit(self: *Trap) void {
        wasm_trap_delete(self);
    }
};

pub const Func = opaque {
    /// Create a function from a function type and callback
    pub fn init(store: *Store, func_type: *const anyopaque, callback: Callback) !*Func {
        return wasm_func_new(store, func_type, callback) orelse return Error.FuncInit;
    }

    /// Create a function with environment from a callback
    pub fn initWithEnv(store: *Store, func_type: *const anyopaque, callback: CallbackWithEnv, env: *anyopaque, finalizer: ?*const fn (*anyopaque) callconv(.c) void) !*Func {
        return wasm_func_new_with_env(store, func_type, callback, env, finalizer) orelse return Error.FuncInit;
    }

    /// Call the function with parameters and get results
    pub fn call(self: *Func, params: []const Value, results: []Value) CallError!void {
        // Validate parameter count
        const param_arity = wasm_func_param_arity(self);
        if (params.len != param_arity) {
            return CallError.InvalidParamCount;
        }

        // Validate result count
        const result_arity = wasm_func_result_arity(self);
        if (results.len != result_arity) {
            return CallError.InvalidResultCount;
        }

        // Create parameter vector
        var param_vec = ValVec.fromSlice(params);
        defer param_vec.deinit();

        // Create result vector
        var result_vec = ValVec.initCapacity(result_arity);
        defer result_vec.deinit();

        // Call the function
        const trap = wasm_func_call(self, &param_vec, &result_vec);
        if (trap) |t| {
            // Handle trap - for now just return error
            wasm_trap_delete(t);
            return CallError.Trap;
        }

        // Copy results back
        const result_slice = result_vec.asSlice();
        @memcpy(results[0..result_arity], result_slice[0..result_arity]);
    }

    /// Get the number of parameters this function expects
    pub fn getParamArity(self: *const Func) usize {
        return wasm_func_param_arity(self);
    }

    /// Get the number of results this function returns
    pub fn getResultArity(self: *const Func) usize {
        return wasm_func_result_arity(self);
    }

    /// Convert to extern
    pub fn asExtern(self: *Func) *Extern {
        return wasm_func_as_extern(self) orelse unreachable;
    }

    /// Create a copy of the function
    pub fn copy(self: *const Func) !*Func {
        return wasm_func_copy(self) orelse return Error.FuncInit;
    }

    /// Clean up function resources
    pub fn deinit(self: *Func) void {
        wasm_func_delete(self);
    }
};

pub const Extern = opaque {
    /// Convert extern to function if it is one
    pub fn asFunc(self: *Extern) ?*Func {
        return wasm_extern_as_func(self);
    }

    /// Convert extern to memory if it is one
    pub fn asMemory(self: *Extern) ?*Memory {
        return wasm_extern_as_memory(self);
    }

    /// Convert extern to table if it is one
    pub fn asTable(self: *Extern) ?*Table {
        return wasm_extern_as_table(self);
    }

    /// Convert extern to global if it is one
    pub fn asGlobal(self: *Extern) ?*Global {
        return wasm_extern_as_global(self);
    }

    /// Get the kind of extern
    pub fn getKind(self: *const Extern) ExternKind {
        return wasm_extern_kind(self);
    }

    /// Get the type of the extern
    pub fn getType(self: *const Extern) *ExternType {
        return wasm_extern_type(self) orelse unreachable;
    }

    /// Clean up extern resources
    pub fn deinit(self: *Extern) void {
        wasm_extern_delete(self);
    }
};
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

// Vector types with RAII management
pub const ByteVec = extern struct {
    size: usize,
    data: [*]u8,

    /// Create an empty ByteVec
    pub fn init() ByteVec {
        var vec: ByteVec = undefined;
        wasm_byte_vec_new(&vec, 0, null);
        return vec;
    }

    /// Create a ByteVec from a slice (copies data)
    pub fn fromSlice(slice: []const u8) ByteVec {
        var vec: ByteVec = undefined;
        wasm_byte_vec_new(&vec, slice.len, slice.ptr);
        return vec;
    }

    /// Create an uninitialized ByteVec with capacity
    pub fn initCapacity(capacity: usize) ByteVec {
        var vec: ByteVec = undefined;
        wasm_byte_vec_new_uninitialized(&vec, capacity);
        return vec;
    }

    /// Get the data as a slice
    pub fn asSlice(self: *const ByteVec) []u8 {
        return self.data[0..self.size];
    }

    /// Get the data as a const slice
    pub fn asSliceConst(self: *const ByteVec) []const u8 {
        return self.data[0..self.size];
    }

    /// Clean up the ByteVec
    pub fn deinit(self: *ByteVec) void {
        wasm_byte_vec_delete(self);
    }
};

pub const ValVec = extern struct {
    size: usize,
    data: [*]Value,

    /// Create an empty ValVec
    pub fn init() ValVec {
        var vec: ValVec = undefined;
        wasm_val_vec_new(&vec, 0, null);
        return vec;
    }

    /// Create a ValVec from a slice of Values (copies data)
    pub fn fromSlice(values: []const Value) ValVec {
        var vec: ValVec = undefined;
        // Need to cast away const for the C API
        wasm_val_vec_new(&vec, values.len, @constCast(values.ptr));
        return vec;
    }

    /// Create an uninitialized ValVec with capacity
    pub fn initCapacity(capacity: usize) ValVec {
        var vec: ValVec = undefined;
        wasm_val_vec_new_uninitialized(&vec, capacity);
        return vec;
    }

    /// Get the values as a slice
    pub fn asSlice(self: *const ValVec) []Value {
        return self.data[0..self.size];
    }

    /// Clean up the ValVec
    pub fn deinit(self: *ValVec) void {
        wasm_val_vec_delete(self);
    }
};

pub const ExternVec = extern struct {
    size: usize,
    data: [*]?*Extern,

    /// Create an empty ExternVec
    pub fn init() ExternVec {
        var vec: ExternVec = undefined;
        wasm_extern_vec_new(&vec, 0, null);
        return vec;
    }

    /// Create an ExternVec from a slice of Extern pointers (copies data)
    pub fn fromSlice(externs: []?*Extern) ExternVec {
        var vec: ExternVec = undefined;
        wasm_extern_vec_new(&vec, externs.len, externs.ptr);
        return vec;
    }

    /// Create an uninitialized ExternVec with capacity
    pub fn initCapacity(capacity: usize) ExternVec {
        var vec: ExternVec = undefined;
        wasm_extern_vec_new_uninitialized(&vec, capacity);
        return vec;
    }

    /// Get the externs as a slice
    pub fn asSlice(self: *const ExternVec) []?*Extern {
        return self.data[0..self.size];
    }

    /// Clean up the ExternVec
    pub fn deinit(self: *ExternVec) void {
        wasm_extern_vec_delete(self);
    }
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
pub extern "c" fn wasm_module_new(?*Store, ?*const ByteVec) ?*Module;
pub extern "c" fn wasm_module_delete(?*Module) void;
pub extern "c" fn wasm_module_validate(?*Store, ?*const ByteVec) bool;
pub extern "c" fn wasm_module_exports(?*const Module, ?*ExportTypeVec) void;
pub extern "c" fn wasm_module_imports(?*const Module, ?*ImportTypeVec) void;
extern "c" fn wasm_module_share(?*const Module) ?*Module;
extern "c" fn wasm_module_obtain(?*Store, ?*const Module) ?*Module;
extern "c" fn wasm_module_serialize(?*const Module, ?*ByteVec) void;
extern "c" fn wasm_module_deserialize(?*Store, ?*const ByteVec) ?*Module;
extern "c" fn wasmer_module_name(?*const Module, ?*NameVec) void;
extern "c" fn wasmer_module_set_name(?*Module, ?*const NameVec) bool;

// Instance
extern "c" fn wasm_instance_new(?*Store, ?*const Module, ?*const ExternVec, ?*?*Trap) ?*Instance;
extern "c" fn wasm_instance_delete(?*Instance) void;
extern "c" fn wasm_instance_exports(?*Instance, ?*ExternVec) void;

// Func
extern "c" fn wasm_func_new(?*Store, ?*const anyopaque, Callback) ?*Func;
extern "c" fn wasm_func_delete(?*Func) void;
extern "c" fn wasm_func_new_with_env(?*Store, ?*const anyopaque, CallbackWithEnv, ?*anyopaque, ?*const fn (?*anyopaque) callconv(.c) void) ?*Func;
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
pub extern "c" fn wasm_functype_new(?*ValtypeVec, ?*ValtypeVec) ?*anyopaque;
pub extern "c" fn wasm_functype_delete(?*anyopaque) void;
pub extern "c" fn wasm_memorytype_new(?*const Limits) ?*MemoryType;
pub extern "c" fn wasm_memorytype_delete(?*MemoryType) void;
pub extern "c" fn wasm_tabletype_new(?*Valtype, ?*const Limits) ?*TableType;
pub extern "c" fn wasm_tabletype_delete(?*TableType) void;
pub extern "c" fn wasm_globaltype_new(?*Valtype, Mutability) ?*GlobalType;
pub extern "c" fn wasm_globaltype_delete(?*GlobalType) void;
pub extern "c" fn wasm_valtype_new(u8) ?*Valtype;
pub extern "c" fn wasm_valtype_delete(?*Valtype) void;
pub extern "c" fn wasm_valtype_kind(?*Valtype) u8;

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
// Function Type Helpers (from wasm.h convenience functions)
// -----------------------------------------------------------------------------

/// Create a function type that takes 0 parameters and returns 0 results
pub fn createFuncType0To0() !*anyopaque {
    var params = ValtypeVec{ .size = 0, .data = undefined };
    var results = ValtypeVec{ .size = 0, .data = undefined };
    return wasm_functype_new(&params, &results) orelse return Error.FuncTypeInit;
}

/// Create a function type that takes 1 parameter and returns 0 results
pub fn createFuncType1To0(param_type: *Valtype) !*anyopaque {
    var params = ValtypeVec{ .size = 1, .data = @as([*]?*Valtype, @ptrCast(@constCast(&param_type))) };
    var results = ValtypeVec{ .size = 0, .data = undefined };
    return wasm_functype_new(&params, &results) orelse return Error.FuncTypeInit;
}

/// Create a function type that takes 2 parameters and returns 0 results
pub fn createFuncType2To0(param1_type: *Valtype, param2_type: *Valtype) !*anyopaque {
    var params_data = [_]?*Valtype{ param1_type, param2_type };
    var params = ValtypeVec{ .size = 2, .data = @as([*]?*Valtype, @ptrCast(&params_data)) };
    var results = ValtypeVec{ .size = 0, .data = undefined };
    return wasm_functype_new(&params, &results) orelse return Error.FuncTypeInit;
}

/// Create a function type that takes 4 parameters and returns 0 results
pub fn createFuncType4To0(param1_type: *Valtype, param2_type: *Valtype, param3_type: *Valtype, param4_type: *Valtype) !*anyopaque {
    var params_data = [_]?*Valtype{ param1_type, param2_type, param3_type, param4_type };
    var params = ValtypeVec{ .size = 4, .data = @as([*]?*Valtype, @ptrCast(&params_data)) };
    var results = ValtypeVec{ .size = 0, .data = undefined };
    return wasm_functype_new(&params, &results) orelse return Error.FuncTypeInit;
}

/// Create a function type that takes 0 parameters and returns 1 result
pub fn createFuncType0To1(result_type: *Valtype) !*anyopaque {
    var params = ValtypeVec{ .size = 0, .data = undefined };
    var results = ValtypeVec{ .size = 1, .data = @as([*]?*Valtype, @ptrCast(@constCast(&result_type))) };
    return wasm_functype_new(&params, &results) orelse return Error.FuncTypeInit;
}

/// Create a function type that takes 1 parameter and returns 1 result
pub fn createFuncType1To1(param_type: *Valtype, result_type: *Valtype) !*anyopaque {
    var params = ValtypeVec{ .size = 1, .data = @as([*]?*Valtype, @ptrCast(@constCast(&param_type))) };
    var results = ValtypeVec{ .size = 1, .data = @as([*]?*Valtype, @ptrCast(@constCast(&result_type))) };
    return wasm_functype_new(&params, &results) orelse return Error.FuncTypeInit;
}

/// Create a function type that takes 2 parameters and returns 1 result
pub fn createFuncType2To1(param1_type: *Valtype, param2_type: *Valtype, result_type: *Valtype) !*anyopaque {
    var params_data = [_]?*Valtype{ param1_type, param2_type };
    var params = ValtypeVec{ .size = 2, .data = @as([*]?*Valtype, @ptrCast(&params_data)) };
    var results = ValtypeVec{ .size = 1, .data = @as([*]?*Valtype, @ptrCast(@constCast(&result_type))) };
    return wasm_functype_new(&params, &results) orelse return Error.FuncTypeInit;
}

/// Create a function type that takes 3 parameters and returns 1 result
pub fn createFuncType3To1(param1_type: *Valtype, param2_type: *Valtype, param3_type: *Valtype, result_type: *Valtype) !*anyopaque {
    var params_data = [_]?*Valtype{ param1_type, param2_type, param3_type };
    var params = ValtypeVec{ .size = 3, .data = @as([*]?*Valtype, @ptrCast(&params_data)) };
    var results = ValtypeVec{ .size = 1, .data = @as([*]?*Valtype, @ptrCast(@constCast(&result_type))) };
    return wasm_functype_new(&params, &results) orelse return Error.FuncTypeInit;
}

/// Create an i32 value type
pub fn createI32Valtype() !*Valtype {
    return wasm_valtype_new(@intFromEnum(Valkind.i32)) orelse return Error.ValtypeInit;
}

/// Create an i64 value type
pub fn createI64Valtype() !*Valtype {
    return wasm_valtype_new(@intFromEnum(Valkind.i64)) orelse return Error.ValtypeInit;
}

/// Create an f32 value type
pub fn createF32Valtype() !*Valtype {
    return wasm_valtype_new(@intFromEnum(Valkind.f32)) orelse return Error.ValtypeInit;
}

/// Create an f64 value type
pub fn createF64Valtype() !*Valtype {
    return wasm_valtype_new(@intFromEnum(Valkind.f64)) orelse return Error.ValtypeInit;
}

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
pub const Callback = *const fn (?*const ValVec, ?*ValVec) callconv(.c) ?*Trap;
pub const CallbackWithEnv = *const fn (?*anyopaque, ?*const ValVec, ?*ValVec) callconv(.c) ?*Trap;
pub const MeteringCostFunction = fn (u32) callconv(.c) u64;
pub const Mutability = enum(u8) {
    constant = 0,
    variable = 1,
};

pub const CallError = error{
    /// Failed to call the function
    InnerError,
    /// and resulted into an error
    InvalidResultType,
    /// When the user provided a different ResultType to Func.call
    /// than what is defined by the wasm binary
    InvalidParamCount,
    /// The given argument count to Func.call mismatches that
    /// of the func argument count of the wasm binary
    InvalidResultCount,
    /// The wasm function number of results mismatch that of the given
    /// ResultType to Func.Call. Note that void equals to 0 result types.
    Trap,
};

// =============================================================================
// INSTANCE IMPROVEMENTS (Section 2.3)
// =============================================================================

/// Detailed information about a required import
pub const ImportInfo = struct {
    module_name: []const u8,
    name: []const u8,
    extern_type: *ExternType,
};

/// Detailed error information for instantiation failures
pub const DetailedError = struct {
    error_type: InstantiationError,
    module_name: ?[]const u8,
    import_name: ?[]const u8,
    expected_type: ?*ExternType,
    provided_type: ?*ExternType,
    suggestion: ?[]const u8,
};

/// Enhanced instantiation error types
pub const InstantiationError = error{
    MissingImport,
    TypeMismatch,
    InvalidImport,
    LinkError,
};

/// Export information with name and type
pub const ExportInfo = struct {
    name: []const u8,
    extern_type: *ExternType,
    extern_ptr: *Extern,
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
    return ByteVec.fromSlice(slice);
}

/// Helper to create a NameVec from a string
pub fn nameVecFromString(str: []const u8) NameVec {
    return .{
        .size = str.len,
        .data = str.ptr,
    };
}

/// Convert a Zig value to a Wasmer Value
pub fn valueFromZigValue(value: anytype) Value {
    const T = @TypeOf(value);
    return switch (T) {
        i32 => Value{ .kind = .i32, .of = .{ .i32 = value } },
        i64 => Value{ .kind = .i64, .of = .{ .i64 = value } },
        f32 => Value{ .kind = .f32, .of = .{ .f32 = value } },
        f64 => Value{ .kind = .f64, .of = .{ .f64 = value } },
        else => @compileError("Unsupported value type: " ++ @typeName(T)),
    };
}

/// Validate that all required imports are provided
pub fn validateImports(module: *const Module, imports: ?*const ExternVec) !void {
    // TODO: Implement import validation
    // This should check that all module imports are satisfied by the provided imports
    // and that the types match
    _ = module;
    _ = imports;
}

/// Get list of required imports for a module
pub fn getRequiredImports(module: *const Module, allocator: Allocator) ![]ImportInfo {
    // TODO: Implement required imports retrieval
    // This should return detailed information about all imports required by the module
    _ = module;
    _ = allocator;
    return &[_]ImportInfo{}; // Return empty slice for now
}

// =============================================================================
// TYPE DEFINITIONS FOR MISSING TYPES
// =============================================================================

// These types are referenced in extern declarations but not defined in the main headers
// They may be internal or defined elsewhere

// Note: Some types like MemoryType, TableType, etc. are defined as opaque above
// but may need additional extern declarations if they have associated functions

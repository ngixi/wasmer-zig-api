const std = @import("std");
const log = std.log;
const testing = std.testing;
const types = @import("./types.zig");

// Import all types from types.zig
pub const Error = types.Error;
pub const Config = types.Config;
pub const Engine = types.Engine;
pub const Store = types.Store;
pub const Module = types.Module;
pub const Instance = types.Instance;
pub const Func = types.Func;
pub const Memory = types.Memory;
pub const Table = types.Table;
pub const Global = types.Global;
pub const Trap = types.Trap;
pub const Extern = types.Extern;
pub const ExternType = types.ExternType;
pub const WasiConfig = types.WasiConfig;
pub const WasiEnv = types.WasiEnv;
pub const WasiFilesystem = types.WasiFilesystem;
pub const Features = types.Features;
pub const CpuFeatures = types.CpuFeatures;
pub const Metering = types.Metering;
pub const Middleware = types.Middleware;
pub const Target = types.Target;
pub const Triple = types.Triple;
pub const NamedExtern = types.NamedExtern;

// Import vector and utility types from types.zig
pub const ByteVec = types.ByteVec;
pub const ValVec = types.ValVec;
pub const ExternVec = types.ExternVec;
pub const ExportTypeVec = types.ExportTypeVec;
pub const NamedExternVec = types.NamedExternVec;
pub const NameVec = types.NameVec;
pub const Limits = types.Limits;
pub const Value = types.Value;
pub const Valkind = types.Valkind;
pub const WasiVersion = types.WasiVersion;
pub const Backend = types.Backend;
pub const Compiler = types.Compiler;
pub const ValtypeVec = types.ValtypeVec;
pub const ImportTypeVec = types.ImportTypeVec;
pub const FrameVec = types.FrameVec;
pub const Mutability = types.Mutability;

// Keep local types that are not in types.zig
pub const MemoryType = opaque {
    pub fn init(limits: Limits) !*MemoryType {
        return wasm_memorytype_new(&limits) orelse return error.InitMemoryType;
    }

    pub fn deinit(self: *MemoryType) void {
        wasm_memorytype_delete(self);
    }

    extern "c" fn wasm_memorytype_new(*const Limits) ?*MemoryType;
    extern "c" fn wasm_memorytype_delete(*MemoryType) void;
};

pub const ExportType = opaque {
    /// Returns the name of the given ExportType
    pub fn name(self: *ExportType) *ByteVec {
        return self.wasm_exporttype_name().?;
    }

    extern "c" fn wasm_exporttype_name(*ExportType) ?*ByteVec;
};

pub const Callback = fn (?*const types.Valtype, ?*const types.Valtype) callconv(.c) ?*Trap;

pub const CallError = types.CallError;

var CALLBACK: usize = 0;

pub fn cb(params: ?*const types.Valtype, results: ?*const types.Valtype) callconv(.c) ?*Trap {
    _ = params;
    _ = results;
    const func = @as(*const fn () void, @ptrFromInt(CALLBACK));
    func();
    return null;
}

test "run_tests" {
    testing.refAllDecls(@This());
}

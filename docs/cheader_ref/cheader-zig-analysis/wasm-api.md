# WASM C API Analysis

## Current Implementation Status - UPDATED October 23, 2025

### ✅ **Fully Implemented Types (Method Wrappers + Extern Declarations)**
- `Config` - Complete with all methods (engine, compiler, features, target, middleware)
- `Engine` - Full init and withConfig functionality
- `Store` - Complete store operations
- `Module` - Full module lifecycle (init, validate, exports, imports, serialize)
- `Instance` - Complete instance management and export access
- `Func` - Full function API with parameter validation and calling
- `Memory` - Complete memory operations (data access, sizing, growth)
- `Table` - **COMPLETED**: Full table operations (init, size, grow, get, set)
- `Global` - **COMPLETED**: Full global variable management (init, get, set)
- `Trap` - Full trap handling and error propagation
- `Valtype`, `ValVec`, `ExternVec`, etc. - Complete value and extern handling with RAII

### ⚠️ **Extern Declarations Only (Missing Method Wrappers)**
- Advanced config options (some implemented, some missing wrappers)
- Advanced trap inspection methods

#### Config
```c
void wasm_config_push_middleware(wasm_config_t*, wasmer_middleware_t*)
void wasm_config_set_backend(wasm_config_t*, wasmer_backend_t)
void wasm_config_set_features(wasm_config_t*, wasmer_features_t*)
void wasm_config_set_target(wasm_config_t*, wasmer_target_t*)
void wasm_config_sys_canonicalize_nans(wasm_config_t*, bool)
```

#### Engine
- No additional functions needed beyond current

#### Module
```c
void wasmer_module_name(const wasm_module_t*, wasm_name_t*)
wasm_module_t* wasmer_module_new(wasm_engine_t*, const wasm_byte_vec_t*)
bool wasmer_module_set_name(wasm_module_t*, const wasm_name_t*)
void wasm_module_serialize(const wasm_module_t*, wasm_byte_vec_t*)
wasm_module_t* wasm_module_deserialize(wasm_store_t*, const wasm_byte_vec_t*)
```

#### Func
- Full call implementation missing
- FuncEnv support missing

#### Memory
- Additional operations may be missing

#### Table/Global
- [x] **COMPLETED**: Full Table and Global API with get/set methods

## Implementation Plan

### Phase 1: Complete Config API
1. Add missing Config methods
2. Implement Features, Target, Middleware types
3. Add proper error handling

### Phase 2: Extend Module API
- [x] **COMPLETED**: Add name operations
- [x] **COMPLETED**: Implement wasmer_module_new wrapper
- [x] **COMPLETED**: Add module serialization/deserialization

### Phase 3: Complete Func API
1. Fix call implementation
2. Add FuncEnv support

### Phase 4: Add Table/Global
- [x] **COMPLETED**: Implement Table type and operations
- [x] **COMPLETED**: Implement Global type and operations

### Phase 5: Advanced Features
1. Add CPU features
2. Add metering
3. Add target/triple support
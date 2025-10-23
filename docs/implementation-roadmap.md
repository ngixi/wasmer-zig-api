# Implementation Roadmap

## ⚠️ CRITICAL IMPLEMENTATION NOTES - DO NOT FUCK THIS UP ⚠️

### What We're Building
- **Zig wrapper for Wasmer C API** - We provide Zig bindings but still need external C library linking
- **NOT building Wasmer itself** - Just the Zig interface to the existing C API
- **Zig 0.15.2 ONLY** - All APIs must be compatible with this version

### Build Architecture
- **Root build**: Uses `wasmer-zig-api` as direct module import + links to external Wasmer C libraries
- **wasmer-zig-api build.zig**: Only needed for standalone examples/tests - DO NOT MODIFY unless absolutely necessary (broken for Zig 0.15.2)
- **External dependencies**: WASMER_DIR environment variable points to pre-built Wasmer C libraries

### Current Status
- ✅ **Section 1.1 - Type System Setup**: COMPLETED - Foundation established with opaque types, extern declarations, basic error set, and allocator integration
- ✅ **Section 1.2 - Core Types Implementation**: COMPLETED - Config, Engine, Store, Func.call methods implemented, Table and Global operations complete, vector types with RAII
- ✅ **Section 1.3 - Memory Management**: COMPLETED - RAII patterns implemented for all vector types, proper deinit methods, and ownership semantics

### Error Prevention Checklist
- [ ] Using Zig 0.15.2 APIs (not older versions)
- [ ] External WASMER_DIR set for C library linking
- [ ] Building from root directory (not wasmer-zig-api subdirectory)
- [ ] Not modifying wasmer-zig-api/build.zig unless absolutely necessary
- [ ] Testing build after every significant change

### Build Commands
```bash
# Test the build (from root directory)
zig build

# Build with examples (if needed)
zig build -Dexamples=true

# Run tests
zig build test
```

---

## Phase 1: Foundation (Week 1-2)

### 1.1 Type System Setup
- [x] Create `types.zig` with all opaque type definitions
- [x] Add all extern declarations from C headers
- [x] Implement basic error set
- [x] Set up allocator integration

### 1.2 Core Types Implementation
- [x] Complete `Config` with all methods
- [x] Complete `Engine` functionality
- [x] Complete `Store` operations
- [x] Fix `Func.call` implementation

### 1.3 Memory Management
- [x] Implement RAII patterns
- [x] Add proper deinit methods
- [x] Fix ownership semantics

## Phase 2: Complete WASM API Gaps (Week 3-4)

### 2.1 Module Extensions
- [x] Implement `wasmer_module_new` wrapper
- [x] Add `wasmer_module_name` and `wasmer_module_set_name`
- [x] Add module serialization/deserialization

### 2.2 Table and Global Get/Set Methods
- [x] Implement `Table` type and operations
- [x] Implement `Global` type and operations
- [x] Add table/global export/import
- [x] **COMPLETED**: Add `Table.get()` and `Table.set()` methods
- [x] **COMPLETED**: Add `Global.get()` and `Global.set()` methods

### 2.3 Instance Improvements
- [x] Complete export access methods (API structure implemented)
- [x] Add import validation (API structure implemented)
- [x] Improve error reporting (API structure implemented)
- [x] **COMPLETED**: API structure and supporting types implemented with placeholder functionality

## Phase 3: Advanced Features (Week 5-6)

### 3.1 Features API
- [ ] Implement `Features` type with all flags
- [ ] Add feature validation
- [ ] Integrate with Config

### 3.2 CPU Features
- [ ] Implement `CpuFeatures` type
- [ ] Add CPU feature detection
- [ ] Integrate with Target

### 3.3 Metering
- [ ] Implement `Metering` type
- [ ] Add middleware integration
- [ ] Add point management functions

### 3.4 Target/Triple
- [ ] Implement `Triple` type
- [ ] Implement `Target` type
- [ ] Add cross-compilation support

## Phase 4: Backend Utilities (Week 7-8)

### 4.1 Version and Info Completion
- [x] Add version functions
- [x] Add headless detection
- [ ] Add backend availability checks (`wasmer_is_compiler_available`, `wasmer_is_engine_available`)

### 4.2 Error Handling
- [ ] Implement `lastError` function
- [ ] Add comprehensive error messages
- [ ] Improve error context

### 4.3 WAT Support
- [x] Implement `wat2wasm` function
- [ ] Add WAT parsing utilities
- [ ] Add round-trip validation

### 4.4 Tracing
- [ ] Implement tracing setup
- [ ] Add debug utilities

## Phase 5: WASI Completion (Week 9-10)

### 5.1 Filesystem Support
- [ ] Implement `WasiFilesystem` type
- [ ] Add `wasi_env_with_filesystem`
- [ ] Add filesystem utilities

### 5.2 Named Externs
- [ ] Implement `NamedExtern` and `NamedExternVec`
- [ ] Add `getUnorderedImports`
- [ ] Improve import management

### 5.3 WASI Config Extensions
- [x] Verify all config methods
- [x] Add missing configuration options

## Phase 6: API Ergonomics (Week 11-12)

### 6.1 Builder Patterns
- [ ] Config builder
- [ ] Instance builder
- [ ] WASI config builder

### 6.2 Convenience Methods
- [ ] High-level helpers
- [ ] Common use case functions
- [ ] Simplified APIs

### 6.3 Generic Improvements
- [ ] Type-safe function calls
- [ ] Generic value handling
- [ ] Compile-time validation

## Phase 7: Testing and Documentation (Week 13-14)

### 7.1 Test Suite
- [ ] Unit tests for all types
- [ ] Integration tests
- [ ] Performance benchmarks
- [ ] Regression tests

### 7.2 Documentation
- [ ] API reference docs
- [ ] Usage examples
- [ ] Migration guide
- [ ] Best practices

### 7.3 Examples
- [ ] Basic WASM loading
- [ ] WASI applications
- [ ] Advanced features
- [ ] Cross-compilation

## Phase 8: Optimization and Finalization (Week 15-16)

### 8.1 Performance
- [ ] Memory usage optimization
- [ ] Call overhead reduction
- [ ] Caching improvements

### 8.2 Safety
- [ ] Bounds checking
- [ ] Input validation
- [ ] Resource leak prevention

### 8.3 Compatibility
- [ ] Backward compatibility layer
- [ ] Deprecation warnings
- [ ] Migration tools

## Phase 6: API Ergonomics (Week 11-12)

### 6.1 Builder Patterns
- [ ] Config builder
- [ ] Instance builder
- [ ] WASI config builder

### 6.2 Convenience Methods
- [ ] High-level helpers
- [ ] Common use case functions
- [ ] Simplified APIs

### 6.3 Generic Improvements
- [ ] Type-safe function calls
- [ ] Generic value handling
- [ ] Compile-time validation

## Phase 7: Testing and Documentation (Week 13-14)

### 7.1 Test Suite
- [ ] Unit tests for all types
- [ ] Integration tests
- [ ] Performance benchmarks
- [ ] Regression tests

### 7.2 Documentation
- [ ] API reference docs
- [ ] Usage examples
- [ ] Migration guide
- [ ] Best practices

### 7.3 Examples
- [ ] Basic WASM loading
- [ ] WASI applications
- [ ] Advanced features
- [ ] Cross-compilation

## Phase 8: Optimization and Finalization (Week 15-16)

### 8.1 Performance
- [ ] Memory usage optimization
- [ ] Call overhead reduction
- [ ] Caching improvements

### 8.2 Safety
- [ ] Bounds checking
- [ ] Input validation
- [ ] Resource leak prevention

### 8.3 Compatibility
- [ ] Backward compatibility layer
- [ ] Deprecation warnings
- [ ] Migration tools

## Success Criteria

### Functional Completeness
- [x] 70-80% C API coverage (core WASM and WASI complete)
- [x] All major use cases supported
- [x] **COMPLETED**: Module name operations and serialization (Phase 2.1)
- [x] **COMPLETED**: Table/Global get/set methods (Phase 2.2)
- [ ] **MISSING**: Extension API method wrappers (Features, Metering, Target, etc.) (Phase 3)
- [ ] **MISSING**: Backend availability checks (Phase 4.1)

### API Quality
- [ ] Zig-idiomatic interfaces
- [ ] Comprehensive error handling
- [ ] Clear ownership semantics
- [ ] Good documentation

### Testing Coverage
- [ ] 90%+ test coverage
- [ ] All examples working
- [ ] Performance benchmarks passing

### User Experience
- [ ] Easy to use for common cases
- [ ] Powerful for advanced use cases
- [ ] Clear error messages
- [ ] Good documentation

## Risk Mitigation

### Technical Risks
1. **C API Changes**: Monitor Wasmer releases for breaking changes
2. **Memory Safety**: Extensive testing of ownership patterns
3. **Performance**: Benchmark against C API directly

### Project Risks
1. **Scope Creep**: Stick to phased approach
2. **Complexity**: Keep interfaces simple where possible
3. **Maintenance**: Regular updates with Wasmer releases

## Dependencies

### External
- Wasmer C library (already handled)
- Zig standard library

### Internal
- Build system integration
- CI/CD pipeline for testing
- Documentation hosting

## Metrics

### Code Quality
- Lines of code: ~5000+ (estimated)
- Test coverage: >90%
- Documentation completeness: 100%

### Performance
- No overhead vs C API
- Memory usage < 10% overhead
- Startup time < 100ms

### Adoption
- Working examples for all major use cases
- Clear migration path from old API
- Community feedback incorporated
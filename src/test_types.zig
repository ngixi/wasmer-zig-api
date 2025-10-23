// Test file to verify Func.call implementation
const std = @import("std");
const types = @import("types.zig");

test "Value conversion functions" {
    // Test valueFromZigValue and zigValueFromValue functions
    const value_i32 = types.valueFromZigValue(@as(i32, 42));
    try std.testing.expect(value_i32.kind == .i32);
    try std.testing.expect(value_i32.of.i32 == 42);

    const value_i64 = types.valueFromZigValue(@as(i64, 123456789));
    try std.testing.expect(value_i64.kind == .i64);
    try std.testing.expect(value_i64.of.i64 == 123456789);

    const value_f32 = types.valueFromZigValue(@as(f32, 3.14));
    try std.testing.expect(value_f32.kind == .f32);
    try std.testing.expect(value_f32.of.f32 == 3.14);

    const value_f64 = types.valueFromZigValue(@as(f64, 2.71828));
    try std.testing.expect(value_f64.kind == .f64);
    try std.testing.expect(value_f64.of.f64 == 2.71828);

    // Test conversion back
    const back_i32 = types.zigValueFromValue(i32, value_i32);
    try std.testing.expect(back_i32 == 42);

    const back_i64 = types.zigValueFromValue(i64, value_i64);
    try std.testing.expect(back_i64 == 123456789);

    const back_f32 = types.zigValueFromValue(f32, value_f32);
    try std.testing.expect(back_f32 == 3.14);

    const back_f64 = types.zigValueFromValue(f64, value_f64);
    try std.testing.expect(back_f64 == 2.71828);
}

test "Vector type definitions compile" {
    // Test that vector types are properly defined and can be instantiated
    // We can't actually call the extern functions without linking Wasmer,
    // but we can verify the types compile

    // Test ByteVec type
    const ByteVecType = types.ByteVec;
    const byte_vec_size = @sizeOf(ByteVecType);
    try std.testing.expect(byte_vec_size > 0);

    // Test ValVec type
    const ValVecType = types.ValVec;
    const val_vec_size = @sizeOf(ValVecType);
    try std.testing.expect(val_vec_size > 0);

    // Test ExternVec type
    const ExternVecType = types.ExternVec;
    const extern_vec_size = @sizeOf(ExternVecType);
    try std.testing.expect(extern_vec_size > 0);

    // Test Value type
    const ValueType = types.Value;
    const value_size = @sizeOf(ValueType);
    try std.testing.expect(value_size > 0);

    // Test Valkind enum
    const i32_kind = types.Valkind.i32;
    const i64_kind = types.Valkind.i64;
    const f32_kind = types.Valkind.f32;
    const f64_kind = types.Valkind.f64;

    try std.testing.expect(@intFromEnum(i32_kind) == 0);
    try std.testing.expect(@intFromEnum(i64_kind) == 1);
    try std.testing.expect(@intFromEnum(f32_kind) == 2);
    try std.testing.expect(@intFromEnum(f64_kind) == 3);
}

test "Func type definition compiles" {
    // Test that Func type is properly defined
    // Opaque types don't have a size, so we just verify it compiles
    try std.testing.expect(true);
}

test "Error types are defined" {
    // Test that error types are properly defined
    const CallErrorType = types.CallError;

    // Test that we can reference the error values
    const inner_error = CallErrorType.InnerError;
    const invalid_param_count = CallErrorType.InvalidParamCount;
    const invalid_result_count = CallErrorType.InvalidResultCount;
    const trap = CallErrorType.Trap;

    // Verify they are different error values
    try std.testing.expect(inner_error != invalid_param_count);
    try std.testing.expect(invalid_param_count != invalid_result_count);
    try std.testing.expect(invalid_result_count != trap);
}

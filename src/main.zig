const std = @import("std");
const expect = @import("std").testing.expect;

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    var i: usize = 1;
    while (i <= 16) : (i += 1) {
        if (i % 15 == 0) {
            try stdout.writeAll("ZiggZagg\n");
        } else if (i % 3 == 0) {
            try stdout.writeAll("Zigg\n");
        } else if (i % 5 == 0) {
            try stdout.writeAll("Zagg\n");
        } else {
            try stdout.print("{d}\n", .{i});
        }
    }
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}

test "if statement" {
    const a = true;
    var x: u8 = 0;
    if (a) {
        x += 1;
    } else {
        x += 2;
    }
    try expect(x == 1);
}

test "if statement expression" {
    const a = true;
    var x: u8 = 0;
    x += if (a) 1 else 2;
    try expect(x == 1);
}

test "while" {
    var i: u8 = 2;
    while (i < 100) {
        i += 2;
    }
    try expect(i == 100);
}

test "while with continue expression" {
    var sum: u8 = 0;
    var i: u8 = 1;
    while (i <= 10) : (i += 1) {
        sum += 1;
    }
    try expect(i == 11);
}

test "while with continue" {
    var sum: u8 = 0;
    var i: u8 = 0;
    while (i <= 3) : (i += 1) {
        if (i == 2) continue;
        sum += i;
    }
    try expect(sum == 4);
}

test "while with break" {
    var sum: u8 = 0;
    var i: u8 = 0;
    while (i <= 3) : (i += 1) {
        if (i == 2) break;
        sum += i;
    }
    try expect(sum == 1);
}

test "for" {
    const string = [_]u8{ 'a', 'b', 'c' };

    for (string, 0..) |char, index| {
        std.log.info("Index = {d}, Char = {d}\n", .{ index, char });
    }

    for (string) |char| {
        _ = char;
    }

    for (string, 0..) |_, index| {
        _ = index;
    }

    for (string) |_| {}
}

test "out of bounds" {
    @setRuntimeSafety(false);
    const a = [3]u8{ 1, 2, 3 };
    var index: u8 = 5;
    const b = a[index];
    _ = b;
}

fn asciiToUpper(x: u8) u8 {
    return switch (x) {
        'a'...'z' => x + 'A' - 'a',
        'A'...'Z' => x,
        else => unreachable,
    };
}

test "unreachable switch" {
    try expect(asciiToUpper('a') == 'A');
    try expect(asciiToUpper('A') == 'A');
    // try expect(asciiToUpper('[') == 'A');
}

fn increment(num: *u8) void {
    num.* += 1;
}

test "pointers" {
    var x: u8 = 1;
    increment(&x);
    try expect(x == 2);
}

// test "naughty pointer" {
//     var x: u16 = 0;
//     var y: *u8 = @intToPtr(*u8, x);
//     _ = y;
// }

// test "const pointers" {
//     const x: u8 = 1;
//     var y = &x;
//     y.* += 1;
// }

// Slices
fn total(values: []const u8) usize {
    var sum: usize = 0;
    for (values) |v| sum += v;
    return sum;
}

test "slices" {
    const array = [_]u8{ 1, 2, 3, 4, 5 };
    const slice = array[0..3];
    try expect(total(slice) == 6);
}

test "slices 2" {
    const array = [_]u8{ 1, 2, 3, 4, 5 };
    const slice = array[0..3];
    try expect(@TypeOf(slice) == *const [3]u8);
}

test "slices 3" {
    var array = [_]u8{ 1, 2, 3, 4, 5 };
    var slice = array[0..];
    try expect(total(slice) == 15);
    var slice2 = slice[3..];
    try expect(total(slice2) == 9);
}

// Enums
const Direction = enum { north, south, east, west };
const Value = enum(u2) { zero, one, two };

test "enum ordinal value" {
    try expect(@enumToInt(Value.zero) == 0);
    try expect(@enumToInt(Value.one) == 1);
    try expect(@enumToInt(Value.two) == 2);
}

const Value2 = enum(u32) {
    hundred = 100,
    thousand = 1000,
    million = 1000000,
    next,
};

test "set enum ordinal value" {
    try expect(@enumToInt(Value2.hundred) == 100);
    try expect(@enumToInt(Value2.thousand) == 1000);
    try expect(@enumToInt(Value2.million) == 1000000);
    try expect(@enumToInt(Value2.next) == 1000001);
}

const Suit = enum {
    clubs,
    spades,
    diamonds,
    hearts,

    pub fn isClubs(s: Suit) bool {
        return s == Suit.clubs;
    }

    pub fn isHearts(self: Suit) bool {
        return self == Suit.hearts;
    }
};

test "emum method" {
    try expect(Suit.spades.isClubs() == Suit.isClubs(.spades));
    const mySuit: Suit = Suit.hearts;
    try expect(mySuit.isHearts());
    try expect(Suit.isHearts(Suit.clubs) == Suit.isClubs(.hearts));
}

const Mode = enum {
    var count: u8 = 0;
    on,
    off,
};

test "increment enum var" {
    try expect(Mode.count == 0);
    Mode.count += 1;
    try expect(Mode.count == 1);
}

const Vec3 = struct {
    x: f32,
    y: f32,
    z: f32,
};

test "struct" {
    const my_vector = Vec3{
        .x = 0,
        .y = 100,
        .z = 3.14,
    };

    _ = my_vector;
}

const Vec4 = struct { x: f32, y: f32, z: f32 = 0, w: f32 = undefined };

test "struct defaults" {
    const my_vector = Vec4{
        .x = 25,
        .y = -50,
    };
    _ = my_vector;
}

const Stuff = struct {
    x: i32,
    y: i32,

    fn swap(s: *Stuff) void {
        const tmp = s.x;
        s.x = s.y;
        s.y = tmp;
    }
};

test "automatic dereference" {
    var thing = Stuff{ .x = 10, .y = 20 };
    thing.swap();
    try expect(thing.x == 20);
    try expect(thing.y == 10);
}

fn rangeHasNumber(begin: usize, end: usize, number: usize) bool {
    var i = begin;
    return while (i < end) : (i += 1) {
        if (i == number) {
            break true;
        }
    } else false;
}

test "while loop expression" {
    try expect(rangeHasNumber(0, 10, 3));
}

test "optional" {
    var found_index: ?usize = null;
    const data = [_]i32{ 1, 2, 3, 4, 5, 6, 7, 8, 12 };
    for (data, 0..) |v, i| {
        if (v == 10) found_index = i;
    }
    try expect(found_index == null);
}

test "orelse" {
    var a: ?f32 = null;
    var b = a orelse 0;
    try expect(b == 0);
    try expect(@TypeOf(b) == f32);
}

// .? is a shorthand for orelse unreachable, a bit like unwrap in rust
test "orelse unreachable" {
    const a: ?f32 = 5;
    const b = a orelse unreachable;
    const c = a.?;
    try expect(b == c);
    try expect(@TypeOf(c) == f32);
    try expect(a == b and a == c);
}

test "if optional payload capture" {
    const a: ?i32 = 5;
    if (a != null) {
        const value = a.?;
        _ = value;
    }

    var b: ?i32 = 5;
    if (b) |*value| {
        value.* += 1;
    }
    try expect(b.? == 6);
}

var numbers_left: u32 = 4;
fn eventuallyNullSequence() ?u32 {
    if (numbers_left == 0) return null;
    numbers_left -= 1;
    return numbers_left;
}

test "while null capture" {
    var sum: u32 = 0;
    while (eventuallyNullSequence()) |value| {
        sum += value;
    }
    try expect(sum == 6); // 3 + 2 + 1
}

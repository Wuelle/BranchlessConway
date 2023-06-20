const std = @import("std");

// Single step from bubblesort
inline fn bubble(comptime T: type, a: *T, b: *T) void {
    const tmp = a.* & b.*;
    b.* = a.* | b.*;
    a.* = tmp;
}

pub fn Board(comptime N: usize) type {
    const bits_required = N * N;
    if (bits_required > std.math.maxInt(u16)) {
        @compileError("Try a smaller grid >.>");
    }

    const Bitmap = @Type(.{
        .Int = .{
            .signedness = .unsigned,
            .bits = N * N,
        },
    });


    return struct {
        alive: Bitmap,

        const Self = @This();

        pub fn empty() Self {
            return .{
                .alive = 0,
            };
        }

        pub fn debug_print(self: *const Self) void {
            var t = self.alive;
            // This has branches, but its only for debug printing ¯\_(ツ)_/¯
            for (0..N * N) |i| {
                std.debug.print("{} ", .{t & 1});

                t >>= 1;
                if ((i + 1) % N == 0) {
                    std.debug.print("\n", .{});
                }
            }
            std.debug.print("\n", .{});
        }

        pub fn toggle_cell(self: *Self, x: usize, y: usize) void {
            const index = x + N * y;
            self.alive ^= std.math.shl(Bitmap, @as(Bitmap, 1), index);
        }


        pub fn step(self: *Self) void {
            // & keeps the bits which have been set twice
            // | keeps all the bits which have been set at least once
            // Use this to sort the bits in the bitmaps, without branches

            // Bitmasks with all the neighbors in one of the 8 directions
            var n0 = self.alive >> N; // Bottom neighbors
            var n1 = self.alive << N; // Top neighbors
            var n2 = self.alive >> N + 1; // Bottom right neighbors
            var n3 = self.alive << N + 1; // Top left neighbors
            var n4 = self.alive >> N - 1; // Bottom left neighbors
            var n5 = self.alive << N - 1; // Top right neighbors
            var n6 = self.alive >> 1; // Right neighbors
            var n7 = self.alive << 1; // Left neeighbors

            // Bubblesort. *Far* from the most efficient but I'm tired
            // and this is easy to reason about ^^
            bubble(Bitmap, &n6, &n7);
            bubble(Bitmap, &n5, &n6);
            bubble(Bitmap, &n4, &n5);
            bubble(Bitmap, &n3, &n4);
            bubble(Bitmap, &n2, &n3);
            bubble(Bitmap, &n1, &n2);
            bubble(Bitmap, &n0, &n1);

            bubble(Bitmap, &n6, &n7);
            bubble(Bitmap, &n5, &n6);
            bubble(Bitmap, &n4, &n5);
            bubble(Bitmap, &n3, &n4);
            bubble(Bitmap, &n2, &n3);
            bubble(Bitmap, &n1, &n2);

            bubble(Bitmap, &n6, &n7);
            bubble(Bitmap, &n5, &n6);
            bubble(Bitmap, &n4, &n5);
            bubble(Bitmap, &n3, &n4);
            bubble(Bitmap, &n2, &n3);

            bubble(Bitmap, &n6, &n7);
            bubble(Bitmap, &n5, &n6);
            bubble(Bitmap, &n4, &n5);
            bubble(Bitmap, &n3, &n4);

            bubble(Bitmap, &n6, &n7);
            bubble(Bitmap, &n5, &n6);
            bubble(Bitmap, &n4, &n5);

            bubble(Bitmap, &n6, &n7);
            bubble(Bitmap, &n5, &n6);

            bubble(Bitmap, &n6, &n7);

            // Compute bitmasks for exact number of neighbors
            const set_8_times = n0;
            const set_7_times = n1 ^ n0;
            const set_6_times = n2 ^ n1;
            const set_5_times = n3 ^ n2;
            const set_4_times = n4 ^ n3;
            const set_3_times = n5 ^ n4;
            const set_2_times = n6 ^ n5;
            const set_1_times = n7 ^ n6;
            const set_0_times = ~n7;
            
            const alive = self.alive;
            const revive_map = (~alive & set_3_times);
            const kill_map = alive & ~(set_2_times | set_3_times);
            const toggle_map = revive_map | kill_map;

            self.alive ^= toggle_map;

            // Shut up zig, I'm trying to write pretty code.
            _ = set_0_times;
            _ = set_1_times;
            _ = set_4_times;
            _ = set_5_times;
            _ = set_6_times;
            _ = set_7_times;
            _ = set_8_times;
        }
    };
}

pub fn main() !void {
    var b = Board(32).empty();

    // Build a glider
    //  x
    //   x
    // xxx
    b.toggle_cell(10, 10);
    b.toggle_cell(11, 10);
    b.toggle_cell(12, 10);
    b.toggle_cell(12, 9);
    b.toggle_cell(11, 8);

    b.debug_print();
    b.step();
    b.debug_print();

}

const std = @import("std");
const stdout = std.io.getStdOut().writer();
const mem = std.mem;
const parseInt = std.fmt.parseInt;

fn handleFirstQuestion(file_path: []const u8) !void {
    const allocator = std.heap.page_allocator;

    const file = try std.fs.cwd().openFile(file_path, .{});
    defer file.close();

    var buffer = std.io.bufferedReader(file.reader());
    var reader = buffer.reader();

    var line_buffer = std.ArrayList(u8).init(allocator);
    defer line_buffer.deinit();

    while (true) {
        line_buffer.clearAndFree();

        reader.streamUntilDelimiter(line_buffer.writer(), '\n', null) catch |err| switch (err) {
            error.EndOfStream => break,
            else => return err,
        };

        const line = line_buffer.items;

        var numbers = std.ArrayList(u8).init(allocator);
        defer numbers.deinit();

        for (line) |char| {
            if (std.ascii.isDigit(char)) {
                try numbers.append(char);
            }
        }

        if (numbers.items.len > 0) {
            var numberStringBuffer: [256]u8 = undefined;
            std.mem.copy(u8, numberStringBuffer[0..], numbers.items);
            const numberString = numberStringBuffer[0..numbers.items.len];

            const number = try parseInt(i32, numberString, 10);
            try stdout.print("Números encontrados: {d}\n", .{number});
        }
    }
}

pub fn main() !void {
    try handleFirstQuestion("input.txt");
}

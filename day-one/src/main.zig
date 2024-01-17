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

    var total_result: i32 = 0;

    while (true) {
        line_buffer.clearAndFree();

        reader.streamUntilDelimiter(line_buffer.writer(), '\n', null) catch |err| switch (err) {
            error.EndOfStream => break,
            else => return err,
        };

        const line = line_buffer.items;

        var numbers = std.ArrayList(u8).init(allocator);
        defer numbers.deinit();

        var first_digit = std.ArrayList(u8).init(allocator);
        defer first_digit.deinit();

        var last_digit = std.ArrayList(u8).init(allocator);
        defer last_digit.deinit();

        for (line) |char| {
            if (std.ascii.isDigit(char)) {
                if (first_digit.items.len == 0) {
                    try first_digit.append(char);
                }

                if (last_digit.items.len > 0) {
                    last_digit.clearAndFree();
                }

                try last_digit.append(char);
            }
        }

        try first_digit.appendSlice(last_digit.items);

        total_result += parseInt(i32, first_digit.items, 10) catch |err| switch (err) {
            else => 0,
        };
    }

    try stdout.print("Result: {d}\n", .{total_result});
}

pub fn main() !void {
    try handleFirstQuestion("input.txt");
}

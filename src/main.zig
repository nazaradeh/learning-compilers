const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const args = try std.process.argsAlloc(gpa.allocator());
    defer std.process.argsFree(gpa.allocator(), args);
    if (args.len < 2) {
        std.debug.print("Please pass through an argument.\n", .{});
        return;
    }
    const file = std.fs.cwd().openFile(args[1], .{}) catch |err| {
        std.debug.print("{s}\n", .{@errorName(err)});
        return;
    };
    defer file.close();
    const file_size = try file.getEndPos();
    const source_code = try gpa.allocator().alloc(u8, file_size);
    defer gpa.allocator().free(source_code);
    _ = try file.readAll(source_code);
    if (comptime @import("builtin").target.os.tag == .windows) _ = std.os.windows.kernel32.SetConsoleOutputCP(65001);
    std.debug.print("{s}\n", .{source_code});
}

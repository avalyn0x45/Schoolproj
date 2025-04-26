const std = @import("std");
const js = @import("js.zig");

pub const Color = enum(u8) {
    Black = 30,
    Red = 31,
    Green = 32,
    Yellow = 33,
    Blue = 34,
    Purple = 35,
    Cyan = 36,
    White = 37,
};
pub const TextType = enum { Normal, Bold, Underline, Intense, IntenseBold };
pub const TextColor = struct {
    start: u16 = 0,
    length: u16 = 0,
    color: Color = .White,
    txt_type: TextType = .Normal,
    bg_color: Color = .Black,
    bg_hi: bool = false,
};
pub const Line = struct {
    redraw: bool,
    x: []u8,
    colors: []TextColor,
};
pub const CursorType = enum {
    BlinkingBlock,
    Block,
    BlinkingUnderline,
    Underline,
    BlinkingBar,
    Bar,
    Hidden,
};

var wa = std.heap.wasm_allocator;
pub var lines: []Line = undefined;
var ccpx: u16 = 0;
var ccpy: u16 = 0;

export fn redraw_ne() void {
    redraw() catch @panic("Error in JS exposed function!");
}

pub fn redraw() !void {
    var seq = std.ArrayList(u8).init(wa);
    var ntp = false;
    var ca = true;
    const ccpxc = ccpx;
    const ccpyc = ccpy;
    try seq.appendSlice("\x1b[H");

    for (lines, 0..) |*line, y| {
        if (true) {
            //if (line.redraw) {
            //    ntp = true;
            //}
            ntp = true;
            while (ccpy < y) {
                try seq.appendSlice("\x1b[1B"); //up
                ccpy += 1;
            }
            while (ccpy > y) {
                try seq.appendSlice("\x1b[1A"); //down
                ccpy -= 1;
            }
            try seq.appendSlice("\r\x1b[2K"); //clear line
            const line_start = seq.items.len;
            try seq.appendSlice(line.x);
            for (line.colors) |color| {
                var fgcc = [7]u8{ 0x1b, '[', '0', ';', '0', '0', 'm' };
                var fg_color = @intFromEnum(color.color);
                switch (color.txt_type) {
                    .Normal => {
                        fgcc[2] = '0';
                    },
                    .Bold => {
                        fgcc[2] = '1';
                    },
                    .Underline => {
                        fgcc[2] = '4';
                    },
                    .Intense => {
                        fg_color += 60;
                    },
                    .IntenseBold => {
                        fg_color += 60;
                        fgcc[2] = 2;
                    },
                }
                _ = std.fmt.formatIntBuf(fgcc[4..6], fg_color, 10, .lower, .{});

                var bgcc = [8]u8{ 0x1b, '[', 0, 0, 0, 0, 0, 'm' };
                const bg_color = @intFromEnum(color.bg_color);
                if (color.bg_hi) {
                    bgcc[2] = '0';
                    bgcc[3] = ';';
                    _ = std.fmt.formatIntBuf(bgcc[4..7], bg_color + 70, 10, .lower, .{});
                } else {
                    _ = std.fmt.formatIntBuf(bgcc[2..4], bg_color + 10, 10, .lower, .{});
                }

                try seq.insertSlice(color.start + line_start, &fgcc);
                try seq.insertSlice(color.start + line_start, &bgcc);
                if (color.length > 0) {
                    try seq.insertSlice(color.start + line_start + color.length + 15, "\x1b[0m");
                } else {
                    try seq.appendSlice("\x1b[0m");
                }
            }
            line.redraw = false;
        } else {
            ca = false;
        }
    }

    if (ca or ntp) {
        try js.jspc("\x1b" ++ "c");
    }
    if (ntp) {
        try js.jsprint(seq.items);
        seq.deinit();
    } else {
        ccpx = ccpxc;
        ccpy = ccpyc;
    }

    try js.jsexec("redraw_ne", 32);
}

pub fn setLine(index: i32, text: []const u8) void {
    if (lines.len > index) {
        @memset(lines[@intCast(index)].x, ' ');
        std.mem.copyForward(u8, lines[@intCast(index)].x, text);
        lines[@intCast(index)].redraw = true;
        clearColor(@intCast(index));
    }
}

pub fn genBottomBar(height: i32, widtho: i32) !void {
    const stars = try wa.alloc(u8, @intCast(js.sizex()));
    @memset(stars[@intCast(widtho)..(stars.len - @as(usize, @intCast(widtho)))], '*');
    @memset(stars[0..@intCast(widtho - 1)], ' ');
    setLine(js.sizey() - height, stars);
    for (1..@intCast(height)) |i| {
        var this_line = std.ArrayList(u8).init(wa);
        try this_line.appendSlice("\x1b[1000C");
        for (0..@intCast(widtho + 1)) |_| {
            try this_line.append('\x08');
        }
        try this_line.appendSlice("*\r");
        for (1..@intCast(widtho)) |_| {
            try this_line.append(' ');
        }
        try this_line.append('*');
        try this_line.appendSlice(" Testing");
        setLine(js.sizey() - @as(i32, @intCast(i)), try this_line.toOwnedSlice());
    }
}

pub fn insertText(x: usize, y: usize, text: []const u8) !usize {
    var line_it = std.mem.splitScalar(u8, text, '\n');
    var index: usize = 0;
    while (line_it.next()) |line| {
        std.mem.copyForwards(u8, lines[y + index].x[x..], line);
        index += 1;
    }
    return index;
}

pub fn fillScreen(char: u8) void {
    for (lines) |*line| {
        @memset(line.x, char);
        line.redraw = true;
    }
}

pub fn getCenterX(width: usize) usize {
    const halfwidth = @divTrunc(width, 2);
    return @divTrunc(@as(usize, @intCast(js.sizex())), 2) - halfwidth;
}

pub fn getTextWidth(text: []const u8) usize {
    var line_it = std.mem.splitScalar(u8, text, '\n');
    var max: usize = 0;
    while (line_it.next()) |line| {
        if (line.len > max) {
            max = line.len;
        }
    }
    return max;
}

pub fn addColor(line_y: usize, color: TextColor) !void {
    var color_arraylist = std.ArrayList(TextColor).fromOwnedSlice(wa, lines[line_y].colors);
    try color_arraylist.append(color);
    lines[line_y].colors = try color_arraylist.toOwnedSlice();
    lines[line_y].redraw = true;
}

pub fn clearColor(line_y: usize) void {
    wa.free(lines[line_y].colors);
    lines[line_y].colors = wa.alloc(TextColor, 0) catch unreachable;
}

pub fn setCursorType(cursor_type: CursorType) !void {
    if (cursor_type != .Hidden) {
        try js.jspc("\x1b[?25h");
    }
    switch (cursor_type) {
        .BlinkingBlock => {
            try js.jspc("\x1b[\x30 q");
        },
        .Block => {
            try js.jspc("\x1b[\x32 q");
        },
        .BlinkingUnderline => {
            try js.jspc("\x1b[\x33 q");
        },
        .Underline => {
            try js.jspc("\x1b[\x34 q");
        },
        .BlinkingBar => {
            try js.jspc("\x1b[\x35 q");
        },
        .Bar => {
            try js.jspc("\x1b[\x36 q");
        },
        .Hidden => {
            try js.jspc("\x1b[25l");
        },
    }
}

pub fn genBox(x: usize, y: usize, width: usize, height: usize, char: u8, color: TextColor) !void {
    @memset(lines[y].x[x .. x + width], char);
    @memset(lines[y + height].x[x .. x + width + 1], char);
    for (y..y + height + 1) |yindex| {
        lines[yindex].x[x] = char;
        lines[yindex].x[x + width] = char;
        try addColor(yindex, .{
            .start = @intCast(x),
            .length = @intCast(width + 1),
            .color = color.color,
            .txt_type = color.txt_type,
            .bg_color = color.bg_color,
            .bg_hi = color.bg_hi,
        });
        lines[yindex].redraw = true;
    }
}

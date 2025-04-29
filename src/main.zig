const std = @import("std");
const js = @import("js.zig");
const bl = @import("boilerplate.zig");
const art = @import("asciiart.zig");
const wa = std.heap.wasm_allocator;

const inkheart_asciiart = art.inkheart_txt;

var prev_framerate: u16 = 30;
var boxchar: u8 = 0;
var pbdc: u8 = 0;
var grade = 0;
const bdc = [_]u8{ '#', '*', '\\', '@', '+' };
const grades = [_][2]u8{ "A+", "A ", "A-", "B+", "B", "B-" };

export fn entry() void {
    main() catch {
        js.log("An error has occured! This probably is NOT good.") catch @panic("Failed to print error message!");
    };
}

fn main() !void {
    js.initCache(wa);
    try js.log("Starting WASM!");

    bl.lines = try wa.alloc(bl.Line, @intCast(js.sizey()));
    for (bl.lines) |*line| {
        line.* = bl.Line{
            .x = try wa.alloc(u8, @intCast(js.sizex())),
            .redraw = true,
            .colors = &.{},
        };
    }

    bl.fillScreen(' ');
    try js.jsexec("redraw_ne", 16);

    //try bl.genBottomBar(5, 10);
    try bl.setCursorType(.Hidden);
    try menu();
}

var creditsindx: usize = 0;
var credits_text = "Inkheart is a novel written in 2003 by Cornelia Funke which tells the tale of a bookbinder's daughter, Meggie, who finds herself in a story of magic, books, and magical books. Meggie's father, Mortimer, who \r\nMeggie refers to as \"Mo\", has the poweful ability to swap things from books with real-life things, which has not always ended well. While he was reading to his family one day, he accidentally swapped his wife \r\nand several objects in his house with characters from the story, who were understandably very upset. One of them, Capricorn, was an evil person, who enjoyed the real world more than his book. He searched for Mo and the book from which he came for a long time, until he found them. He burned the book, so he could never go back, and then forced Mo to conjure him things from books." ++ "Okay, now dumping all the RAM lolololololololololololololololololololol\x1b[0;30m";

export fn credits() void {
    js.jsprint((&credits_text[creditsindx])[0..1]) catch @panic("Error in JS exposed function.");
    creditsindx += 1;
    js.jsexec("credits", 30) catch @panic("Error in JS exposed function.");
}

export fn onKey(code: i32) void {
    if (ismenu and code == 13 and !issettings) {
        switch (selection) {
            0 => {
                game(69) catch @panic("Error in JS exposed function.");
            }, //New game
            1 => undefined, //Load game
            2 => {
                settings() catch @panic("Error in JS exposed function.");
            }, //Settings
            3 => {
                bl.lines.ptr = @ptrCast(&credits_text);
                js.jspc("\x1b" ++ "c") catch @panic("Error in JS exposed function.");
                js.jsexec("credits", 50) catch @panic("Error in JS exposed function.");
            }, //Credits
            4 => {
                js.execjs("window.location.reload();") catch @panic("Error in JS exposed function.");
            }, //Reload
            else => undefined,
        }
    } else if (code == 13 and issettings) {
        if (selection == 3) {
            menu() catch @panic("Error in JS exposed function.");
        } else if (selection == 4) {
            bl.framerate = prev_framerate;
            menu() catch @panic("Error in JS exposed function.");
        }
    }
}

var selection: usize = 1;
var ismenu = false;
var issettings = false;

export fn upKey() void {
    if (selection > 0 and ismenu) {
        const text_x = bl.getCenterX(bl.getTextWidth(inkheart_asciiart));
        bl.lines[(selection * 3) + 12].x[text_x + 8] = ' ';
        bl.lines[(selection * 3) + 12].redraw = true;
        selection -= 1;
        bl.lines[(selection * 3) + 12].x[text_x + 8] = '>';
        bl.lines[(selection * 3) + 12].redraw = true;
    }
}
export fn downKey() void {
    if (selection < 4 and ismenu) {
        const text_x = bl.getCenterX(bl.getTextWidth(inkheart_asciiart));
        bl.lines[(selection * 3) + 12].x[text_x + 8] = ' ';
        bl.lines[(selection * 3) + 12].redraw = true;
        selection += 1;
        bl.lines[(selection * 3) + 12].x[text_x + 8] = '>';
        bl.lines[(selection * 3) + 12].redraw = true;
    }
}
export fn leftKey() void {
    const text_x = bl.getCenterX(bl.getTextWidth(inkheart_asciiart));
    if (issettings) {
        switch (selection) {
            0 => {
                bl.framerate = @max(5, bl.framerate - 5);
                const frtext = std.fmt.allocPrint(wa, "Framerate: <{d:02}> FPS    ", .{bl.framerate}) catch @panic("Error in JS exposed function.");
                defer wa.free(frtext);
                _ = try bl.insertText(text_x + 10, 12, frtext);
            },
            1 => {
                if (boxchar > 0) {
                    boxchar -= 1;
                }
                settings() catch @panic("Error in JS exposed function.");
                downKey();
            },
            2 => undefined,
            3 => undefined,
            4 => undefined,
            else => undefined,
        }
    }
}
export fn rightKey() void {
    const text_x = bl.getCenterX(bl.getTextWidth(inkheart_asciiart));
    if (issettings) {
        switch (selection) {
            0 => {
                bl.framerate += 5;
                const frtext = std.fmt.allocPrint(wa, "Framerate: <{d:02}> FPS    ", .{bl.framerate}) catch @panic("Error in JS exposed function.");
                defer wa.free(frtext);
                _ = try bl.insertText(text_x + 10, 12, frtext);
            },
            1 => {
                boxchar = @min(boxchar + 1, bdc.len - 1);
                settings() catch @panic("Error in JS exposed function.");
            },
            2 => undefined, //Grade lolz
            3 => undefined, //Savequit
            4 => undefined, //Quit, handled by enter key
            else => undefined,
        }
    }
}

fn settings() !void {
    selection = 1;
    issettings = true;

    bl.fillScreen(' ');

    const text_y = 5;
    const text_x = bl.getCenterX(bl.getTextWidth(inkheart_asciiart));
    const linecount = try bl.insertText(text_x, text_y, inkheart_asciiart);

    for (bl.lines, 0..) |_, i| {
        bl.clearColor(i);
    }

    for (text_y..linecount + text_y) |line_y| {
        try bl.addColor(line_y, .{
            .color = .Red,
            .txt_type = .Intense,
        });
    }

    try bl.genBox(text_x, 10, bl.getTextWidth(inkheart_asciiart), 30, bdc[boxchar], .{ .color = .Yellow });

    const frtext = try std.fmt.allocPrint(wa, "Framerate: <{d:02}> FPS     ", .{bl.framerate});
    defer wa.free(frtext);
    _ = try bl.insertText(text_x + 10, 12, frtext);

    const bdtext = std.fmt.allocPrint(wa, "Box Character: <{c}>", .{bdc[boxchar]}) catch @panic("Error in JS exposed function.");
    defer wa.free(bdtext);
    _ = try bl.insertText(text_x + 10, 15, bdtext);

    _ = try bl.insertText(text_x + 10, 18, "Grade: ");

    _ = try bl.insertText(text_x + 10, 21, "Exit & Save");
    _ = try bl.insertText(text_x + 10, 24, "Exit & Don't Save");

    upKey();
}

fn menu() !void {
    selection = 1;
    ismenu = true;
    issettings = false;

    bl.fillScreen(' ');
    for (bl.lines, 0..) |_, i| {
        bl.clearColor(i);
    }

    const text_y = 5;
    const text_x = bl.getCenterX(bl.getTextWidth(inkheart_asciiart));
    const linecount = try bl.insertText(text_x, text_y, inkheart_asciiart);

    for (text_y..linecount + text_y) |line_y| {
        try bl.addColor(line_y, .{
            .color = .Red,
            .txt_type = .Intense,
        });
    }

    try bl.genBox(text_x, 10, bl.getTextWidth(inkheart_asciiart), 30, bdc[boxchar], .{ .color = .Yellow });
    _ = try bl.insertText(text_x + 10, 12, "New Game [Deletes save!!]");
    _ = try bl.insertText(text_x + 10, 15, "Load Previous Game");
    _ = try bl.insertText(text_x + 10, 18, "Open Settings");
    _ = try bl.insertText(text_x + 10, 21, "Credits");
    _ = try bl.insertText(text_x + 10, 24, "Reload");

    upKey();
}

fn game(seed: usize) !void {
    _ = seed;
    ismenu = false;
    issettings = false;

    bl.fillScreen(' ');
    for (bl.lines, 0..) |_, i| {
        bl.clearColor(i);
    }

    try bl.runAnim(10, 10, &art.player_running_right ** 40, 6);
}

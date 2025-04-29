pub extern fn data(i32, i32) i32;
pub extern fn free(i32) void;
pub extern fn print(i32) void;
pub extern fn exec(i32) void;
pub extern fn read(i32, i32) i32;
pub extern fn run(i32, i32) void;
pub extern fn tone(i32, i32, i32) void;
pub extern fn sizex() i32;
pub extern fn sizey() i32;
pub extern fn jlog(i32) void;
pub extern fn logn(i32) void;

const std = @import("std");

var jscache: std.StringHashMap(i32) = undefined;
var wa: std.mem.Allocator = undefined;

pub fn jsdata(slice: []const u8) !i32 {
    const heap = try wa.alloc(u8, slice.len);
    @memcpy(heap[0..slice.len], slice);
    const aptr = data(@intCast(@intFromPtr(heap.ptr)), @intCast(heap.len));
    wa.free(heap);
    return aptr;
}

pub fn jsprint(str: []const u8) !void {
    const aptr = try jsdata(str);
    print(aptr);
    free(aptr);
}

pub fn jspc(str: []const u8) !void {
    if (jscache.get(str)) |aptr| {
        print(aptr);
    } else {
        const aptr = try jsdata(str);
        print(aptr);
        try jscache.put(str, aptr);
    }
}

pub fn jsexec(fn_name: []const u8, time: i32) !void {
    if (jscache.get(fn_name)) |aptr| {
        run(aptr, time);
    } else {
        const aptr = try jsdata(fn_name);
        run(aptr, time);
        try jscache.put(fn_name, aptr);
    }
}

pub fn execjs(js_code: []const u8) !void {
    if (jscache.get(js_code)) |aptr| {
        exec(aptr);
    } else {
        const aptr = try jsdata(js_code);
        exec(aptr);
        try jscache.put(js_code, aptr);
    }
}

pub fn execjs_nc(js_code: []const u8) !void {
    const aptr = try jsdata(js_code);
    exec(aptr);
}

pub fn log(str: []const u8) !void {
    const aptr = try jsdata(str);
    jlog(aptr);
    free(aptr);
}

pub fn initCache(allocator: std.mem.Allocator) void {
    jscache = std.StringHashMap(i32).init(allocator);
    wa = allocator;
}

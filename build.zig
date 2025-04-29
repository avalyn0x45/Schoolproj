const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = std.Target.Query{ .cpu_arch = .wasm64, .os_tag = .freestanding };
    const optimize = .Debug;

    const exe_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = b.resolveTargetQuery(target),
        .optimize = optimize,
    });
    const exe = b.addExecutable(.{
        .name = "inkheart",
        .root_module = exe_mod,
    });

    exe.rdynamic = true;
    exe.entry = .disabled;

    b.installArtifact(exe);
}

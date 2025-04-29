const bl = @import("boilerplate.zig");
pub const smile_face =
    \\   _______
    \\  /       \
    \\ / ()   () \
    \\|           |
    \\|           |
    \\ \  \___/  /
    \\  \_______/
;
pub const frown_face =
    \\   _______
    \\  /       \
    \\ / ()   () \
    \\|           |
    \\|    ___    |
    \\ \  /   \  /
    \\  \_______/
;
pub const neutral_face =
    \\   _______
    \\  /       \
    \\ / ()   () \
    \\|           |
    \\|           |
    \\ \   ___   /
    \\  \_______/
;
pub const dead_face =
    \\   _______
    \\  /       \
    \\ / (X) (X) \
    \\|           |
    \\|           |
    \\ \  XXXXX  /
    \\  \_______/
;

pub const player =
    \\ 0 
    \\/|\
    \\/ \
;

pub const player_dead =
    \\ x 
    \\/|\
    \\/ \
;

pub const player_jumping =
    \\ 0 
    \\/|\
    \\| |
;

pub const player_arms_down =
    \\ 0 
    \\|||
    \\/ \
;

pub const player_jumping_arms_down =
    \\ 0 
    \\|||
    \\| |
;

pub const player_right_leg_in =
    \\ 0 
    \\/|\
    \\/ |
;

pub const player_left_leg_in =
    \\ 0 
    \\/|\
    \\| \
;

pub const player_right_leg_inverted =
    \\ 0
    \\/|\
    \\/ /
;

pub const player_left_leg_inverted =
    \\ 0
    \\/|\
    \\\ \
;

pub const player_right_leg_inverted_left_in =
    \\ 0
    \\/|\
    \\| /
;

pub const player_left_leg_inverted_right_in =
    \\ 0
    \\/|\
    \\\ |
;

pub const car_facing_right =
    \\    _____
    \\,--/   | \__
    \\==(0)===(0)=/
;

pub const car_facing_left =
    \\    _____
    \\ __/ |   \--,
    \\\=(0)===(0)==
;

pub const inkheart_txt = " _        \\     _                           .   \n | , __   |   , /        ___    ___  .___  _/_  \n | |'  `. |  /  |,---. .'   `  /   ` /   \\  |   \n | |    | |-<   |'   ` |----' |    | |   '  |   \n / /    | /  \\_ /    | `.___, `.__/| /      \\__/";

pub const player_jumping_jacks = [_]bl.AnimFrame{
    .{ .text = player, .deltax = 0, .deltay = 0, .colors = &.{}, .height = 3 },
    .{ .text = player_jumping, .deltax = 0, .deltay = -1, .colors = &.{}, .height = 3 },
    .{ .text = player_jumping_arms_down, .deltax = 0, .deltay = -1, .colors = &.{}, .height = 3 },
    .{ .text = player_jumping, .deltax = 0, .deltay = 1, .colors = &.{}, .height = 3 },
    .{ .text = player, .deltax = 0, .deltay = 1, .colors = &.{}, .height = 3 },
};

pub const player_running_right = [_]bl.AnimFrame{
    .{ .text = player_right_leg_inverted, .deltax = 1, .deltay = 0, .colors = &.{}, .height = 3 },
    .{ .text = player_right_leg_inverted_left_in, .deltax = 1, .deltay = 0, .colors = &.{}, .height = 3 },
    .{ .text = player_right_leg_inverted, .deltax = 1, .deltay = 0, .colors = &.{}, .height = 3 },
    .{ .text = player_right_leg_in, .deltax = 1, .deltay = 0, .colors = &.{}, .height = 3 },
};

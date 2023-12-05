const std = @import("std");
const tic = @import("tic");

const State = enum {
    empty,
    tilled,
    planted,
    watered,
    growing,
    grown,
    flowering,
};

const Plot = struct {
    s: State = .empty,
    x: u8 = 0,
    y: u8 = 0,
    g: u32 = 0,

    fn new(x: u8, y: u8) Plot {
        return .{
            .x = x,
            .y = y,
        };
    }

    fn update(self: *Plot) void {
        self.g += 1;

        if (self.g < 300) return;

        const x: i32 = @intCast(self.x);
        const y: i32 = @intCast(self.y);

        switch (tic.mget(x, y)) {
            4 => self.state(.growing),
            5 => self.mset(6),
            6 => self.state(.grown),
            7 => self.mset(8),
            8 => self.state(.flowering),
            else => {},
        }

        self.g = 0;
    }

    fn state(self: *Plot, s: State) void {
        self.s = s;

        switch (self.s) {
            .empty => self.mset(0),
            .tilled => self.mset(2),
            .planted => self.mset(3),
            .watered => self.mset(4),
            .growing => self.mset(5),
            .grown => self.mset(7),
            .flowering => self.mset(9),
        }
    }

    fn mset(self: *Plot, tile_id: u32) void {
        tic.mset(self.x, self.y, tile_id);
    }
};

const Inventory = struct {
    seeds: u16 = 3,
    carrots: u16 = 0,

    fn draw(self: *Inventory) void {
        spr(19, 22, 0, .{});
        printf(" {d}", .{self.seeds}, 23, 0, .{ .small_font = true, .color = 2 });
        spr(18, 26, 0, .{});
        printf(" {d}", .{self.carrots}, 27, 0, .{ .small_font = true, .color = 2 });
    }
};

const Farm = struct {
    bot: Bot = .{},
    inventory: Inventory = .{},
    plots: [16 * 30]Plot = undefined,

    fn start(self: *Farm) void {
        for (1..17) |y| {
            for (0..30) |x| {
                self.plots[offset(x, y)] = Plot.new(@intCast(x), @intCast(y));
            }
        }
    }

    fn update(self: *Farm) void {
        if (tic.pressed(4)) self.action();

        self.bot.update();

        for (&self.plots) |*p| {
            p.update();
        }
    }

    fn draw(self: *Farm) void {
        tic.cls(0);
        tic.map(.{});
        self.inventory.draw();
        self.bot.draw();
    }

    fn action(self: *Farm) void {
        const p = self.plot();

        switch (tic.mget(p.x, p.y)) {
            0, 1 => self.till(p),
            2 => self.plant(p),
            3 => self.water(p),
            7, 8, 9 => self.pick(p),
            else => {},
        }
    }

    fn till(_: *Farm, p: *Plot) void {
        p.state(.tilled);
    }

    fn plant(self: *Farm, p: *Plot) void {
        if (self.inventory.seeds > 0) {
            p.state(.planted);
            self.inventory.seeds -|= 1;
        } else if (self.inventory.carrots > 0) {
            p.state(.grown);
            self.inventory.carrots -|= 1;
        }
    }

    fn water(_: *Farm, p: *Plot) void {
        p.state(.watered);
    }

    fn pick(self: *Farm, p: *Plot) void {
        switch (p.s) {
            .grown => self.inventory.carrots +|= 1,
            .flowering => self.inventory.seeds +|= 2,
            else => {},
        }

        p.state(.empty);
    }

    fn plot(self: *Farm) *Plot {
        return &self.plots[offset(self.bot.x, self.bot.y)];
    }
};

var farm = Farm{};

const Bot = struct {
    x: u8 = 14,
    y: u8 = 8,

    fn update(b: *Bot) void {
        if (tic.pressed(0) and b.y > 1) b.y -|= 1;
        if (tic.pressed(1) and b.y < 16) b.y +|= 1;
        if (tic.pressed(2)) b.x -|= 1;
        if (tic.pressed(3) and b.x < 29) b.x +|= 1;
    }

    fn draw(b: *Bot) void {
        spr(15, b.x, b.y, .{ .transparent = &[_]u8{0} });
    }
};

fn printf(comptime fmt: []const u8, fmtargs: anytype, x: i32, y: i32, args: tic.PrintArgs) void {
    _ = tic.printf(fmt, fmtargs, x * 8, y * 8, args);
}

fn spr(id: i32, x: i32, y: i32, args: anytype) void {
    tic.spr(id, x * 8, y * 8, args);
}

fn offset(x: usize, y: usize) usize {
    return x + ((y - 1) * 30);
}

export fn BOOT() void {
    farm.start();
}

export fn TIC() void {
    farm.update();
    farm.draw();
}

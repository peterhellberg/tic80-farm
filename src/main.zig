const tic = @import("tic");

const Farm = struct {
    bot: Bot = .{},

    seeds: u16 = 3,
    carrots: u16 = 0,
    growth: u16 = 0,

    fn update(self: *Farm) void {
        if (tic.pressed(4)) self.action();

        self.bot.update();

        self.grow();
    }

    fn grow(self: *Farm) void {
        self.growth += 1;

        if (self.growth < 300) return;

        for (0..30) |X| {
            for (0..17) |Y| {
                const x: i32 = @intCast(X);
                const y: i32 = @intCast(Y);

                switch (tic.mget(x, y)) {
                    4 => tic.mset(x, y, 5),
                    5 => tic.mset(x, y, 6),
                    6 => tic.mset(x, y, 7),
                    else => {},
                }
            }
        }

        self.growth = 0;
    }

    fn draw(self: *Farm) void {
        tic.cls(0);
        tic.map(.{});
        self.status();
        self.bot.draw();
    }

    fn status(self: *Farm) void {
        spr(19, 22, 0, .{});
        printf(" {d}", .{self.seeds}, 23, 0, .{ .small_font = true, .color = 2 });
        spr(18, 26, 0, .{});
        printf(" {d}", .{self.carrots}, 27, 0, .{ .small_font = true, .color = 2 });
    }

    fn action(self: *Farm) void {
        const x = self.bot.x;
        const y = self.bot.y;

        switch (tic.mget(x, y)) {
            0, 1 => self.till(),
            2 => self.plant(),
            3 => self.water(),
            7 => self.pick(),
            else => {},
        }
    }

    fn till(self: *Farm) void {
        tic.mset(self.bot.x, self.bot.y, 2);
    }

    fn plant(self: *Farm) void {
        if (self.seeds > 0) {
            tic.mset(self.bot.x, self.bot.y, 3);
            self.seeds -|= 1;
        }
    }

    fn water(self: *Farm) void {
        tic.mset(self.bot.x, self.bot.y, 4);
    }

    fn pick(self: *Farm) void {
        tic.mset(self.bot.x, self.bot.y, 2);
        self.carrots +|= 1;
        self.seeds +|= 3;
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

export fn TIC() void {
    farm.update();
    farm.draw();
}

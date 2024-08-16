// This is a sample middleware

// Generally, using a custom Handler with a dispatch method provides the most
// flexibility and should be your first approach (see the dispatcher.zig example).

// Middleware provide an alternative way to manipulate the request/response and
// is well suited if you need different middleware (or middleware configurations)
// for different routes.

const std = @import("std");
const httpz = @import("httpz");

const Logger = @This();

query: bool,

// Must define an `init` method, which will accept your Congi
pub fn init(config: Config) Logger {
    return .{
        .query = config.query,
    };
}

pub fn execute(self: *const Logger, req: *httpz.Request, res: *httpz.Response, executor: anytype) !void {
    // generally better to use an std.time.Timer to measure elapsed time
    // but we need the "start" time for our log anyways, so while this might occasionally
    // report wrong/strange "elapsed" time, it's simpler to do.
    const start = std.time.microTimestamp();

    defer {
        const elapsed = std.time.microTimestamp() - start;
        std.log.info("{d}\t{s}?{s}\t{d}\t{d}us", .{start, req.url.path, if (self.query) req.url.query else "", res.status, elapsed});
    }

    // If you don't call executor.next(), there will be no further processing of
    // the request and we'll go straight to writing the response.
    return executor.next();
}

// Must defined a pub config structure, even if it's empty
pub const Config = struct {
   query: bool,
};

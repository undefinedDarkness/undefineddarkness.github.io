"use strict";
var __assign = (this && this.__assign) || function () {
    __assign = Object.assign || function(t) {
        for (var s, i = 1, n = arguments.length; i < n; i++) {
            s = arguments[i];
            for (var p in s) if (Object.prototype.hasOwnProperty.call(s, p))
                t[p] = s[p];
        }
        return t;
    };
    return __assign.apply(this, arguments);
};
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    Object.defineProperty(o, k2, { enumerable: true, get: function() { return m[k]; } });
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || function (mod) {
    if (mod && mod.__esModule) return mod;
    var result = {};
    if (mod != null) for (var k in mod) if (k !== "default" && Object.prototype.hasOwnProperty.call(mod, k)) __createBinding(result, mod, k);
    __setModuleDefault(result, mod);
    return result;
};
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __generator = (this && this.__generator) || function (thisArg, body) {
    var _ = { label: 0, sent: function() { if (t[0] & 1) throw t[1]; return t[1]; }, trys: [], ops: [] }, f, y, t, g;
    return g = { next: verb(0), "throw": verb(1), "return": verb(2) }, typeof Symbol === "function" && (g[Symbol.iterator] = function() { return this; }), g;
    function verb(n) { return function (v) { return step([n, v]); }; }
    function step(op) {
        if (f) throw new TypeError("Generator is already executing.");
        while (_) try {
            if (f = 1, y && (t = op[0] & 2 ? y["return"] : op[0] ? y["throw"] || ((t = y["return"]) && t.call(y), 0) : y.next) && !(t = t.call(y, op[1])).done) return t;
            if (y = 0, t) op = [op[0] & 2, t.value];
            switch (op[0]) {
                case 0: case 1: t = op; break;
                case 4: _.label++; return { value: op[1], done: false };
                case 5: _.label++; y = op[1]; op = [0]; continue;
                case 7: op = _.ops.pop(); _.trys.pop(); continue;
                default:
                    if (!(t = _.trys, t = t.length > 0 && t[t.length - 1]) && (op[0] === 6 || op[0] === 2)) { _ = 0; continue; }
                    if (op[0] === 3 && (!t || (op[1] > t[0] && op[1] < t[3]))) { _.label = op[1]; break; }
                    if (op[0] === 6 && _.label < t[1]) { _.label = t[1]; t = op; break; }
                    if (t && _.label < t[2]) { _.label = t[2]; _.ops.push(op); break; }
                    if (t[2]) _.ops.pop();
                    _.trys.pop(); continue;
            }
            op = body.call(thisArg, _);
        } catch (e) { op = [6, e]; y = 0; } finally { f = t = 0; }
        if (op[0] & 5) throw op[1]; return { value: op[0] ? op[1] : void 0, done: true };
    }
};
var __read = (this && this.__read) || function (o, n) {
    var m = typeof Symbol === "function" && o[Symbol.iterator];
    if (!m) return o;
    var i = m.call(o), r, ar = [], e;
    try {
        while ((n === void 0 || n-- > 0) && !(r = i.next()).done) ar.push(r.value);
    }
    catch (error) { e = { error: error }; }
    finally {
        try {
            if (r && !r.done && (m = i["return"])) m.call(i);
        }
        finally { if (e) throw e.error; }
    }
    return ar;
};
var __values = (this && this.__values) || function(o) {
    var s = typeof Symbol === "function" && Symbol.iterator, m = s && o[s], i = 0;
    if (m) return m.call(o);
    if (o && typeof o.length === "number") return {
        next: function () {
            if (o && i >= o.length) o = void 0;
            return { value: o && o[i++], done: !o };
        }
    };
    throw new TypeError(s ? "Object is not iterable." : "Symbol.iterator is not defined.");
};
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.length = exports.warn = exports.fail = exports.TAB = void 0;
var fs_1 = require("fs");
var perf_hooks_1 = require("perf_hooks");
var _builtin = __importStar(require("./builtin"));
var string_replace_async_1 = __importDefault(require("string-replace-async"));
var stringz_1 = require("stringz");
var builtin = __assign({}, _builtin);
exports.TAB = '        ';
var Importance;
(function (Importance) {
    Importance[Importance["Anywhere"] = 0] = "Anywhere";
    Importance[Importance["ResolveChildren"] = 1] = "ResolveChildren";
    Importance[Importance["WillResolve"] = 2] = "WillResolve";
    Importance[Importance["RunAtEnd"] = 3] = "RunAtEnd";
})(Importance || (Importance = {}));
var fail = function (msg, do_exit) {
    if (do_exit === void 0) { do_exit = true; }
    console.error('\u001b[1m\u001b[31m[ERROR]\u001b[0m ' + msg);
    do_exit ? process.exit(1) : null;
};
exports.fail = fail;
var warn = function (msg) {
    console.error('\u001b[1m\u001b[33m[WARNING]\u001b[0m ' + msg);
};
exports.warn = warn;
var length = function (m) {
    // TODO: possible extra math here
    return stringz_1.length(m);
};
exports.length = length;
function filterObj(obj, test_) {
    return Object.fromEntries(Object.entries(obj).filter(function (_a) {
        var _b = __read(_a, 2), _ = _b[0], v = _b[1];
        return test_(v);
    }));
}
function useTransformer(data, obj, append_args) {
    if (append_args === void 0) { append_args = ''; }
    return __awaiter(this, void 0, void 0, function () {
        var _this = this;
        return __generator(this, function (_a) {
            switch (_a.label) {
                case 0: return [4 /*yield*/, string_replace_async_1.default(data, new RegExp("[\t ]*#(" + Object.keys(obj).map(function (x) { return x.toUpperCase().replace('_', '-'); }).join('|') + ")+([^\n]+)?([^]+?)#END \\1", 'g'), function (match, tag, args, value) { return __awaiter(_this, void 0, void 0, function () {
                        return __generator(this, function (_a) {
                            tag = tag.toLowerCase().replaceAll('-', '_');
                            args = (args !== null && args !== void 0 ? args : '') + append_args;
                            try {
                                return [2 /*return*/, (obj[tag] ? obj[tag].fn(value, args) : value)];
                            }
                            catch (err) {
                                exports.fail("Transformer: " + tag + " failed to transform: " + value + " ~ " + err);
                                return [2 /*return*/, match];
                            }
                            return [2 /*return*/];
                        });
                    }); })];
                case 1: return [2 /*return*/, _a.sent()];
            }
        });
    });
}
var Context = /** @class */ (function () {
    function Context(file_path) {
        this.data = fs_1.readFileSync(file_path, 'utf-8');
        this.inlineTransformers = filterObj(builtin, function (v) { return v.inline && v.importance == 0; });
        this.simpleBlockTransformers = filterObj(builtin, function (v) { return v.importance == 0 && !v.inline; });
        this.complexBlockTransformers = filterObj(builtin, function (v) { return v.importance == 2; });
        this.resolvedBlockTransformers = filterObj(builtin, function (v) { return v.importance == 1; });
        this.endBlockTransformers = filterObj(builtin, function (v) { return v.importance == 3; });
    }
    Context.prototype.preTransform = function () {
        if (process.argv.includes("--ascii")) {
            exports.warn("Using ascii only chars, in accordance with `--ascii`");
            this.data = this.data.replace(/[^\x00-\x7F]/g, "");
        }
        if (!process.argv.includes("--no-fix-emoji")) {
            exports.warn("Stripping all emojis (they break boxes), to ignore use `--no-fix-emoji`");
            this.data = this.data.replace(/\p{Extended_Pictographic}/u, "");
        }
        this.data = this.data.replaceAll('\t', exports.TAB);
    };
    Context.prototype.transform = function () {
        return __awaiter(this, void 0, void 0, function () {
            var matchInline, _a, _b, _c, getLongest, longest, _d, _e;
            var _this = this;
            return __generator(this, function (_f) {
                switch (_f.label) {
                    case 0:
                        // Replace Emoji & Unicode (if --ascii)
                        this.preTransform();
                        matchInline = /#(\w+) (.*)#/g;
                        _f.label = 1;
                    case 1:
                        if (!true) return [3 /*break*/, 3];
                        _a = this;
                        return [4 /*yield*/, string_replace_async_1.default(this.data, matchInline, function (_, tag, value) { return __awaiter(_this, void 0, void 0, function () {
                                return __generator(this, function (_a) {
                                    tag = tag.toLowerCase();
                                    return [2 /*return*/, (this.inlineTransformers[tag] ? this.inlineTransformers[tag].fn(value.trim()) : value)];
                                });
                            }); })];
                    case 2:
                        _a.data = _f.sent();
                        if (!matchInline.test(this.data)) {
                            return [3 /*break*/, 3];
                        }
                        return [3 /*break*/, 1];
                    case 3:
                        _b = this;
                        return [4 /*yield*/, useTransformer(this.data, this.simpleBlockTransformers)
                            // -- Complex Processing -- 
                        ];
                    case 4:
                        _b.data = _f.sent();
                        // -- Complex Processing -- 
                        _c = this;
                        return [4 /*yield*/, useTransformer(this.data, this.complexBlockTransformers)
                            // get longest line
                        ];
                    case 5:
                        // -- Complex Processing -- 
                        _c.data = _f.sent();
                        getLongest = function (longest, data) {
                            var e_1, _a;
                            if (longest === void 0) { longest = 0; }
                            if (data === void 0) { data = _this.data; }
                            try {
                                for (var _b = __values(data.split('\n')), _c = _b.next(); !_c.done; _c = _b.next()) {
                                    var line = _c.value;
                                    var l = exports.length(line);
                                    if (l > longest) {
                                        longest = l;
                                    }
                                }
                            }
                            catch (e_1_1) { e_1 = { error: e_1_1 }; }
                            finally {
                                try {
                                    if (_c && !_c.done && (_a = _b.return)) _a.call(_b);
                                }
                                finally { if (e_1) throw e_1.error; }
                            }
                            return longest;
                        };
                        longest = getLongest();
                        // -- Relative Processing --
                        _d = this;
                        return [4 /*yield*/, useTransformer(this.data, this.resolvedBlockTransformers, longest.toString())];
                    case 6:
                        // -- Relative Processing --
                        _d.data = _f.sent();
                        longest = getLongest();
                        _e = this;
                        return [4 /*yield*/, useTransformer(this.data, this.endBlockTransformers, longest.toString())];
                    case 7:
                        _e.data = _f.sent();
                        return [2 /*return*/];
                }
            });
        });
    };
    return Context;
}());
function main() {
    return __awaiter(this, void 0, void 0, function () {
        var instance, start, end;
        return __generator(this, function (_a) {
            switch (_a.label) {
                case 0:
                    instance = new Context(process.argv[2]);
                    start = perf_hooks_1.performance.now();
                    return [4 /*yield*/, instance.transform()];
                case 1:
                    _a.sent();
                    end = perf_hooks_1.performance.now();
                    console.log(instance.data);
                    console.error("Finished transforming in \u001B[1m" + Math.floor(end - start) + "\u001B[0mms");
                    return [2 /*return*/];
            }
        });
    });
}
main();

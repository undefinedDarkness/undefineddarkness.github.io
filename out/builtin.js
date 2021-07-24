"use strict";
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
var __spreadArray = (this && this.__spreadArray) || function (to, from) {
    for (var i = 0, il = from.length, j = to.length; i < il; i++, j++)
        to[j] = from[i];
    return to;
};
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.box = exports.preserve_center = exports.center = exports.list = exports.html_aware = exports.table = exports.code = exports.script = exports.env = exports.command = void 0;
var util_1 = require("util");
var child_process_1 = require("child_process");
var exec = util_1.promisify(child_process_1.exec);
var promises_1 = require("fs/promises");
//@ts-ignore
var ascii_table_1 = __importDefault(require("ascii-table"));
var main_1 = require("./main");
var stringz_1 = require("stringz");
var WEB = process.argv.includes('--web');
var UNICODE = !process.argv.includes("--ascii");
var BOX_CHARS = {
    v_fill: UNICODE ? '│' : '|',
    h_fill: UNICODE ? '─' : '-',
    h_top_corner_l: UNICODE ? '┌' : '+',
    h_top_corner_r: UNICODE ? '┐' : '+',
    h_bottom_corner_l: UNICODE ? '└' : '+',
    h_bottom_corner_r: UNICODE ? '┘' : '+',
    top_table_corner: '.',
    bottom_table_corner: '\''
};
/** Inline Transforms {{{ */
exports.command = {
    fn: function (input) { return __awaiter(void 0, void 0, void 0, function () {
        return __generator(this, function (_a) {
            switch (_a.label) {
                case 0: return [4 /*yield*/, exec(input)];
                case 1: return [2 /*return*/, (_a.sent()).stdout];
            }
        });
    }); },
    inline: true,
    importance: 0
};
exports.env = {
    fn: function (input) { return __awaiter(void 0, void 0, void 0, function () {
        var _a;
        return __generator(this, function (_b) {
            return [2 /*return*/, (_a = process.env[input]) !== null && _a !== void 0 ? _a : input];
        });
    }); },
    inline: true,
    importance: 0
};
/*}}}*/
exports.script = {
    fn: function (input) { return __awaiter(void 0, void 0, void 0, function () {
        var file_path, x, err_1;
        return __generator(this, function (_a) {
            switch (_a.label) {
                case 0:
                    file_path = '/tmp/' + Number(new Date()) // TODO: Make better
                    ;
                    return [4 /*yield*/, promises_1.writeFile(file_path, '#!/usr/bin/env bash\n' + input)];
                case 1:
                    _a.sent();
                    _a.label = 2;
                case 2:
                    _a.trys.push([2, 4, , 5]);
                    return [4 /*yield*/, exec("sh " + file_path)];
                case 3:
                    x = (_a.sent()).stdout;
                    return [3 /*break*/, 5];
                case 4:
                    err_1 = _a.sent();
                    main_1.fail('While executing embedded script: ' + err_1.stderr, false);
                    x = input;
                    return [3 /*break*/, 5];
                case 5:
                    promises_1.unlink(file_path);
                    return [2 /*return*/, x];
            }
        });
    }); },
    inline: false,
    importance: 0
};
exports.code = {
    fn: function (input, args) {
        if (args === void 0) { args = ""; }
        return __awaiter(void 0, void 0, void 0, function () {
            var type;
            return __generator(this, function (_a) {
                type = args.split(main_1.TAB)[0];
                return [2 /*return*/, input.split('\n').map(function (line, index) {
                        var _a;
                        var block_indentation = "";
                        if (args.includes("INDENT-PRE-INDEX")) {
                            block_indentation = ((_a = line.match(/^\s*/)) !== null && _a !== void 0 ? _a : [''])[0];
                            line = line.trim();
                        }
                        switch (type) {
                            case 'long':
                                return block_indentation + index + '│ ' + line;
                            default:
                                return block_indentation + '> ' + line;
                        }
                    }).join('\n')];
            });
        });
    },
    inline: false,
    importance: 0
};
exports.table = {
    fn: function (input, args) {
        if (args === void 0) { args = ""; }
        return __awaiter(void 0, void 0, void 0, function () {
            var columns, table;
            return __generator(this, function (_a) {
                columns = args.split(main_1.TAB);
                table = new ascii_table_1.default('');
                table.setHeading.apply(table, __spreadArray([], __read(columns)));
                table.setBorder(BOX_CHARS.v_fill, BOX_CHARS.h_fill, BOX_CHARS.top_table_corner, BOX_CHARS.bottom_table_corner);
                input.split('\n').forEach(function (row) { return table.addRow.apply(table, __spreadArray([], __read(row.split(main_1.TAB)))); });
                return [2 /*return*/, table.toString()];
            });
        });
    },
    inline: false,
    importance: 0
};
exports.html_aware = {
    inline: false,
    importance: 3,
    fn: function (input, args) {
        if (args === void 0) { args = ""; }
        return __awaiter(void 0, void 0, void 0, function () {
            return __generator(this, function (_a) {
                return [2 /*return*/, input.replaceAll('<', '&lt;').replaceAll('>', '&gt;')];
            });
        });
    }
};
exports.list = {
    fn: function (input, type) {
        if (type === void 0) { type = ""; }
        return __awaiter(void 0, void 0, void 0, function () {
            var i_1;
            return __generator(this, function (_a) {
                switch (type) {
                    case "number": {
                        i_1 = 0;
                        return [2 /*return*/, input.replace(/^-/gm, function () { i_1 += 1; return i_1.toString(); })];
                    }
                    default:
                        return [2 /*return*/, input.replace(/^-/gm, main_1.length(type) > 0 ? type : '>')];
                }
                return [2 /*return*/];
            });
        });
    },
    inline: false,
    importance: 0
};
// TOOD: merge center & preserve center
exports.center = {
    importance: 1,
    inline: false,
    fn: function (input, args) {
        if (args === void 0) { args = ''; }
        return __awaiter(void 0, void 0, void 0, function () {
            var longest_line;
            return __generator(this, function (_a) {
                longest_line = parseInt(args);
                return [2 /*return*/, input.split('\n').map(function (line) { return stringz_1.limit(line, (longest_line + main_1.length(line)) / 2, ' ', 'left'); }).join('\n')];
            });
        });
    }
};
exports.preserve_center = {
    importance: 3,
    inline: false,
    fn: function (input, args) {
        if (args === void 0) { args = ''; }
        return __awaiter(void 0, void 0, void 0, function () {
            var document_longest_line, inputs, value_longest_line;
            return __generator(this, function (_a) {
                if (WEB) {
                    return [2 /*return*/, "<div style='display:flex;justify-content:center;align-items:center;'><div>" + input + "</div></div>"];
                }
                document_longest_line = parseInt(args.trim());
                inputs = input.split('\n');
                value_longest_line = inputs.reduce(function (a, v) { return a = main_1.length(v) > a ? main_1.length(v) : a; }, 0);
                return [2 /*return*/, inputs.map(function (line) { return "" + ' '.repeat((document_longest_line + value_longest_line) / 4) + line; }).join('\n')];
            });
        });
    }
};
exports.box = {
    fn: function (input, args) {
        if (args === void 0) { args = ''; }
        return __awaiter(void 0, void 0, void 0, function () {
            var lines, longest, end_line, start_line;
            return __generator(this, function (_a) {
                if (WEB) {
                    input = input.replace(/#RIGHT-ALIGN([^]+?)#END RIGHT-ALIGN/, function (_, v) {
                        return "<div style='text-align:right'>" + v + "</div>";
                    });
                    return [2 /*return*/, "<div style=\"border: 1px solid; padding: 8px 16px;\">" + input + "</div>"];
                }
                lines = input.split('\n');
                longest = lines.reduce(function (a, v) { return a = main_1.length(v) > a ? main_1.length(v) : a; }, 0);
                longest = 4 + longest + 4;
                end_line = BOX_CHARS.h_bottom_corner_l + BOX_CHARS.h_fill.repeat(longest + 1) + BOX_CHARS.h_bottom_corner_r;
                start_line = BOX_CHARS.h_top_corner_l + stringz_1.limit(stringz_1.limit(args, (1 + longest + main_1.length(args)) / 2, BOX_CHARS.h_fill, 'left'), longest + 1, BOX_CHARS.h_fill, 'right') + BOX_CHARS.h_top_corner_r;
                lines = input.replace(/#RIGHT-ALIGN([^]+?)#END RIGHT-ALIGN/, function (_, v) {
                    v = v.trim();
                    return v.split('\n').map(function (l) { return stringz_1.limit(l, longest - 4, ' ', 'left'); }).join('\n');
                }).split('\n');
                lines = lines.map(function (line) {
                    return line.length >= longest ? line : BOX_CHARS.v_fill + '  ' + stringz_1.limit(line, longest - 4, ' ', 'right') + '   ' + BOX_CHARS.v_fill;
                });
                lines.unshift(start_line);
                lines.push(end_line);
                return [2 /*return*/, lines.join('\n')];
            });
        });
    },
    inline: false,
    importance: 2
};
//export { command, code, box, center }

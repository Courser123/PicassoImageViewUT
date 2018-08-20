var global = this;
var picasso_view = (function (exports) {
'use strict';

exports = global;/*! *****************************************************************************
Copyright (c) Microsoft Corporation. All rights reserved.
Licensed under the Apache License, Version 2.0 (the "License"); you may not use
this file except in compliance with the License. You may obtain a copy of the
License at http://www.apache.org/licenses/LICENSE-2.0

THIS CODE IS PROVIDED ON AN *AS IS* BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
KIND, EITHER EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION ANY IMPLIED
WARRANTIES OR CONDITIONS OF TITLE, FITNESS FOR A PARTICULAR PURPOSE,
MERCHANTABLITY OR NON-INFRINGEMENT.

See the Apache Version 2.0 License for specific language governing permissions
and limitations under the License.
***************************************************************************** */
/* global global, define, System, Reflect, Promise */
var __extends;
var __assign;
var __rest;
var __decorate;
var __param;
var __metadata;
var __awaiter;
var __generator;
var __exportStar;
var __values;
var __read;
var __spread;
var __await;
var __asyncGenerator;
var __asyncDelegator;
var __asyncValues;
(function (factory) {
    var root = typeof global === "object" ? global : typeof self === "object" ? self : typeof this === "object" ? this : {};
    if (typeof define === "function" && define.amd) {
        define("tslib", ["exports"], function (exports) { factory(createExporter(root, createExporter(exports))); });
    }
    else if (typeof module === "object" && typeof module.exports === "object") {
        factory(createExporter(root, createExporter(module.exports)));
    }
    else {
        factory(createExporter(root));
    }
    function createExporter(exports, previous) {
        return function (id, v) { return exports[id] = previous ? previous(id, v) : v; };
    }
})
(function (exporter) {
    var extendStatics = Object.setPrototypeOf ||
        ({ __proto__: [] } instanceof Array && function (d, b) { d.__proto__ = b; }) ||
        function (d, b) { for (var p in b) if (b.hasOwnProperty(p)) d[p] = b[p]; };

    __extends = function (d, b) {
        extendStatics(d, b);
        function __() { this.constructor = d; }
        d.prototype = b === null ? Object.create(b) : (__.prototype = b.prototype, new __());
    };

    __assign = Object.assign || function (t) {
        for (var s, i = 1, n = arguments.length; i < n; i++) {
            s = arguments[i];
            for (var p in s) if (Object.prototype.hasOwnProperty.call(s, p)) t[p] = s[p];
        }
        return t;
    };

    __rest = function (s, e) {
        var t = {};
        for (var p in s) if (Object.prototype.hasOwnProperty.call(s, p) && e.indexOf(p) < 0)
            t[p] = s[p];
        if (s != null && typeof Object.getOwnPropertySymbols === "function")
            for (var i = 0, p = Object.getOwnPropertySymbols(s); i < p.length; i++) if (e.indexOf(p[i]) < 0)
                t[p[i]] = s[p[i]];
        return t;
    };

    __decorate = function (decorators, target, key, desc) {
        var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
        if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
        else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
        return c > 3 && r && Object.defineProperty(target, key, r), r;
    };

    __param = function (paramIndex, decorator) {
        return function (target, key) { decorator(target, key, paramIndex); }
    };

    __metadata = function (metadataKey, metadataValue) {
        if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(metadataKey, metadataValue);
    };

    __awaiter = function (thisArg, _arguments, P, generator) {
        return new (P || (P = Promise))(function (resolve, reject) {
            function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
            function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
            function step(result) { result.done ? resolve(result.value) : new P(function (resolve) { resolve(result.value); }).then(fulfilled, rejected); }
            step((generator = generator.apply(thisArg, _arguments || [])).next());
        });
    };

    __generator = function (thisArg, body) {
        var _ = { label: 0, sent: function() { if (t[0] & 1) throw t[1]; return t[1]; }, trys: [], ops: [] }, f, y, t, g;
        return g = { next: verb(0), "throw": verb(1), "return": verb(2) }, typeof Symbol === "function" && (g[Symbol.iterator] = function() { return this; }), g;
        function verb(n) { return function (v) { return step([n, v]); }; }
        function step(op) {
            if (f) throw new TypeError("Generator is already executing.");
            while (_) try {
                if (f = 1, y && (t = y[op[0] & 2 ? "return" : op[0] ? "throw" : "next"]) && !(t = t.call(y, op[1])).done) return t;
                if (y = 0, t) op = [0, t.value];
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

    __exportStar = function (m, exports) {
        for (var p in m) if (!exports.hasOwnProperty(p)) exports[p] = m[p];
    };

    __values = function (o) {
        var m = typeof Symbol === "function" && o[Symbol.iterator], i = 0;
        if (m) return m.call(o);
        return {
            next: function () {
                if (o && i >= o.length) o = void 0;
                return { value: o && o[i++], done: !o };
            }
        };
    };

    __read = function (o, n) {
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

    __spread = function () {
        for (var ar = [], i = 0; i < arguments.length; i++)
            ar = ar.concat(__read(arguments[i]));
        return ar;
    };

    __await = function (v) {
        return this instanceof __await ? (this.v = v, this) : new __await(v);
    };

    __asyncGenerator = function (thisArg, _arguments, generator) {
        if (!Symbol.asyncIterator) throw new TypeError("Symbol.asyncIterator is not defined.");
        var g = generator.apply(thisArg, _arguments || []), i, q = [];
        return i = {}, verb("next"), verb("throw"), verb("return"), i[Symbol.asyncIterator] = function () { return this; }, i;
        function verb(n) { if (g[n]) i[n] = function (v) { return new Promise(function (a, b) { q.push([n, v, a, b]) > 1 || resume(n, v); }); }; }
        function resume(n, v) { try { step(g[n](v)); } catch (e) { settle(q[0][3], e); } }
        function step(r) { r.value instanceof __await ? Promise.resolve(r.value.v).then(fulfill, reject) : settle(q[0][2], r);  }
        function fulfill(value) { resume("next", value); }
        function reject(value) { resume("throw", value); }
        function settle(f, v) { if (f(v), q.shift(), q.length) resume(q[0][0], q[0][1]); }
    };

    __asyncDelegator = function (o) {
        var i, p;
        return i = {}, verb("next"), verb("throw", function (e) { throw e; }), verb("return"), i[Symbol.iterator] = function () { return this; }, i;
        function verb(n, f) { if (o[n]) i[n] = function (v) { return (p = !p) ? { value: __await(o[n](v)), done: n === "return" } : f ? f(v) : v; }; }
    };

    __asyncValues = function (o) {
        if (!Symbol.asyncIterator) throw new TypeError("Symbol.asyncIterator is not defined.");
        var m = o[Symbol.asyncIterator];
        return m ? m.call(o) : typeof __values === "function" ? __values(o) : o[Symbol.iterator]();
    };

    exporter("__extends", __extends);
    exporter("__assign", __assign);
    exporter("__rest", __rest);
    exporter("__decorate", __decorate);
    exporter("__param", __param);
    exporter("__metadata", __metadata);
    exporter("__awaiter", __awaiter);
    exporter("__generator", __generator);
    exporter("__exportStar", __exportStar);
    exporter("__values", __values);
    exporter("__read", __read);
    exporter("__spread", __spread);
    exporter("__await", __await);
    exporter("__asyncGenerator", __asyncGenerator);
    exporter("__asyncDelegator", __asyncDelegator);
    exporter("__asyncValues", __asyncValues);
});

var Increment_View_Id = 0;
function _generateViewId() {
    Increment_View_Id = Increment_View_Id + 1;
    return ("viewid-" + Increment_View_Id);
}

(function (GradientOrientation) {
    GradientOrientation[GradientOrientation["TOP_BOTTOM"] = 0] = "TOP_BOTTOM";
    GradientOrientation[GradientOrientation["TR_BL"] = 1] = "TR_BL";
    GradientOrientation[GradientOrientation["RIGHT_LEFT"] = 2] = "RIGHT_LEFT";
    GradientOrientation[GradientOrientation["BR_TL"] = 3] = "BR_TL";
    GradientOrientation[GradientOrientation["BOTTOM_TOP"] = 4] = "BOTTOM_TOP";
    GradientOrientation[GradientOrientation["BL_TR"] = 5] = "BL_TR";
    GradientOrientation[GradientOrientation["LEFT_RIGHT"] = 6] = "LEFT_RIGHT";
    GradientOrientation[GradientOrientation["TL_BR"] = 7] = "TL_BR";
})(exports.GradientOrientation || (exports.GradientOrientation = {}));
var BaseView = (function () {
    function BaseView() {
        this._x = 0;
        this._y = 0;
        this._width = 0;
        this._height = 0;
        this.type = -1;
        this.borderWidth = 0;
        this.borderColor = "";
        this.alpha = 1;
        this.hidden = false;
        this.shadowColor = "";
        this.shadowOpacity = 0;
        this.shadowRadius = 3;
        this.shadowOffset = { width: 0, height: -3 };
        this.gaLabel = "";
        this.gaUserInfo = {};
        this.ignoreBaselineAdjustment = false;
        this.shrinkable = false;
        this.viewId = _generateViewId();
        this.hostId = "";
        this.parentView = null;
        this.actions = {};
        this.tag = "";
        this.accessId = "";
        this.accessLabel = "";
    }
    BaseView.viewWithFrame = function (x, y, width, height) {
        var v = new this();
        v._x = x;
        v._y = y;
        v._width = width;
        v._height = height;
        return v;
    };
    BaseView.viewWithSize = function (width, height) {
        return this.viewWithFrame(0, 0, width, height);
    };
    Object.defineProperty(BaseView.prototype, "x", {
        get: function () {
            return (typeof this._x === "number") ? this._x : 0;
        },
        set: function (v) {
            this._x = v;
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(BaseView.prototype, "y", {
        get: function () {
            return (typeof this._y === "number") ? this._y : 0;
        },
        set: function (v) {
            this._y = v;
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(BaseView.prototype, "width", {
        get: function () {
            return (typeof this._width === "number") ? this._width : 0;
        },
        set: function (v) {
            this._width = v;
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(BaseView.prototype, "height", {
        get: function () {
            return (typeof this._height === "number") ? this._height : 0;
        },
        set: function (v) {
            this._height = v;
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(BaseView.prototype, "left", {
        get: function () {
            return this.x;
        },
        set: function (v) {
            this.x = v;
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(BaseView.prototype, "right", {
        get: function () {
            return this.x + this.width;
        },
        set: function (v) {
            this.x = v - this.width;
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(BaseView.prototype, "top", {
        get: function () {
            return this.y;
        },
        set: function (v) {
            this.y = v;
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(BaseView.prototype, "bottom", {
        get: function () {
            return this.y + this.height;
        },
        set: function (v) {
            this.y = v - this.height;
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(BaseView.prototype, "center", {
        get: function () {
            return {
                x: this.centerX,
                y: this.centerY
            };
        },
        set: function (center) {
            this.centerX = center.x;
            this.centerY = center.y;
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(BaseView.prototype, "centerX", {
        get: function () {
            return this.x + this.width / 2;
        },
        set: function (v) {
            this.x = v - this.width / 2;
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(BaseView.prototype, "centerY", {
        get: function () {
            return this.y + this.height / 2;
        },
        set: function (v) {
            this.y = v - this.height / 2;
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(BaseView.prototype, "size", {
        get: function () {
            return {
                width: this.width,
                height: this.height
            };
        },
        set: function (v) {
            this.width = v.width;
            this.height = v.height;
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(BaseView.prototype, "frame", {
        get: function () {
            return {
                x: this.x,
                y: this.y,
                width: this.width,
                height: this.height
            };
        },
        set: function (v) {
            this.x = v.x;
            this.y = v.y;
            this.width = v.width;
            this.height = v.height;
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(BaseView.prototype, "bounds", {
        get: function () {
            return {
                x: 0,
                y: 0,
                width: this.width,
                height: this.height
            };
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(BaseView.prototype, "baseline", {
        get: function () {
            return this.bottom;
        },
        set: function (v) {
            this.bottom = v;
        },
        enumerable: true,
        configurable: true
    });
    BaseView.prototype.setAction = function (action, callback) {
        this.actions[action] = callback;
    };
    BaseView.prototype.info = function () {
        var info = {
            x: this.x,
            y: this.y,
            width: this.width,
            height: this.height,
            type: this.type,
            borderWidth: this.borderWidth,
            borderColor: this.borderColor,
            alpha: this.alpha,
            hidden: this.hidden,
            gaLabel: this.gaLabel,
            gaUserInfo: (typeof this.gaUserInfo === "object" ? (PCSEnvironment.platform === "iOS" ? this.gaUserInfo : JSON.stringify(this.gaUserInfo)) : this.gaUserInfo),
            tag: this.tag,
            extra: (typeof this.extra === "object" ? (PCSEnvironment.platform === "iOS" ? this.extra : JSON.stringify(this.extra)) : this.extra),
            sdColor: this.shadowColor,
            sdOffsetX: this.shadowOffset.width,
            sdOffsetY: this.shadowOffset.height,
            sdOpacity: this.shadowOpacity,
            sdRadius: this.shadowRadius,
            viewId: this.viewId,
            hostId: this.hostId,
            accessId: this.accessId,
            accessLabel: this.accessLabel,
            actions: Object.keys(this.actions),
            parentId: this.parentView ? this.parentView.viewId : ''
        };
        if (this.backgroundColor && typeof this.backgroundColor === "object") {
            info.startColor = this.backgroundColor.startColor;
            info.endColor = this.backgroundColor.endColor;
            info.orientation = this.backgroundColor.orientation;
        }
        else {
            info.backgroundColor = this.backgroundColor || "";
        }
        if (typeof this.cornerRadius === "object") {
            info.cornerRadiusLT = this.cornerRadius.leftTop;
            info.cornerRadiusRT = this.cornerRadius.rightTop;
            info.cornerRadiusLB = this.cornerRadius.leftBottom;
            info.cornerRadiusRB = this.cornerRadius.rightBottom;
            info.cornerRadius = this.cornerRadius.radius;
        }
        else {
            info.cornerRadius = this.cornerRadius || 0;
        }
        return info;
    };
    return BaseView;
}());

var View = (function (_super) {
    __extends(View, _super);
    function View() {
        var _this = _super.call(this) || this;
        _this.type = 0;
        _this.subviews = [];
        return _this;
    }
    View.prototype.addSubView = function (v) {
        v.parentView = this;
        this.subviews.push(v);
    };
    View.viewWithFrame = function (x, y, width, height) {
        var v = new this;
        v._x = x;
        v._y = y;
        v._width = width;
        v._height = height;
        return v;
    };
    Object.defineProperty(View.prototype, "onClick", {
        get: function () {
            return this.actions['click'];
        },
        set: function (click) {
            this.setAction('click', click);
        },
        enumerable: true,
        configurable: true
    });
    View.viewWithSize = function (width, height) {
        return this.viewWithFrame(0, 0, width, height);
    };
    View.prototype.info = function () {
        var info = _super.prototype.info.call(this);
        info.subviews = this.subviews.map(function (v) {
            return v.info();
        });
        return info;
    };
    return View;
}(BaseView));

var Button = (function (_super) {
    __extends(Button, _super);
    function Button() {
        var _this = _super.call(this) || this;
        _this.type = 3;
        _this.schema = "";
        _this.clickedColor = "";
        return _this;
    }
    Button.viewWithFrame = function (x, y, width, height) {
        var v = new this();
        v._x = x;
        v._y = y;
        v._width = width;
        v._height = height;
        return v;
    };
    Object.defineProperty(Button.prototype, "onClick", {
        get: function () {
            return this.actions['click'];
        },
        set: function (click) {
            this.setAction('click', click);
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(Button.prototype, "onLongPress", {
        get: function () {
            return this.actions['longPress'];
        },
        set: function (f) {
            this.setAction('longPress', f);
        },
        enumerable: true,
        configurable: true
    });
    Button.prototype.info = function () {
        var info = _super.prototype.info.call(this);
        info.clickedColor = this.clickedColor;
        info.schema = this.schema;
        info.data = (typeof this.data === "object" ? (PCSEnvironment.platform === "iOS" ? this.data : JSON.stringify(this.data)) : this.data);
        return info;
    };
    return Button;
}(BaseView));

var ImageView = (function (_super) {
    __extends(ImageView, _super);
    function ImageView() {
        var _this = _super.call(this) || this;
        _this.imageUrl = "";
        _this.imagePath = "";
        _this.image = "";
        _this.imageBase64 = "";
        _this.contentMode = 0;
        _this.needPlaceholder = true;
        _this.placeholderLoading = "";
        _this.placeholderError = "";
        _this.placeholderEmpty = "";
        _this.resizeEdgeInset = { top: 0, left: 0, bottom: 0, right: 0 };
        _this.imageScale = 3;
        _this.gifLoopCount = -1;
        _this.fadeEffect = false;
        _this.type = 2;
        return _this;
    }
    Object.defineProperty(ImageView.prototype, "onClick", {
        get: function () {
            return this.actions['click'];
        },
        set: function (click) {
            this.setAction('click', click);
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(ImageView.prototype, "onImageLoaded", {
        get: function () {
            return this.actions['imageLoaded'];
        },
        set: function (f) {
            this.setAction('imageLoaded', f);
        },
        enumerable: true,
        configurable: true
    });
    ImageView.viewWithFrame = function (x, y, width, height) {
        var v = new this;
        v._x = x;
        v._y = y;
        v._width = width;
        v._height = height;
        return v;
    };
    ImageView.prototype.info = function () {
        var info = _super.prototype.info.call(this);
        info.imageUrl = this.imageUrl;
        info.imagePath = this.imagePath;
        info.image = this.image;
        info.contentMode = this.contentMode;
        info.placeholderLoading = this.placeholderLoading;
        info.placeholderEmpty = this.placeholderEmpty;
        info.placeholderError = this.placeholderError;
        info.edgeInsets = this.resizeEdgeInset;
        info.needPlaceholder = this.needPlaceholder;
        info.imageScale = this.imageScale;
        info.imageBase64 = this.imageBase64;
        info.gifLoopCount = this.gifLoopCount;
        info.fadeEffect = this.fadeEffect;
        return info;
    };
    return ImageView;
}(BaseView));

var TextViewSizeCache = (function () {
    function TextViewSizeCache() {
        this.cacheLength = 100;
        this.cacheDic = {};
    }
    TextViewSizeCache.prototype.sizeForKey = function (theKey) {
        var cacheSize = this.cacheDic[theKey];
        if (typeof cacheSize === "undefined") {
            return null;
        }
        else {
            return cacheSize;
        }
    };
    TextViewSizeCache.prototype.addCacheSize = function (thekey, size) {
        this.cacheDic[thekey] = size;
        var cacheKeys = Object.keys(this.cacheDic);
        while (cacheKeys.length > this.cacheLength) {
            delete this.cacheDic[cacheKeys[0]];
            cacheKeys.shift();
        }
    };
    return TextViewSizeCache;
}());
var picasso_size_cache = new TextViewSizeCache();
var TextView = (function (_super) {
    __extends(TextView, _super);
    function TextView() {
        var _this = _super.call(this) || this;
        _this._text = "";
        _this.textColor = "";
        _this.textSize = 14;
        _this.highlightedBgColor = "";
        _this.fontStyle = 0;
        _this.textAlignment = 0;
        _this.lineBreakMode = 4;
        _this.numberOfLines = 1;
        _this.linespacing = 0;
        _this.strikethrough = false;
        _this.underline = false;
        _this.needSizeToFit = false;
        _this.disableBold = false;
        _this.type = 1;
        return _this;
    }
    Object.defineProperty(TextView.prototype, "text", {
        get: function () {
            if (this._text === undefined || this._text === null) {
                return "";
            }
            else {
                return "" + this._text;
            }
        },
        set: function (v) {
            if (v === undefined || v === null) {
                this._text = "";
            }
            else {
                this._text = "" + v;
            }
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(TextView.prototype, "baseline", {
        get: function () {
            return this.bottom - this.baselineBottomOffset();
        },
        set: function (v) {
            this.bottom = v + this.baselineBottomOffset();
        },
        enumerable: true,
        configurable: true
    });
    TextView.viewWithFrame = function (x, y, width, height) {
        var v = new this;
        v._x = x;
        v._y = y;
        v._width = width;
        v._height = height;
        return v;
    };
    TextView.prototype.sizeToFit = function () {
        if (!this.hidden) {
            var sizeKey = this.sizeKey();
            this._sizeKey = sizeKey;
            var cacheSize = picasso_size_cache.sizeForKey(sizeKey);
            if (cacheSize === null) {
                cacheSize = Picasso.size_for_text(this.info());
                picasso_size_cache.addCacheSize(sizeKey, cacheSize);
            }
            this.width = cacheSize.width;
            this.height = cacheSize.height;
        }
    };
    TextView.prototype.sizeKey = function () {
        return this.text + "#" + this.numberOfLines + "#" + this.textSize + "#" + this.fontStyle + "#" + this.strikethrough + "#" + this.underline + "#" + this.linespacing + (this.numberOfLines === 1 ? "" : ("#" + this.width));
    };
    TextView.prototype.info = function () {
        var info = _super.prototype.info.call(this);
        info.text = this.text;
        info.textColor = this.textColor;
        info.textSize = this.textSize;
        info.textAlignment = this.textAlignment;
        info.lineBreakMode = this.lineBreakMode;
        info.numberOfLines = this.numberOfLines;
        info.fontStyle = this.fontStyle;
        info.linespacing = this.linespacing;
        info.strikethrough = this.strikethrough;
        info.underline = this.underline;
        info.needSizeToFit = this.needSizeToFit;
        info.sizeKey = this._sizeKey || this.sizeKey();
        info.disableBold = this.disableBold;
        info.highlightedBgColor = this.highlightedBgColor;
        return info;
    };
    TextView.prototype.isContainChinese = function (str) {
        for (var index = 0; index < str.length; index++) {
            var ch = str.charCodeAt(index);
            if (0x4E00 <= ch && ch <= 0x9FA5) {
                return true;
            }
        }
        return false;
    };
    TextView.prototype.getTunning = function (text, fontSize) {
        if (this.isContainChinese(text)) {
            var tunning = 0;
            if (fontSize <= 8) {
                tunning = 2;
            }
            else if (fontSize <= 23) {
                tunning = Math.floor((fontSize + 1) / 5);
            }
            else if (fontSize <= 30) {
                tunning = 6;
            }
            else if (fontSize <= 35) {
                tunning = 7;
            }
            else {
                tunning = 8;
            }
            return tunning / PCSEnvironment.scale;
        }
        return 0;
    };
    TextView.prototype.baselineBottomOffset = function () {
        if (this.numberOfLines >= 2) {
            return 0;
        }
        else {
            var maxFontSize = this.textSize;
            var allText = "";
            try {
                var textObj = JSON.parse(this.text);
                if (Array.isArray(textObj)) {
                    for (var _i = 0, textObj_1 = textObj; _i < textObj_1.length; _i++) {
                        var textDic = textObj_1[_i];
                        maxFontSize = Math.max(maxFontSize, textDic['textsize']);
                        allText += textDic['text'];
                    }
                }
                else if (textObj !== null && typeof textObj === "object") {
                    var textList = textObj["richtextlist"];
                    if (Array.isArray(textList)) {
                        for (var _a = 0, textList_1 = textList; _a < textList_1.length; _a++) {
                            var textDic = textList_1[_a];
                            maxFontSize = Math.max(maxFontSize, textDic["textsize"]);
                            allText += textDic["text"];
                        }
                    }
                    else {
                        maxFontSize = textList["textsize"];
                        allText = textList["text"];
                    }
                }
            }
            catch (e) {
                allText = this.text;
            }
            finally {
                if (allText.length === 0) {
                    allText = this.text;
                }
            }
            var bottomOffset = 0;
            bottomOffset -= this.getTunning(allText, maxFontSize);
            if (PCSEnvironment.platform === "iOS") {
                bottomOffset = (Math.floor(-PCSEnvironment.fontDescender * maxFontSize * PCSEnvironment.scale) - 1) / PCSEnvironment.scale;
                bottomOffset += (this.height - Math.ceil(maxFontSize * PCSEnvironment.fontLineHeight * PCSEnvironment.scale) / PCSEnvironment.scale) / 2;
            }
            else {
                bottomOffset += maxFontSize * PCSEnvironment.fontDescender;
            }
            return bottomOffset;
        }
    };
    return TextView;
}(BaseView));

(function (Alignment) {
    Alignment["left"] = "left";
    Alignment["right"] = "right";
    Alignment["top"] = "top";
    Alignment["bottom"] = "bottom";
    Alignment["center"] = "center";
    Alignment["baseline"] = "baseline";
})(exports.Alignment || (exports.Alignment = {}));

(function (Orientation) {
    Orientation[Orientation["horizontal"] = 0] = "horizontal";
    Orientation[Orientation["vertical"] = 1] = "vertical";
})(exports.Orientation || (exports.Orientation = {}));
var LayoutContainer = (function () {
    function LayoutContainer() {
        this.subviews = [];
        this.orientation = exports.Orientation.horizontal;
        this.divideSpace = 0;
        this.horizontalAlignment = exports.Alignment.left;
        this.verticalAlignment = exports.Alignment.bottom;
        this.OFFSET = 0.1;
        this.x = 0;
        this.y = 0;
        this.paddingLeft = 0;
        this.paddingRight = 0;
        this.paddingTop = 0;
        this.paddingBottom = 0;
        this.ignoreBaselineAdjustment = false;
        this.baseline = 0;
        this._width = 0;
        this._height = 0;
        this._hidden = false;
        this.shrinkable = false;
    }
    Object.defineProperty(LayoutContainer.prototype, "baselineAlignment", {
        get: function () {
            return this.orientation === exports.Orientation.horizontal && this.verticalAlignment === exports.Alignment.baseline;
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(LayoutContainer.prototype, "children", {
        get: function () {
            return this.subviews.filter(function (e) { return !e.hidden; });
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(LayoutContainer.prototype, "width", {
        get: function () {
            if (this._width)
                return this._width;
            this._width = this.arrangeWidth();
            return this._width;
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(LayoutContainer.prototype, "height", {
        get: function () {
            if (this._height)
                return this._height;
            this._height = this.arrangeHeight();
            return this._height;
        },
        enumerable: true,
        configurable: true
    });
    LayoutContainer.prototype.sizeToFit = function () {
        this.width;
        this.height;
    };
    LayoutContainer.prototype.arrangeHeight = function () {
        var _this = this;
        if (this.orientation === exports.Orientation.vertical) {
            return this.arrangeVertical();
        }
        else {
            return this.children.reduce(function (max, e, index) { return Math.max(max, e.height + (e.marginTop || 0) + (e.marginBottom || 0) + _this.paddingBottom + _this.paddingTop); }, 0);
        }
    };
    LayoutContainer.prototype.layout = function (adjust) {
        if (adjust)
            adjust(this);
        this.sizeToFit();
        switch (this.orientation) {
            case exports.Orientation.vertical:
                this.layoutVertical();
                break;
            case exports.Orientation.horizontal:
            default:
                this.layoutHorizontal();
                break;
        }
    };
    LayoutContainer.prototype.lastPriorityView = function () {
        var viewsWithPriority = this.children.filter(function (v) { return v.priority !== undefined; });
        if (viewsWithPriority.length === 0) {
            return this.lastChild();
        }
        return viewsWithPriority.sort(function (a, b) {
            if (!a.priority)
                return 0;
            if (!b.priority)
                return 0;
            return b.priority - a.priority;
        }).reverse()[0];
    };
    LayoutContainer.prototype.arrangeVertical = function () {
        if (!this.children.length)
            return this._height;
        var index = 0;
        var prev = { bottom: this.top + this.paddingTop };
        for (var _i = 0, _a = this.children; _i < _a.length; _i++) {
            var current = _a[_i];
            var space = index === 0 ? 0 : this.divideSpace;
            current.top = prev.bottom + (current.marginTop || prev.marginBottom || space);
            index = index + 1;
            prev = current;
        }
        var last = this.lastChild();
        var height = last.bottom + (last.marginBottom || 0) - this.top + this.paddingBottom;
        var maxHeight = (this.maxHeight || Number.MAX_SAFE_INTEGER);
        if (Math.abs(height - maxHeight) > this.OFFSET) {
            if (height > maxHeight) {
                var v = this.lastPriorityView();
                if (v.height > height - maxHeight && v.shrinkable) {
                    v.height = v.height - (height - maxHeight);
                }
                else {
                    v.hidden = true;
                }
                return this.arrangeVertical();
            }
            else if (this.maxHeight) {
                var flexBoxs = void 0;
                flexBoxs = this.children.filter(function (e) { return e instanceof LayoutContainer && e.isFlexible(); });
                if (flexBoxs.length > 0) {
                    var flexHeight_1 = (maxHeight - height) / flexBoxs.length;
                    flexBoxs.forEach(function (e) {
                        e._height = flexHeight_1;
                    });
                    return this.arrangeVertical();
                }
            }
        }
        this._height = height;
        return height;
    };
    LayoutContainer.prototype.layoutVertical = function () {
        this.arrangeVertical();
        for (var _i = 0, _a = this.children; _i < _a.length; _i++) {
            var current = _a[_i];
            if (current.marginLeft) {
                current.left = this.left + current.marginLeft;
            }
            else if (current.marginRight) {
                current.right = this.right - current.marginRight;
            }
            else {
                if (this.horizontalAlignment === exports.Alignment.left) {
                    current.left = this.left + this.paddingLeft;
                }
                else if (this.horizontalAlignment === exports.Alignment.right) {
                    current.right = this.right - this.paddingRight;
                }
                else {
                    current.centerX = this.centerX;
                }
            }
            if (current instanceof LayoutContainer && !this.isFlexible()) {
                current.layout();
            }
        }
    };
    LayoutContainer.prototype.arrangeHorizental = function () {
        if (!this.children.length)
            return this._width;
        var index = 0;
        var prev = { right: this.left + this.paddingLeft };
        for (var _i = 0, _a = this.children; _i < _a.length; _i++) {
            var current = _a[_i];
            var space = index === 0 ? 0 : this.divideSpace;
            current.left = prev.right + (current.marginLeft || prev.marginRight || space);
            index = index + 1;
            prev = current;
        }
        var last = this.lastChild();
        var width = last.right + (last.marginRight || 0) - this.left + this.paddingRight;
        var maxWidth = (this.maxWidth || Number.MAX_SAFE_INTEGER);
        if (Math.abs(width - maxWidth) > this.OFFSET) {
            if (width > maxWidth) {
                var v = this.lastPriorityView();
                if (v.width > width - maxWidth && v.shrinkable) {
                    v.width = v.width - (width - maxWidth);
                }
                else {
                    v.hidden = true;
                }
                return this.arrangeHorizental();
            }
            else if (this.maxWidth) {
                var flexBoxs = void 0;
                flexBoxs = this.children.filter(function (e) { return e instanceof LayoutContainer && e.isFlexible(); });
                if (flexBoxs.length > 0) {
                    var flexWidth_1 = (maxWidth - width) / flexBoxs.length;
                    flexBoxs.forEach(function (e) {
                        e._width = flexWidth_1;
                    });
                    return this.arrangeHorizental();
                }
            }
        }
        this._width = width;
        return width;
    };
    LayoutContainer.prototype.arrangeWidth = function () {
        var _this = this;
        if (this.orientation === exports.Orientation.horizontal) {
            return this.arrangeHorizental();
        }
        else {
            return this.children.reduce(function (max, e, index) { return Math.max(max, e.width + (e.marginLeft || 0) + (e.marginRight || 0) + _this.paddingLeft + _this.paddingRight); }, 0);
        }
    };
    LayoutContainer.prototype.layoutHorizontal = function () {
        this.arrangeHorizental();
        for (var _i = 0, _a = this.children; _i < _a.length; _i++) {
            var current = _a[_i];
            if (current.marginTop) {
                current.top = this.top + current.marginTop;
            }
            else if (current.marginBottom) {
                current.bottom = this.bottom - current.marginBottom;
            }
            else {
                if (this.verticalAlignment === exports.Alignment.top) {
                    current.top = this.top + this.paddingTop;
                }
                else if (this.verticalAlignment === exports.Alignment.bottom) {
                    current.bottom = this.bottom - this.paddingBottom;
                }
                else {
                    current.centerY = this.centerY;
                }
            }
            if (this.baselineAlignment && !current.ignoreBaselineAdjustment) {
                current.baseline = current.bottom;
            }
            if (current instanceof LayoutContainer && !current.isFlexible()) {
                current.layout();
            }
        }
    };
    LayoutContainer.prototype.isFlexible = function () {
        return this instanceof FlexBox;
    };
    LayoutContainer.prototype.lastChild = function () {
        return this.children[this.children.length - 1];
    };
    LayoutContainer.prototype.in = function (bgView) {
        this.subviews.forEach(function (e) {
            if (e instanceof LayoutContainer) {
                e.in(bgView);
            }
            else {
                bgView.addSubView(e);
            }
        });
        return this;
    };
    LayoutContainer.prototype.adjust = function (f) {
        f(this);
        return this;
    };
    LayoutContainer.prototype.as = function (bgView) {
        bgView.width = this.width;
        bgView.height = this.height;
        this.in(bgView);
        return bgView;
    };
    Object.defineProperty(LayoutContainer.prototype, "left", {
        get: function () {
            return this.x;
        },
        set: function (v) {
            this.x = v;
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(LayoutContainer.prototype, "right", {
        get: function () {
            return this.x + this.width;
        },
        set: function (v) {
            this.x = v - this.width;
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(LayoutContainer.prototype, "top", {
        get: function () {
            return this.y;
        },
        set: function (v) {
            this.y = v;
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(LayoutContainer.prototype, "bottom", {
        get: function () {
            return this.y + this.height;
        },
        set: function (v) {
            this.y = v - this.height;
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(LayoutContainer.prototype, "centerX", {
        get: function () {
            return this.x + this.width / 2;
        },
        set: function (v) {
            this.x = v - this.width / 2;
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(LayoutContainer.prototype, "centerY", {
        get: function () {
            return this.y + this.height / 2;
        },
        set: function (v) {
            this.y = v - this.height / 2;
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(LayoutContainer.prototype, "size", {
        get: function () {
            return {
                width: this.width,
                height: this.height
            };
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(LayoutContainer.prototype, "hidden", {
        get: function () {
            return this._hidden;
        },
        set: function (hide) {
            this._hidden = hide;
            for (var _i = 0, _a = this.children; _i < _a.length; _i++) {
                var e = _a[_i];
                e.hidden = hide;
            }
        },
        enumerable: true,
        configurable: true
    });
    return LayoutContainer;
}());
function containerWith(container, elements, option) {
    if (option) {
        container.divideSpace = option.divideSpace || 0;
        container.marginLeft = option.marginLeft;
        container.marginRight = option.marginRight;
        container.marginTop = option.marginTop;
        container.marginBottom = option.marginBottom;
        container.paddingBottom = option.padding || 0;
        container.paddingLeft = option.padding || 0;
        container.paddingRight = option.padding || 0;
        container.paddingTop = option.padding || 0;
        container.paddingLeft = option.paddingHorizontal !== undefined ? option.paddingHorizontal : container.paddingLeft;
        container.paddingRight = option.paddingHorizontal !== undefined ? option.paddingHorizontal : container.paddingRight;
        container.paddingBottom = option.paddingVertical !== undefined ? option.paddingVertical : container.paddingBottom;
        container.paddingTop = option.paddingVertical !== undefined ? option.paddingVertical : container.paddingTop;
        container.paddingTop = option.paddingTop !== undefined ? option.paddingTop : container.paddingTop;
        container.paddingBottom = option.paddingBottom !== undefined ? option.paddingBottom : container.paddingBottom;
        container.paddingLeft = option.paddingLeft !== undefined ? option.paddingLeft : container.paddingLeft;
        container.paddingRight = option.paddingRight !== undefined ? option.paddingRight : container.paddingRight;
        container.left = option.left || 0;
        container.top = option.top || 0;
        container.right = option.right || container.right;
        container.bottom = option.bottom || container.bottom;
        container.centerX = option.centerX || container.centerX;
        container.centerY = option.centerY || container.centerY;
    }
    return container;
}
function vlayout(elements, option) {
    var container = new LayoutContainer;
    container.subviews = elements;
    container.orientation = exports.Orientation.vertical;
    container.maxHeight = option && option.maxHeight;
    container.horizontalAlignment = option && option.align || container.horizontalAlignment;
    containerWith(container, elements, option);
    container.layout();
    return container;
}
function hlayout(elements, option) {
    var container = new LayoutContainer;
    container.subviews = elements;
    container.orientation = exports.Orientation.horizontal;
    container.maxWidth = option && option.maxWidth;
    container.verticalAlignment = option && option.align || container.verticalAlignment;
    containerWith(container, elements, option);
    container.layout();
    return container;
}
var FlexBox = (function (_super) {
    __extends(FlexBox, _super);
    function FlexBox() {
        return _super !== null && _super.apply(this, arguments) || this;
    }
    return FlexBox;
}(LayoutContainer));
function flexBox() {
    var container = new FlexBox;
    container.orientation = exports.Orientation.horizontal;
    return container;
}

var ScrollView = (function (_super) {
    __extends(ScrollView, _super);
    function ScrollView() {
        var _this = _super.call(this) || this;
        _this.showScrollIndicator = true;
        _this.scrollEnabled = true;
        _this.bounces = true;
        _this.type = 11;
        return _this;
    }
    Object.defineProperty(ScrollView.prototype, "onScroll", {
        get: function () {
            return this.actions['scroll'];
        },
        set: function (f) {
            this.setAction('scroll', f);
        },
        enumerable: true,
        configurable: true
    });
    ScrollView.viewWithFrame = function (x, y, width, height) {
        var v = new this;
        v._x = x;
        v._y = y;
        v._width = width;
        v._height = height;
        return v;
    };
    ScrollView.prototype.info = function () {
        var info = _super.prototype.info.call(this);
        info.showScrollIndicator = this.showScrollIndicator;
        info.scrollEnabled = this.scrollEnabled;
        info.bounces = this.bounces;
        if (this.contentOffset) {
            info.contentOffsetX = this.contentOffset.x;
            info.contentOffsetY = this.contentOffset.y;
        }
        return info;
    };
    return ScrollView;
}(View));

var modules = {};
function registerModule(moduleName, module) {
    modules[moduleName] = module;
}
function require(moduleName) {
    if (modules[moduleName]) {
        return modules[moduleName];
    }
    else {
        if (nativeRequire(moduleName)) {
            return modules[moduleName];
        }
        else {
            return null;
        }
    }
}

function handleMessage(msg) {
    if (typeof msg === 'undefined') {
        return 'undefined';
    }
    if (typeof msg === 'string') {
        return msg;
    }
    return JSON.stringify(msg);
}
function pLogInfo(msg) {
    if (PCSEnvironment.isDebug === false) {
        return;
    }
    picassoLog(handleMessage(msg), 2);
}
function pLogWarning(msg) {
    picassoLog(handleMessage(msg), 1);
}
function pLogError(msg) {
    picassoLog(handleMessage(msg), 0);
}

exports.BaseView = BaseView;
exports.View = View;
exports.Button = Button;
exports.ImageView = ImageView;
exports.TextView = TextView;
exports.LayoutContainer = LayoutContainer;
exports.vlayout = vlayout;
exports.hlayout = hlayout;
exports.FlexBox = FlexBox;
exports.flexBox = flexBox;
exports.ScrollView = ScrollView;
exports.registerModule = registerModule;
exports.require = require;
exports.log = pLogInfo;
exports.logw = pLogWarning;
exports.loge = pLogError;

return exports;

}({}));

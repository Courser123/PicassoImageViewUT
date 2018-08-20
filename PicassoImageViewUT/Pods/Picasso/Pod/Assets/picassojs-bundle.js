'use strict';

Object.defineProperty(exports, '__esModule', { value: true });

function handleMessages(args, level) {
    var str = 'undefined';
    if (args && args.length) {
        str = args.map(function (msg) { return typeof msg === 'object' ? JSON.stringify(msg) : msg + ''; }).join(' ');
    }
    picassoLog(str, level);
}
function pLogInfo() {
    var args = [];
    for (var _i = 0; _i < arguments.length; _i++) {
        args[_i] = arguments[_i];
    }
    if (PCSEnvironment.isDebug === false) {
        return;
    }
    handleMessages(args, 2);
}
function pLogWarning() {
    var args = [];
    for (var _i = 0; _i < arguments.length; _i++) {
        args[_i] = arguments[_i];
    }
    handleMessages(args, 1);
}
function pLogError() {
    var args = [];
    for (var _i = 0; _i < arguments.length; _i++) {
        args[_i] = arguments[_i];
    }
    handleMessages(args, 0);
}

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
    BaseView.prototype.getAction = function (action) {
        return this.actions[action];
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
        _this.clipToBounds = true;
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
        info.clipToBounds = this.clipToBounds;
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
        _this.failedRetry = false;
        _this.placeholderLoading = "";
        _this.placeholderError = "";
        _this.placeholderEmpty = "";
        _this.resizeEdgeInset = { top: 0, left: 0, bottom: 0, right: 0 };
        _this.imageScale = 3;
        _this.gifLoopCount = -1;
        _this.fadeEffect = false;
        _this.cacheType = 0;
        _this.blurRadius = 0;
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
        info.failedRetry = this.failedRetry;
        info.needPlaceholder = this.needPlaceholder;
        info.imageScale = this.imageScale;
        info.imageBase64 = this.imageBase64;
        info.gifLoopCount = this.gifLoopCount;
        info.fadeEffect = this.fadeEffect;
        info.cacheType = this.cacheType;
        info.blurRadius = this.blurRadius;
        return info;
    };
    return ImageView;
}(BaseView));

var PicassoSizeCache = (function () {
    function PicassoSizeCache() {
        this.allHostCache = {};
        this.allCache = {};
    }
    PicassoSizeCache.prototype.sizeForKey = function (theKey) {
        return this.allCache[theKey];
    };
    PicassoSizeCache.prototype.addNativeCache = function (sizeCache, hostId) {
        var cache = this.allHostCache[hostId];
        if (cache) {
            for (var key in sizeCache) {
                if (sizeCache.hasOwnProperty(key)) {
                    cache[key] = sizeCache[key];
                    this.allCache[key] = sizeCache[key];
                }
            }
        }
        else {
            cache = sizeCache;
            for (var key in sizeCache) {
                if (sizeCache.hasOwnProperty(key)) {
                    this.allCache[key] = sizeCache[key];
                }
            }
        }
        this.allHostCache[hostId] = cache;
    };
    PicassoSizeCache.prototype.removeCache = function (hostId) {
        var hostCache = this.allHostCache[hostId];
        for (var key in hostCache) {
            if (hostCache.hasOwnProperty(key)) {
                delete this.allCache[key];
            }
        }
        delete this.allHostCache[hostId];
    };
    return PicassoSizeCache;
}());
var picasso_size_cache = new PicassoSizeCache();

var TextView = (function (_super) {
    __extends(TextView, _super);
    function TextView() {
        var _this = _super.call(this) || this;
        _this._text = "";
        _this.textColor = "";
        _this.textSize = 14;
        _this.fontName = "";
        _this.highlightedBgColor = "";
        _this.fontStyle = 0;
        _this.textAlignment = 0;
        _this.lineBreakMode = 4;
        _this.numberOfLines = 1;
        _this.linespacing = 0;
        _this.strikethrough = false;
        _this.underline = false;
        _this.disableBold = false;
        _this.textShadowOffset = { width: 0, height: 0 };
        _this.needSizeToFit = false;
        _this.type = 1;
        return _this;
    }
    Object.defineProperty(TextView.prototype, "text", {
        get: function () {
            if (this.textModel) {
                return JSON.stringify(this.textModel);
            }
            if (this._text) {
                return "" + this._text;
            }
            return "";
        },
        set: function (v) {
            if (v) {
                this._text = "" + v;
            }
            else {
                this._text = "";
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
    Object.defineProperty(TextView.prototype, "onClick", {
        get: function () {
            return this.actions['click'];
        },
        set: function (click) {
            this.setAction('click', click);
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
            if (!cacheSize) {
                this.needSizeToFit = true;
            }
            else {
                this.needSizeToFit = false;
                this.width = cacheSize.width;
                this.height = cacheSize.height;
            }
        }
    };
    TextView.prototype.sizeToFitSync = function () {
        var size = Picasso.size_for_text(this.info());
        this.width = size.width;
        this.height = size.height;
    };
    TextView.prototype.sizeKey = function () {
        return this.text + "#" + this.numberOfLines + "#" + this.textSize + "#" + this.fontStyle + "#" + this.strikethrough + "#" + this.underline + "#" + this.linespacing + (this.numberOfLines === 1 ? "" : ("#" + this.width));
    };
    TextView.prototype.info = function () {
        var info = _super.prototype.info.call(this);
        info.text = this.text;
        info.textColor = this.textColor;
        info.textSize = this.textSize;
        info.fontName = this.fontName;
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
        info.textShadowColor = this.textShadowColor;
        info.textShadowOffsetX = this.textShadowOffset.width;
        info.textShadowOffsetY = this.textShadowOffset.height;
        info.textShadowRadius = this.textShadowRadius;
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

var PullRefreshView = (function (_super) {
    __extends(PullRefreshView, _super);
    function PullRefreshView() {
        var _this = _super.call(this) || this;
        _this.type = 10;
        _this.style = 1;
        return _this;
    }
    PullRefreshView.viewWithFrame = function (x, y, width, height) {
        var v = new this;
        v._x = x;
        v._y = y;
        v._width = width;
        v._height = height;
        return v;
    };
    PullRefreshView.prototype.info = function () {
        var info = _super.prototype.info.call(this);
        info.style = this.style;
        return info;
    };
    return PullRefreshView;
}(BaseView));

var ScrollView = (function (_super) {
    __extends(ScrollView, _super);
    function ScrollView() {
        var _this = _super.call(this) || this;
        _this.showScrollIndicator = true;
        _this.scrollEnabled = true;
        _this.bounces = true;
        _this.handleSubItem = function (v) { };
        _this.refreshView = null;
        _this.refreshStatus = 'normal';
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
    Object.defineProperty(ScrollView.prototype, "onPullDown", {
        get: function () {
            return this.actions['onPullDown'];
        },
        set: function (f) {
            if (f) {
                this.setAction('onPullDown', f);
                if (!this.refreshView) {
                    this.refreshView = PullRefreshView.viewWithFrame(0, -50, this.width, 50);
                }
            }
            else {
                delete this.actions['onPullDown'];
            }
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
        if (this.onPullDown && this.refreshView) {
            if (this.handleSubItem) {
                this.handleSubItem(this.refreshView);
            }
            info.refreshView = this.refreshView.info();
            info.refreshStatus = this.refreshStatus;
        }
        return info;
    };
    return ScrollView;
}(View));

var InputView = (function (_super) {
    __extends(InputView, _super);
    function InputView() {
        var _this = _super.call(this) || this;
        _this.type = 14;
        _this.hint = "";
        _this.hintColor = "";
        _this.inputType = 0;
        _this.returnAction = -1;
        _this.textColor = "";
        _this.textSize = 0;
        _this.multiline = false;
        _this.secureTextEntry = false;
        _this.autoFocus = false;
        _this.autoAdjust = true;
        _this.inputAlignment = 0;
        _this.maxLength = 0;
        _this.setAction('onTextChange', function (param) {
            if (_this.onTextChange) {
                _this.onTextChange(param.newStr);
            }
        });
        return _this;
    }
    Object.defineProperty(InputView.prototype, "onFocus", {
        get: function () {
            return this.actions['onFocus'];
        },
        set: function (f) {
            this.setAction('onFocus', f);
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(InputView.prototype, "onReturnDone", {
        set: function (f) {
            this.setAction('onReturnDone', f);
        },
        enumerable: true,
        configurable: true
    });
    InputView.viewWithFrame = function (x, y, width, height) {
        var v = new this();
        v._x = x;
        v._y = y;
        v._width = width;
        v._height = height;
        return v;
    };
    InputView.prototype.info = function () {
        var info = _super.prototype.info.call(this);
        info.hint = this.hint;
        info.hintColor = this.hintColor;
        info.inputType = this.inputType;
        info.returnAction = this.returnAction;
        if (this.text !== undefined && this.text != null) {
            info.text = this.text;
        }
        info.textColor = this.textColor;
        info.textSize = this.textSize;
        info.autoFocus = this.autoFocus;
        info.autoAdjust = this.autoAdjust;
        info.multiline = this.multiline;
        info.secureTextEntry = this.secureTextEntry;
        info.inputAlignment = this.inputAlignment;
        info.maxLength = this.maxLength;
        return info;
    };
    return InputView;
}(BaseView));

var ListItem = (function (_super) {
    __extends(ListItem, _super);
    function ListItem() {
        var _this = _super.call(this) || this;
        _this.type = 8;
        return _this;
    }
    ListItem.itemWithReuseId = function (reuseId) {
        var v = new this;
        v.reuseId = reuseId;
        return v;
    };
    ListItem.prototype.info = function () {
        var info = _super.prototype.info.call(this);
        info.reuseId = this.reuseId;
        return info;
    };
    return ListItem;
}(View));

var ActivityIndicator = (function (_super) {
    __extends(ActivityIndicator, _super);
    function ActivityIndicator() {
        var _this = _super.call(this) || this;
        _this.color = '';
        _this.animating = true;
        _this.type = 15;
        _this.style = 0;
        return _this;
    }
    Object.defineProperty(ActivityIndicator.prototype, "style", {
        get: function () {
            return this._style;
        },
        set: function (v) {
            this._style = v;
            if (v === 0) {
                this.size = { width: 20, height: 20 };
            }
            else {
                this.size = { width: 36, height: 36 };
            }
        },
        enumerable: true,
        configurable: true
    });
    ActivityIndicator.viewWithStyle = function (style) {
        var v = new this;
        v.style = style;
        return v;
    };
    ActivityIndicator.prototype.info = function () {
        var info = _super.prototype.info.call(this);
        info.color = this.color;
        info.style = this.style;
        info.animating = this.animating;
        return info;
    };
    return ActivityIndicator;
}(BaseView));

var LoadingView = (function () {
    function LoadingView() {
    }
    LoadingView.loadingViewWithWidth = function (width) {
        var v = View.viewWithFrame(0, 0, width, 50);
        var a = new ActivityIndicator();
        a.centerX = v.width / 2;
        a.centerY = v.height / 2;
        v.addSubView(a);
        return v;
    };
    LoadingView.loadingErrorViewWithWidth = function (width, onLoadMoreRetry, errStr) {
        var v = View.viewWithFrame(0, 0, width, 50);
        var tv = TextView.viewWithFrame(0, 0, v.width, v.height);
        tv.text = errStr ? errStr : '加载失败，请点击重试';
        tv.textSize = 20;
        tv.textAlignment = 1;
        tv.onClick = onLoadMoreRetry;
        v.addSubView(tv);
        return v;
    };
    return LoadingView;
}());

var object_id_count = 0;
function hash(obj) {
    var o = obj;
    if (o.___objectid___)
        return o.___objectid___;
    object_id_count = (object_id_count + 1) % Number.MAX_SAFE_INTEGER;
    o.___objectid___ = object_id_count;
    return object_id_count;
}

var ModelCache = (function () {
    function ModelCache() {
        this.caches = {};
    }
    ModelCache.prototype.getCached = function (v) {
        if (v.key)
            return this.caches[hash(v.key)];
        return null;
    };
    ModelCache.prototype.getCachedByKey = function (key) {
        if (key)
            return this.caches[hash(key)];
        return null;
    };
    ModelCache.prototype.setCache = function (v) {
        if (v.key) {
            this.caches[hash(v.key)] = v;
        }
    };
    return ModelCache;
}());

var ListView = (function (_super) {
    __extends(ListView, _super);
    function ListView() {
        var _this = _super.call(this) || this;
        _this.sectionCount = 1;
        _this.indexColor = "";
        _this.handleSubItem = function (v) { };
        _this.initIndex = -1;
        _this.infoCache = new ModelCache;
        _this.refreshView = null;
        _this.refreshStatus = 'normal';
        _this.loadingView = null;
        _this.estimateItemHeight = 0;
        _this.type = 9;
        _this.setAction('getItems', function (arg) {
            if (!_this.layoutItem)
                return [];
            var items = [];
            if (!_this.itemCountInSection) {
                _this.itemCountInSection = function () { return _this.itemCount; };
            }
            var section = arg.section;
            var offset = arg.start;
            for (var count = 0; count < arg.length && section < _this.sectionCount; count++) {
                var v = null;
                if (offset < 0) {
                    v = _this.layoutSectionHeader ? _this.layoutSectionHeader(section) : null;
                }
                else {
                    var key = null;
                    if (_this.keyOfItem) {
                        key = _this.keyOfItem(offset, section);
                        if (key) {
                            v = _this.infoCache.getCachedByKey(key);
                        }
                    }
                    if (!v)
                        v = _this.layoutItem ? _this.layoutItem(offset, section) : null;
                    if (key && v) {
                        v.key = key;
                    }
                }
                if (v && _this.handleSubItem) {
                    items.push(_this.handleSubItem(v));
                }
                else {
                    items.push({});
                }
                offset++;
                if (offset >= _this.itemCountInSection(section)) {
                    section++;
                    offset = -1;
                }
            }
            return items;
        });
        return _this;
    }
    Object.defineProperty(ListView.prototype, "itemActionConfigs", {
        set: function (v) {
            var _this = this;
            this._itemActionConfigs = v;
            this.setAction('onItemAction', function (indexPath) {
                var sectionConfigArray = _this._itemActionConfigs[indexPath.sectionIndex];
                if (sectionConfigArray instanceof Array) {
                    var itemConfigArray = sectionConfigArray[indexPath.itemIndex];
                    if (itemConfigArray instanceof Array) {
                        var itemConfig = itemConfigArray[indexPath.actionIndex];
                        if (itemConfig && itemConfig.action) {
                            itemConfig.action();
                        }
                    }
                }
            });
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(ListView.prototype, "onItemClick", {
        set: function (click) {
            this.setAction('onItemClick', click);
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(ListView.prototype, "onPullDown", {
        get: function () {
            return this.actions['onPullDown'];
        },
        set: function (f) {
            if (f) {
                this.setAction('onPullDown', f);
                if (!this.refreshView) {
                    this.refreshView = PullRefreshView.viewWithFrame(0, -50, this.width, 50);
                }
            }
            else {
                delete this.actions['onPullDown'];
            }
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(ListView.prototype, "onScrollStart", {
        set: function (f) {
            this.setAction('onScrollStart', f);
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(ListView.prototype, "onScrollEnd", {
        set: function (f) {
            this.setAction('onScrollEnd', f);
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(ListView.prototype, "onLoadMore", {
        get: function () {
            return this.actions['onLoadMore'];
        },
        set: function (f) {
            if (f) {
                this.setAction('onLoadMore', f);
                if (!this.loadingView) {
                    this.loadingView = LoadingView.loadingViewWithWidth(this.width);
                }
            }
            else {
                delete this.actions['onLoadMore'];
            }
        },
        enumerable: true,
        configurable: true
    });
    ListView.viewWithFrame = function (x, y, width, height) {
        var v = new this;
        v._x = x;
        v._y = y;
        v._width = width;
        v._height = height;
        return v;
    };
    ListView.prototype.info = function () {
        var info = _super.prototype.info.call(this);
        var itemCount = 0;
        var sectionItemCounts = [];
        if (this.itemCountInSection) {
            for (var i = 0; i < this.sectionCount; i++) {
                var sectionItemCount = this.itemCountInSection(i);
                itemCount += sectionItemCount + 1;
                sectionItemCounts.push(sectionItemCount);
            }
            info.sectionItemCounts = sectionItemCounts;
        }
        else {
            sectionItemCounts.push(this.itemCount);
            info.sectionItemCounts = sectionItemCounts;
            itemCount = this.itemCount + 1;
        }
        if (this.indexTitleInSection) {
            var indexTitles = [];
            for (var i = 0; i < this.sectionCount; i++) {
                indexTitles.push(this.indexTitleInSection(i));
            }
            info.indexTitles = indexTitles;
        }
        info.indexColor = this.indexColor;
        info.estimateItemHeight = this.estimateItemHeight;
        if (this.initIndex >= 0) {
            info.initIndex = this.initIndex;
        }
        if (this.actions["getItems"]) {
            info.items = this.actions["getItems"]({ section: 0, start: -1, length: itemCount });
        }
        if (this.onPullDown && this.refreshView) {
            if (this.handleSubItem) {
                info.refreshView = this.handleSubItem(this.refreshView);
            }
            info.refreshStatus = this.refreshStatus;
        }
        if (this.loadingView) {
            if (this.handleSubItem) {
                info.loadingView = this.handleSubItem(this.loadingView);
            }
        }
        if (this.itemActionConfig) {
            var actionConfigs = [];
            for (var sectionIndex = 0; sectionIndex < this.sectionCount; sectionIndex++) {
                var sectionArray = [];
                for (var itemIndex = 0; itemIndex < sectionItemCounts[sectionIndex]; itemIndex++) {
                    var configArray = this.itemActionConfig(itemIndex, sectionIndex);
                    if (configArray instanceof Array) {
                        sectionArray.push(configArray);
                    }
                    else {
                        sectionArray.push([]);
                    }
                }
                actionConfigs.push(sectionArray);
            }
            this.itemActionConfigs = actionConfigs;
            info.itemActionConfigs = actionConfigs;
        }
        return info;
    };
    return ListView;
}(BaseView));

var AnimationInfo = (function () {
    function AnimationInfo() {
        this.duration = 0;
        this.delay = 0;
    }
    return AnimationInfo;
}());
var Animation = (function () {
    function Animation() {
        this.animationGroups = [[]];
    }
    Animation.prototype.translate = function (toValueX, param) {
        this.translateX(toValueX, param && param.paramX);
        if (param && param.toValueY !== undefined) {
            this.translateY(param.toValueY, param.paramX);
        }
        else {
            this.translateY(toValueX, param && param.paramX);
        }
        return this;
    };
    Animation.prototype.translateX = function (toValue, param) {
        this.pushAnimationInfo(3, toValue, param);
        return this;
    };
    Animation.prototype.translateY = function (toValue, param) {
        this.pushAnimationInfo(4, toValue, param);
        return this;
    };
    Animation.prototype.scale = function (toValueX, param) {
        this.scaleX(toValueX, param && param.paramX);
        if (param && param.toValueY !== undefined) {
            this.scaleY(param.toValueY, param.paramY);
        }
        else {
            this.scaleY(toValueX, param && param.paramX);
        }
        return this;
    };
    Animation.prototype.scaleX = function (toValue, param) {
        this.pushAnimationInfo(1, toValue, param);
        return this;
    };
    Animation.prototype.scaleY = function (toValue, param) {
        this.pushAnimationInfo(2, toValue, param);
        return this;
    };
    Animation.prototype.rotate = function (toValue, param) {
        this.pushAnimationInfo(5, toValue, param);
        return this;
    };
    Animation.prototype.rotateX = function (toValue, param) {
        this.pushAnimationInfo(6, toValue, param);
        return this;
    };
    Animation.prototype.rotateY = function (toValue, param) {
        this.pushAnimationInfo(7, toValue, param);
        return this;
    };
    Animation.prototype.opacity = function (toValue, param) {
        this.pushAnimationInfo(9, toValue, param);
        return this;
    };
    Animation.prototype.backgroundColor = function (toValue, param) {
        this.pushAnimationInfo(8, toValue, param);
        return this;
    };
    Animation.prototype.latestAnimationGroup = function () {
        if (this.animationGroups.length === 0) {
            this.animationGroups = [[]];
        }
        return this.animationGroups[this.animationGroups.length - 1];
    };
    Animation.prototype.pushAnimationInfo = function (animationProperty, to, param) {
        var fromParam;
        if (param && param.fromValue !== undefined) {
            fromParam = param.fromValue.toString();
        }
        this.latestAnimationGroup().push({
            property: animationProperty,
            fromValue: fromParam,
            toValue: to.toString(),
            duration: param && param.duration,
            timingFunction: param && param.timingFunction,
            delay: param && param.delay,
        });
    };
    Animation.prototype.step = function (param) {
        this.latestAnimationGroup().forEach(function (animationInfo) {
            if (animationInfo.duration === undefined) {
                animationInfo.duration = param && param.duration || 300;
            }
            if (animationInfo.timingFunction === undefined) {
                animationInfo.timingFunction = param && param.timingFunction;
            }
            if (animationInfo.delay === undefined) {
                animationInfo.delay = param && param.delay;
            }
        });
        this.animationGroups.push([]);
        return this;
    };
    Animation.prototype.export = function () {
        var result = [];
        var currentDelay = 0;
        for (var _i = 0, _a = this.animationGroups; _i < _a.length; _i++) {
            var animationGroup = _a[_i];
            var maxDuration = 0;
            for (var _b = 0, animationGroup_1 = animationGroup; _b < animationGroup_1.length; _b++) {
                var animationInfo = animationGroup_1[_b];
                maxDuration = Math.max(maxDuration, (animationInfo.duration || 0) + (animationInfo.delay || 0));
                animationInfo.delay = currentDelay + (animationInfo.delay || 0);
            }
            result = result.concat(animationGroup);
            currentDelay += maxDuration;
        }
        this.animationGroups = [[]];
        return result;
    };
    return Animation;
}());
var AnimationView = (function (_super) {
    __extends(AnimationView, _super);
    function AnimationView() {
        var _this = _super.call(this) || this;
        _this.type = 16;
        _this.animations = [];
        return _this;
    }
    AnimationView.viewWithFrame = function (x, y, width, height) {
        var v = new this;
        v.x = x;
        v.y = y;
        v.width = width;
        v.height = height;
        return v;
    };
    Object.defineProperty(AnimationView.prototype, "onCompletion", {
        set: function (completion) {
            this.setAction('onCompletion', completion);
        },
        enumerable: true,
        configurable: true
    });
    AnimationView.prototype.info = function () {
        var info = _super.prototype.info.call(this);
        info.animations = this.animations;
        return info;
    };
    return AnimationView;
}(View));

var Switch = (function (_super) {
    __extends(Switch, _super);
    function Switch() {
        var _this = _super.call(this) || this;
        _this.isOn = true;
        _this._width = 51;
        _this._height = 31;
        _this.type = 17;
        _this.setAction('onSwitch', function (arg) {
            _this.isOn = arg.isOn;
            if (_this.onSwitch) {
                _this.onSwitch(arg.isOn);
            }
        });
        return _this;
    }
    Switch.viewWithFrame = function (x, y) {
        var v = new this();
        v._x = x;
        v._y = y;
        return v;
    };
    Switch.prototype.info = function () {
        var info = _super.prototype.info.call(this);
        info.on = this.isOn;
        info.tintColor = this.tintColor || "";
        info.onTintColor = this.onTintColor || "";
        info.thumbTintColor = this.thumbTintColor || "";
        return info;
    };
    return Switch;
}(BaseView));

var PicassoController = (function () {
    function PicassoController() {
    }
    PicassoController.prototype.onLoad = function () {
    };
    PicassoController.prototype.onLiveLoad = function () {
    };
    return PicassoController;
}());

var VC = (function (_super) {
    __extends(VC, _super);
    function VC() {
        var _this = _super.call(this) || this;
        _this.infoCache = new ModelCache;
        _this.infoFilter = function (v) {
            if (!v.key) {
                if (v.hidden) {
                    return {
                        hostId: v.hostId,
                        viewId: v.viewId,
                        parentId: v.parentView ? v.parentView.viewId : '',
                        hidden: true,
                        type: v.type,
                    };
                }
                return v.info();
            }
            var cached = _this.infoCache.getCached(v);
            if (cached) {
                _this.mergeActionMap(cached, v);
                return {
                    key: hash(v.key),
                    hostId: v.hostId
                };
            }
            else {
                _this.infoCache.setCache(v);
                var ret = v.info();
                ret.key = hash(v.key);
                return ret;
            }
        };
        _this.childrenVC = {};
        _this.childrenId = 0;
        return _this;
    }
    VC.prototype.onLoad = function () {
        _super.prototype.onLoad.call(this);
    };
    VC.prototype.onAppear = function () {
    };
    VC.prototype.onDisappear = function () {
    };
    VC.prototype.onDestroy = function () {
        picasso_size_cache.removeCache(this.hostId);
    };
    VC.prototype.onFrameChanged = function (frame) {
        this.options.width = frame.width;
        this.options.height = frame.height;
        this.needLayout();
    };
    VC.prototype.onKeyboardStatusChanged = function (keyboardInfo) {
    };
    VC.prototype.onLayoutFinished = function () {
        this._cachedActions = undefined;
    };
    Object.defineProperty(VC.prototype, "width", {
        get: function () {
            return this.options.width;
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(VC.prototype, "height", {
        get: function () {
            return this.options.height;
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(VC.prototype, "extraData", {
        get: function () {
            return this.options.extraData;
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(VC.prototype, "bounds", {
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
    VC.prototype.getActionMap = function (viewId) {
        if (this._cachedActions && this._cachedActions[viewId]) {
            return this._cachedActions[viewId];
        }
        if (this._actions && this._actions[viewId]) {
            return this._actions[viewId];
        }
        return undefined;
    };
    VC.prototype.dispatchActionByNative = function (args) {
        pLogInfo('args=' + JSON.stringify(args));
        for (var _i = 0, _a = Object.keys(this.childrenVC); _i < _a.length; _i++) {
            var key = _a[_i];
            var vc = this.childrenVC[key];
            if (!vc) {
                continue;
            }
            var childActionMap = vc.getActionMap(args.id);
            if (childActionMap) {
                if (childActionMap[args.action]) {
                    return childActionMap[args.action](args.param);
                }
                pLogInfo("Cannot find ActionMap in ChildVC " + key + " for " + args.id + ",action=" + args.action);
                return;
            }
        }
        var actionMap = this.getActionMap(args.id);
        if (!actionMap) {
            pLogInfo("Cannnot find ActionMap for " + args.id);
            return;
        }
        if (!actionMap[args.action]) {
            pLogInfo("Cannnot find Action callback for " + args.id + ", action = " + args.action);
            return;
        }
        return actionMap[args.action](args.param);
    };
    VC.prototype.mergeActionMap = function (cached, v) {
        this._actions[cached.viewId] = this._actions[v.viewId];
        if (cached instanceof View && v instanceof View
            && cached.subviews && v.subviews && cached.subviews.length === v.subviews.length) {
            for (var i = 0; i < cached.subviews.length; i++) {
                this.mergeActionMap(cached.subviews[i], v.subviews[i]);
            }
        }
    };
    VC.prototype.dispatchLayoutByNative = function () {
        this._cachedActions = this._actions;
        this._actions = {};
        var view = this.layout();
        if (this.traversalView(view)) {
            view.key = null;
        }
        this.stashedView = view;
        return this.infoFilter(view);
    };
    VC.prototype.updateSizeCache = function (sizeCache) {
        picasso_size_cache.addNativeCache(sizeCache, this.hostId);
    };
    VC.prototype.traversalView = function (view) {
        var _this = this;
        var secondLayout = false;
        if (view instanceof View) {
            view.subviews.forEach(function (element) {
                var ret = _this.traversalView(element);
                if (!secondLayout) {
                    secondLayout = ret;
                }
            });
        }
        if (view instanceof TextView && !secondLayout) {
            secondLayout = view.needSizeToFit;
        }
        if (view.handleSubItem) {
            view.handleSubItem = function (v) {
                if (_this.infoCache.getCached(v)) {
                    _this.traversalView(v);
                    return _this.infoFilter(v);
                }
                if (_this.traversalView(v)) {
                    v.key = null;
                }
                return _this.infoFilter(v);
            };
        }
        if (view.infoCache) {
            view.infoCache = this.infoCache;
        }
        this._actions[view.viewId] = view.actions;
        view.hostId = this.hostId;
        return secondLayout;
    };
    VC.prototype.needLayout = function () {
        this.context.sendMessage('vc', 'needLayout', null);
    };
    VC.prototype.sendMsg = function (params) {
        this.context.sendMessage("vc", "sendMsg", params);
    };
    VC.prototype.dispatchChildLayoutByNative = function (args) {
        if (this.childrenVC[args.vcId]) {
            return this.childrenVC[args.vcId].dispatchLayoutByNative();
        }
        pLogInfo('找不到对应的childVC');
        return {};
    };
    VC.prototype.callChildVCByNative = function (args) {
        var vc = this.childrenVC[args.__vcid__];
        if (vc && vc[args.__method__]) {
            vc[args.__method__](args);
        }
    };
    VC.prototype.configVC = function (clz, config) {
        var _this = this;
        var childVC = new clz();
        childVC.hostId = this.hostId;
        childVC.context = this.context;
        if (config) {
            childVC.intentData = config.data;
            childVC.options = config.options || { width: this.width, height: this.height };
        }
        else {
            childVC.options = { width: this.width, height: this.height };
        }
        var vcId = this.childrenId++;
        this.childrenVC[vcId] = childVC;
        childVC.needLayout = function () {
            _this.context.sendMessage('vc', 'needChildLayout', { vcId: vcId });
        };
        return vcId;
    };
    return VC;
}(PicassoController));

function clone(obj) {
    if (Array.isArray(obj))
        return obj.slice();
    var keys = Object.keys(obj);
    var result = {};
    for (var _i = 0, keys_1 = keys; _i < keys_1.length; _i++) {
        var key = keys_1[_i];
        if (key === "___objectid___")
            continue;
        result[key] = obj[key];
    }
    return result;
}
function isObject(o) {
    var type = typeof o;
    return o != null && (type === 'object' || type === 'function');
}
function _merge(target, obj, deep) {
    if (!target)
        return {};
    if (obj == null)
        return target;
    var keys = Object.keys(obj);
    if (!keys.length)
        return target;
    var result = target;
    var virgin = false;
    for (var _i = 0, keys_2 = keys; _i < keys_2.length; _i++) {
        var key = keys_2[_i];
        var next = obj[key];
        if (deep && isObject(result[key]) && isObject(next)) {
            next = _merge(result[key], next, deep);
        }
        if (next === undefined || next === result[key])
            continue;
        if (!virgin) {
            virgin = true;
            result = clone(result);
        }
        result[key] = next;
    }
    return result;
}

(function (Immutable) {
    function merge(target, obj) {
        return _merge(target, obj, false);
    }
    Immutable.merge = merge;
    function mergeDeep(target, obj) {
        return _merge(target, obj, true);
    }
    Immutable.mergeDeep = mergeDeep;
    function set(key, value, obj) {
        var sandbox;
        if (typeof obj === "object") {
            sandbox = {};
        }
        else {
            sandbox = [];
        }
        sandbox[key] = value;
        return mergeDeep(obj, sandbox);
    }
    Immutable.set = set;
    function update(obj, updater) {
        var sandbox = {};
        updater(sandbox);
        return mergeDeep(obj, sandbox);
    }
    Immutable.update = update;
    function insert(array, index, value) {
        index = index < array.length && index >= 0 ? index : array.length;
        var result = array.slice();
        result.splice(index, 0, value);
        return result;
    }
    Immutable.insert = insert;
    function remove(array, index) {
        var result = array.slice();
        result.splice(index, 1);
        return result;
    }
    Immutable.remove = remove;
    function range(from, to) {
        if (from === to)
            return [from];
        if (from > to)
            return [];
        var ret = [];
        for (var i = from; i < to + 1; i++) {
            ret.push(i);
        }
        return ret;
    }
    Immutable.range = range;
    function flatten(list, depth) {
        if (depth === void 0) { depth = 10; }
        if (depth === 0)
            return list;
        return list.reduce(function (accumulator, item) {
            if (Array.isArray(item)) {
                accumulator.push.apply(accumulator, flatten(item, depth - 1));
            }
            else {
                accumulator.push(item);
            }
            return accumulator;
        }, []);
    }
    Immutable.flatten = flatten;
})(exports.Immutable || (exports.Immutable = {}));

exports.log = pLogInfo;
exports.logw = pLogWarning;
exports.loge = pLogError;
exports.BaseView = BaseView;
exports.View = View;
exports.Button = Button;
exports.ImageView = ImageView;
exports.TextView = TextView;
exports.PicassoSizeCache = PicassoSizeCache;
exports.picasso_size_cache = picasso_size_cache;
exports.LayoutContainer = LayoutContainer;
exports.vlayout = vlayout;
exports.hlayout = hlayout;
exports.FlexBox = FlexBox;
exports.flexBox = flexBox;
exports.ScrollView = ScrollView;
exports.InputView = InputView;
exports.ListItem = ListItem;
exports.ListView = ListView;
exports.PullRefreshView = PullRefreshView;
exports.LoadingView = LoadingView;
exports.ActivityIndicator = ActivityIndicator;
exports.AnimationInfo = AnimationInfo;
exports.Animation = Animation;
exports.AnimationView = AnimationView;
exports.Switch = Switch;
exports.VC = VC;
exports.PicassoController = PicassoController;

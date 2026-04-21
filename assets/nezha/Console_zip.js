"use strict";

// 限制对象深度的序列化函数
function NezhaJsonStringifySafe(
  obj,
  replacer,
  spaces,
  cycleReplacer,
  maxDepth
) {
  if (maxDepth === undefined) {
    maxDepth = 5; // 默认限制5层深度
  }

  var res = JSON.stringify(
    obj,
    NezhaJsonSerializerSafe(replacer, cycleReplacer, maxDepth),
    spaces
  );
  if (res == "{}" || res == "") {
    res = JSON.stringify(obj, Object.getOwnPropertyNames(obj));
  }
  if (res == "{}" || res == "") {
    res = obj.toString();
  }
  return res;
}

function NezhaJsonSerializerSafe(replacer, cycleReplacer, maxDepth) {
  var stack = [],
    keys = [];

  if (cycleReplacer == null) {
    cycleReplacer = function (key, value) {
      if (stack[0] === value) {
        return "[Circular ~]";
      }
      return (
        "[Circular ~." + keys.slice(0, stack.indexOf(value)).join(".") + "]"
      );
    };
  }

  return function (key, value) {
    // 检查循环引用
    if (stack.length > 0) {
      var thisPos = stack.indexOf(this);
      ~thisPos ? stack.splice(thisPos + 1) : stack.push(this);
      ~thisPos ? keys.splice(thisPos, Infinity, key) : keys.push(key);
      if (~stack.indexOf(value)) {
        value = cycleReplacer.call(this, key, value);
      }
    } else {
      stack.push(value);
    }

    // 计算当前深度 - 通过栈的长度
    var currentDepth = stack.length;

    // 检查深度限制 - 当深度达到限制时截断对象
    if (
      currentDepth >= maxDepth &&
      typeof value === "object" &&
      value !== null
    ) {
      return "[Object]";
    }

    return replacer == null ? value : replacer.call(this, key, value);
  };
}

var _typeof =
  typeof Symbol === "function" && typeof Symbol.iterator === "symbol"
    ? function (obj) {
        return typeof obj;
      }
    : function (obj) {
        return obj &&
          typeof Symbol === "function" &&
          obj.constructor === Symbol &&
          obj !== Symbol.prototype
          ? "symbol"
          : typeof obj;
      };

function formatValue(args) {
  return Object.values(args).map(function (v) {
    var value;
    if (typeof v === "undefined") {
      value = "undefined";
    } else if (
      (typeof v === "undefined" ? "undefined" : _typeof(v)) === "object"
    ) {
      // 使用限制深度的序列化
      value = NezhaJsonStringifySafe(v, null, 0, null, 5);
    } else {
      value = v.toString();
    }
    return typeof value === "string" ? value.substring(0, 3000) : value;
  });
}

function log(tag, type, args) {
  // 使用 formatValue 来限制对象深度
  __NEZHA_BRIDGE__LOG(tag + " " + type + ": " + formatValue(args));
}

var originalLog = console.log;
var originalInfo = console.info;
var originalWarn = console.warn;
var originalError = console.error;
var originalDebug = console.debug;
console.log = function () {
  log("console", "log", arguments);
};
console.info = function () {
  log("console", "info", arguments);
};
console.warn = function () {
  log("console", "warning", arguments);
};
console.error = function () {
  log("console", "error", arguments);
};
console.debug = function () {
  log("console", "debug", arguments);

};

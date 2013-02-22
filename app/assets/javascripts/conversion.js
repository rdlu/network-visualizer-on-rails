//faz a conversao de valores nos gráficos do flot e em outros lugares
var conversion = {
    metrics:{
        rtt:{ original:"s", target:"ms", system:"si", precision:2 },
        jitter:{ original:"s", target:"ms", system:"si", precision:2 },
        owd:{ original:"s", target:"ms", system:"si", precision:2 },
        loss:{ original:"%", target:"%", system:null }, //nao precisa de conversao
        pom:{ original:"%", target:"%", system:null, precision:2 },
        mos:{ original:"", target:"", system:null, precision:2 },
        capacity:{ original:"bps", target:"Mbps", system:"si", precision:3 },
        throughput:{ original:"bps", target:"Mbps", system:"si", precision:3 },
        throughput_tcp:{ original:"bps", target:"Mbps", system:"si", precision:3 },
        throughput_http:{ original:"bps", target:"Mbps", system:"si", precision:3 }
    },
    valueFromMetric:function (metric, value) {
        var metricProperties = conversion.metrics[metric];

        if (metricProperties.system == "si") {
            return $u(value, metricProperties.original).as(metricProperties.target).val(metricProperties.precision);
        }

        return value;
    },
    stringFromMetric:function (metric, value, axis) {
        //console.log(metric,value);
        var metricProperties = this.metrics[metric];

        //var precision = (axis) ? 0 : metricProperties.precision;
        var precision = metricProperties.precision;

        if (metricProperties.system == "si") {
            return $u(value, metricProperties.original).as(metricProperties.target).toString(precision);
        }

        return value + " " + metricProperties.original;
    },
    _value:function (metric, value) {
        var metricProperties = this.metrics[metric];

        if (metricProperties.system == "si") {
            return $u(value, metricProperties.original).as(metricProperties.original).val(0);
        }

        return value;
    }
};

/**
 * Biblioteca basica de conversao SI
 * Exemplo de uso: $u(1, 'g').as('kg').val(); // converts one gram to kg
 */
(function () {
    var table = {};

    window.unitConverter = function (value, unit) {
        this.value = value;
        if (unit) {
            this.currentUnit = unit;
        }
    };
    unitConverter.prototype.as = function (targetUnit) {
        this.targetUnit = targetUnit;
        return this;
    };
    unitConverter.prototype.is = function (currentUnit) {
        this.currentUnit = currentUnit;
        return this;
    };
    unitConverter.prototype.val = function (precision) {
        // first, convert from the current value to the base unit
        var target = table[this.targetUnit];
        var current = table[this.currentUnit];
        if (target.base != current.base) {
            throw new Error('Incompatible units; cannot convert from "' + this.currentUnit + '" to "' + this.targetUnit + '"');
        }

        if (current.factor < 0) var precision = parseInt(current.factor * (-1));
        //console.info(precision,current.factor,current.multiplier);

        return (this.value * (current.multiplier / target.multiplier)).toFixed(precision);
    };
    unitConverter.prototype.toString = function (precision) {
        return this.val(precision) + '' + this.targetUnit;
    };
    unitConverter.prototype.debug = function () {
        return this.value + ' ' + this.currentUnit + ' is ' + this.val() + ' ' + this.targetUnit;
    };
    unitConverter.addUnit = function (baseUnit, actualUnit, multiplier, factor) {
        table[actualUnit] = { base:baseUnit, actual:actualUnit, multiplier:multiplier, factor:factor };
    };

    var prefixes = ['Y', 'Z', 'E', 'P', 'T', 'G', 'M', 'k', 'h', 'da', '', 'd', 'c', 'm', 'u', 'n', 'p', 'f', 'a', 'z', 'y'];
    var factors = [24, 21, 18, 15, 12, 9, 6, 3, 2, 1, 0, -1, -2, -3, -6, -9, -12, -15, -18, -21, -24];
    // SI units only, that follow the mg/kg/dg/cg type of format
    var units = ['g', 'b', 'l', 'm', 'bps', 's'];

    for (var j = 0; j < units.length; j++) {
        var base = units[j];
        for (var i = 0; i < prefixes.length; i++) {
            unitConverter.addUnit(base, prefixes[i] + base, Math.pow(10, factors[i]), factors[i]);
        }
    }

    // we use the SI gram unit as the base; this allows
    // us to convert between SI and English units
    unitConverter.addUnit('g', 'ounce', 28.3495231, 1);
    unitConverter.addUnit('g', 'oz', 28.3495231, 1);
    unitConverter.addUnit('g', 'pound', 453.59237, 1);
    unitConverter.addUnit('g', 'lb', 453.59237, 1);
    unitConverter.addUnit("%", "%", 1, 1);
    unitConverter.addUnit("unit", "unit", 1, 1);


    window.$u = function (value, unit) {
        var u = new window.unitConverter(value, unit);
        return u;
    };

})();

Number.prototype.padZero = function (len) {
    var s = String(this), c = '0';
    len = len || 2;
    while (s.length < len) s = c + s;
    return s;
}
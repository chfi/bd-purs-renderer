exports.tierCanvasContext = function(tier) {
    return tier.viewport.getContext("2d");
};

exports.setTierHeight = function(tier) {
    return function(height) {
        tier.viewport.height = height;
        tier.layoutHeight = height;
        tier.updateHeight();

        tier.norigin = tier.browser.viewStart;

        tier.originHaxx = 0;
        tier.browser.arrangeTiers();
    };
};

exports.tierFeatures = function(tier) {
    return tier.currentFeatures;
};

exports.tierScaleFactor = function(tier) {
    return function(scaleY) {
        var sf = { bpPerPixel: 1/tier.browser.scale,
                   viewStart: tier.browser.viewStart,
                   canvasHeight: tier.viewport.height,
                   scaleY: scaleY(tier.viewport.height)
                 };
        return sf;
    };
};


exports.runEff = function(f) {
    f();
};

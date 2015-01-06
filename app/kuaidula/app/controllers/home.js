var express = require("express"),
    router = express.Router(),
    mongoose = require("mongoose"),
    Article = mongoose.model("Article");


// seed
var env = process.env.NODE_ENV || "development";
if (env == "development" || false) {
    Article.find({}).remove(function() {
        Article.create({
            title: "盘点2014中国高铁出海记:李克强亲自拧螺丝",
            keywords: ["高铁", "李克强"],
            paragraphs: [{
                sentences: [{
                    words: ["高铁", "已经", "成为", "一张", "新的", "中国", "外交", "名片", "。"]
                }, {
                    words: ["2014年", "，", "中国", "高铁", "的", "走出去", "之路", "一路高歌", "。"]
                }, {
                    words: ["有着", "\"超级高铁推销员\"", "和", "\"最强营销总监\"", "等", "美称", "的", "李克强", "总理", "，", "向", "外方", "推荐", "中国", "高铁", "几乎", "成了", "其", "出访", "的", "必做", "功课", "，", "这", "同时", "也", "体现", "了", "中国", "政府", "对", "高铁", "走向", "国际", "市场", "的", "决心", "和", "信心", "。"]
                }]
            }, {
                sentences: [{
                    words: ["据", "《中国经济周刊》", "不完全", "统计", "，", "2014年", "李克强", "总理", "已", "向", "12个", "国家", "表达", "了", "合作", "建设", "高铁", "的", "意愿", "。"]
                }, {
                    words: ["在", "中国", "高端", "装备", "制造业", "遭遇", "世界", "经济", "危机", "和", "面临", "其他", "国家", "的", "激烈", "竞争", "之际", "，", "高铁", "的", "出现", "成为", "中国", "制造", "转型", "升级", "的", "一大", "亮点", "。"]
                }, {
                    words: ["中国", "高铁", "企业", "频频", "斩获", "海外", "大单", "，", "中国", "南车", "和", "中国", "北车", "海外", "订单", "的", "连续", "增长", "已", "成为", "中国", "高铁", "开往", "世界", "的", "佐证", "。"]
                }, {
                    words: ["两家", "企业", "2014年", "上半年", "的", "出口", "签约", "额", "总计", "已达", "45亿", "美元", "以上", "。"]
                }]
            }],
            url: "http://news.sina.com.cn/c/2015-01-03/130731355265.shtml",
            time: 1420298104,
            censored: true,
            censor: "1"
        });
        console.log("hello");
    });
}

module.exports = function(app) {
    app.use("/", router);
};

router.get("/", function(req, res, next) {

    Article.find(function(err, articles) {
        if (err) return next(err);
        res.render("index", {
            title: "Welcome to Kuaidula App, :-)",
        });
    });
});

// APIs

router.get("/0.1/articles/:filter", function(req, res, next) {
    var filter = req.params["filter"];
    console.log("requesting article: " + filter);
    if (filter == "all") {
        Article.find({
            censored: true
        }, function(err, articles) {
            if (err) return next(err);
            // res.writeHead(200, {
            //     "Content-Type": "application/json"
            // });
            res.end(JSON.stringify({
                articles: articles
            }));
        });
    } else {
        res.status(404) // HTTP status 404: NotFound
            .send("Not found");
    }
});
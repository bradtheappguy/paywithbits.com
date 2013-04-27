
/*
 * GET home page.
 */

exports.index = function(req, res){
  res.render('index', { title: 'Express', body: "Hello World" });
};

exports.request_payment = function(req, res){
    res.render('index', { title: 'Express', body: "Hello World" });
};

exports.send_payment = function(req, res){
    res.render('index', { title: 'Express', body: "Hello World" });
};
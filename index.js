if(process.env.NODE_ENV){
  console.log("Loading newrelic")
  require('newrelic');
}
require('dotenv').config({silent: true})
require('./customFunctions');
var processType = process.argv[2] || "web"

if(processType === "web"){
    require('coffee-register')
    require("./web/index")
}else if(processType === "worker"){
    require('coffee-register')
    require("./worker/index")
}else{
    throw Error(`Invalid process type "${processType}"`)
}

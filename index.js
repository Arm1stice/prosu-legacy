require('dotenv').config({silent: true})
var processType = process.argv[2] || "web"

if(processType === "web"){
    require('coffee-script').register()
    require("./web/index")
}else if(processType === "worker"){
    require('coffee-script').register()
    require("./worker/index")
}else{
    throw Error(`Invalid process type "${processType}"`)
}

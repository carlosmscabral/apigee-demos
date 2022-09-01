var routeProb = context.getVariable("route_prob");
print(routeProb);
 
var rand = Math.random() *100;
print(rand);
 
 if (rand < routeProb ) {
     goToNew = "true";
 } else {
     goToNew = "false";
 }
 
 print("results: "+ goToNew);
 context.setVariable("goToNew", goToNew);
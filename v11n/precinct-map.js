// Constants
var SVG_ID = "china-map";

// Global Variables
var width = 1000,
    height = 500;
var svg = d3.select("body").append("svg")
    .attr("width", width)
    .attr("height", height);
var g = svg.append("g").attr("id", SVG_ID);
var colors = d3.scale.category20c();
var path;
var projection = d3.geo.mercator()
    .scale(1)
    .translate([0, 0]);
var precinctData;
var precincts;
var stopData;

function drawMap() {
  path = d3.geo.path()
    .projection(projection);

  // Compute the bounds of a feature of interest,1 then derive scale & translate.
  var b = path.bounds(precinctData),
    s = .95 / Math.max((b[1][0] - b[0][0]) / width, (b[1][1] - b[0][1]) / height),
    t = [(width - s * (b[1][0] + b[0][0])) / 2, ((height - s * (b[1][1] + b[0][1])) / 2)];

  // Update the projection to use computed scale & translate.
  projection
      .scale(s)
      .translate(t);

  // Update our projection
  path.projection(projection);

  // Plot the overall map of China
  g.append("path")
      .datum(precinctData)
      .attr("d", path)
      .attr("fill", "#F5F5DC");
}

function drawPrecincts() {
  precincts = g.selectAll(".subunit-prec")
    .data(precinctData.features)
  .enter().append("path")
    .attr("class", function(d) { return "subunit-prec"; })
    .style("fill", function(d) { return colors(d.properties.Precinct)})
    .attr("stroke", "white")
    .attr("d", path);
}

function comparePrecincts(prec1,prec2) {
  var prec1 = prec1.properties.Precinct;
  var prec2 = prec2.properties.Precinct;

  var prec1Value = stopData[prec1];
  var prec2Value = stopData[prec2];

  return prec2Value - prec2Value;
}

function addData() {
  g.selectAll(".bubble").remove();

  var scale = d3.scale.sqrt().domain([0,25000]).range([1,25]);

  var availablePrecincts = [];
  for (var i = 0; i < precinctData.features.length; i++) {
    var province = precinctData.features[i];
    if (province.properties.Precinct in stopData) {
      availablePrecincts.push(province);
    }
  }
  availablePrecincts = availablePrecincts.sort(comparePrecincts);

  console.log(availablePrecincts);
  // Add the desired provinces, set functions for mouseover and mouseout
  provSubunits = g.selectAll(".subunit-prov")
    .data(availablePrecincts)
  .enter().append("circle")
    .attr("transform", function(d) { return "translate(" + path.centroid(d) + ")"; })
    .attr("r", function(d) { return scale(stopData[d.properties.Precinct]) + "px"; })
    .attr("class", "bubble")
    .on("mouseover", function(precinct,i) {
      var div = d3.select("body").append("div")   
     .attr("class", "nvtooltip")               
     .style("opacity", 0);
      div.transition()        
        .duration(200)      
        .style("opacity", .9);
      div.html('<h3 style="background-color: '
                + colors(precinct.properties.Precinct) + '">Precinct ' + precinct.properties.Precinct + '</h3>'
                + '<p><b>' + stopData[precinct.properties.Precinct] + '</b> occurrences</p>')  
                .style("left", (d3.event.pageX) + "px")     
                .style("top", (d3.event.pageY - 28) + "px")
        .style("left", (d3.event.pageX) + "px")     
        .style("top", (d3.event.pageY - 28) + "px");
    })   
    .on("mouseout", function(precinct) {
      d3.selectAll(".nvtooltip").remove();
    });
}

// Draw the map of China given our previously parsed GeoJSON.
d3.json("data/precincts.json", function(error, precinct) {
  precinctData = precinct;
  drawMap();
  drawPrecincts();
  addData();
});

d3.csv("data/precincts.csv", function(error, data) {
  stopData = {};
  data.forEach(function(d) {
    stopData[parseInt(d.precinct)] = parseInt(d.stops);
  });
});

// Constants
var SVG_ID = "china-map";

// Global Variables
var width = 1000,
    height = 500;
var svg = d3.select("body").append("svg")
    .attr("width", width)
    .attr("height", height)
    .attr("id", "precinct-map");
var g = svg.append("g").attr("id", SVG_ID);
var colorScale = ["#fed976", "#feb24c", "#fd8d3c", "#f03b20", "#bd0026"];
var colorScaleRange;
var path;
var projection = d3.geo.mercator()
    .scale(1)
    .translate([0, 0]);
var precinctData;
var precincts;
var stopData;

function getColorSizeScale() {
  var keys = Object.keys(stopData);
  var stops = [];
  for (var i = 0; i < keys.length; i++) {
    stops.push(stopData[keys[i]]);
  }
  var domain = d3.extent(stops);
  return d3.scale.quantize().domain(d3.extent(stops)).range(colorScale);
}

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
  colorScaleRange = getColorSizeScale();
  precincts = g.selectAll(".subunit-prec")
    .data(precinctData.features)
  .enter().append("path")
    .attr("class", function(d) { return "subunit-prec"; })
    .style("fill", function(d) {
      var color = colorScaleRange(stopData[d.properties.Precinct]); return color;
    })
    .attr("stroke", "black")
    .attr("d", path)
    .on("mouseover", function(precinct,i) {
      var div = d3.select("body").append("div")
     .attr("class", "nvtooltip")
     .style("opacity", 0);
      div.transition()
        .duration(200)
        .style("opacity", .9);
      div.html('<h3 style="background-color: '
                + colorScaleRange(stopData[precinct.properties.Precinct]) + '">Precinct ' + precinct.properties.Precinct + '</h3>'
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

function drawLegend() {
  var legend = svg.selectAll(".legend")
      .data(colorScale)
    .enter().append("g")
      .attr("class", "legend")
      .attr("transform", function(d, i) { return "translate(30," + i * 20 + ")"; });

  legend.append("rect")
      .attr("x", width - 18)
      .attr("width", 18)
      .attr("height", 18)
      .style("fill", function(d,i) { return colorScale[i]; });

  // draw legend text
  legend.append("text")
      .attr("x", width - 24)
      .attr("y", 9)
      .attr("dy", ".35em")
      .style("text-anchor", "end")
      .text(function(d,i) {
        var extent = colorScaleRange.invertExtent(colorScale[i]); 
        return parseInt(extent[0]) + " - " + parseInt(extent[1]) + " stops";
      });
}

// Draw the map of China given our previously parsed GeoJSON.
d3.json("data/precincts.json", function(error, precinct) {
  precinctData = precinct;
  drawMap();
  drawPrecincts();
  drawLegend();
});

d3.csv("data/precincts.csv", function(error, data) {
  stopData = {};
  data.forEach(function(d) {
    stopData[parseInt(d.precinct)] = parseInt(d.stops);
  });
});

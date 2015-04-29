var STATIC_LABEL = "data/";

var width = 960,
    height = 136,
    cellSize = 17; // cell size

var day = d3.time.format("%w"),
    week = d3.time.format("%U"),
    percent = d3.format(".1%"),
    format = d3.time.format("%Y-%m-%d");

var MAX = 3200;
var MIN = 193;

var data;

var color_choices = ["#D73027","#F46D43","#FDAE61","#FEE08B","#FFFFBF","#D9EF8B","#A6D96A","#66BD63","#1A9850","#006837","#A50026"];
var color = d3.scale.quantize()
    .domain([MIN,MAX])
    .range(d3.range(11).map(function(d) { return color_choices[d] }));

var svg = d3.select("#main").selectAll("svg.calendar")
    .data(d3.range(2012, 2013))
  .enter().append("svg")
    .attr("width", width)
    .attr("height", height)
    .attr("class", "RdYlGn")
    .attr("class", "calendar")
  .append("g")
    .attr("transform", "translate(" + ((width - cellSize * 53) / 2) + "," + (height - cellSize * 7 - 1) + ")");

svg.append("text")
    .attr("transform", "translate(-6," + cellSize * 3.5 + ")rotate(-90)")
    .style("text-anchor", "middle")
    .text(function(d) { return d; });

var rect = svg.selectAll(".day")
    .data(function(d) { return d3.time.days(new Date(d, 0, 1), new Date(d + 1, 0, 1)); })
  .enter().append("rect")
    .attr("class", "day")
    .attr("width", cellSize)
    .attr("height", cellSize)
    .attr("x", function(d) { return week(d) * cellSize; })
    .attr("y", function(d) { return day(d) * cellSize; })
    .datum(format)
    .on("mouseover", function(day) {
      var div = d3.select("body").append("div")   
     .attr("class", "nvtooltip")               
     .style("opacity", 0);
      div.transition()        
        .duration(200)      
        .style("opacity", .9);
      div.html('<h3 style="background-color: '
                + color(parseInt(data[day])) + '">' + day + '</h3>'
                + '<p><b>' + data[day] + '</b> occurrences</p>')  
                .style("left", (d3.event.pageX) + "px")     
                .style("top", (d3.event.pageY - 28) + "px")
        .style("left", (d3.event.pageX) + "px")     
        .style("top", (d3.event.pageY - 28) + "px");
    })   
    .on("mouseout", function(precinct) {
      d3.selectAll(".nvtooltip").remove();
    });;

rect.append("title")
    .text(function(d) { return d; });

svg.selectAll(".month")
    .data(function(d) { return d3.time.months(new Date(d, 0, 1), new Date(d + 1, 0, 1)); })
  .enter().append("path")
    .attr("class", "month")
    .attr("d", monthPath);

d3.csv(STATIC_LABEL + "calendar.csv", function(error, csv) {
  data = d3.nest()
    .key(function(d) { return d.datestop; })
    .rollup(function(d) { return (d[0].num_stops); })
    .map(csv);

  rect.filter(function(d) { return d in data; })
      .attr("class", function(d) { return "day"; })
      .style("fill", function(d) { return color(parseInt(data[d])); })
    .select("title")
      .text(function(d) { return d + ": " + percent(data[d]); });
});

function monthPath(t0) {
  var t1 = new Date(t0.getFullYear(), t0.getMonth() + 1, 0),
      d0 = +day(t0), w0 = +week(t0),
      d1 = +day(t1), w1 = +week(t1);
  return "M" + (w0 + 1) * cellSize + "," + d0 * cellSize
      + "H" + w0 * cellSize + "V" + 7 * cellSize
      + "H" + w1 * cellSize + "V" + (d1 + 1) * cellSize
      + "H" + (w1 + 1) * cellSize + "V" + 0
      + "H" + (w0 + 1) * cellSize + "Z";
}

d3.select(self.frameElement).style("height", "2910px");
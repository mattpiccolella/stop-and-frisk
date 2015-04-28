// Constants.
var WIDTH = 900;
var HEIGHT = 550;
var X_OFFSET = 220;
var Y_OFFSET = 70;
var X_SCALE = WIDTH - X_OFFSET;
var Y_SCALE = HEIGHT - Y_OFFSET;
var STATIC_STRING = "data/";

// Global variables.
var chart;
var colors = d3.scale.category20();
var labels;
var values;
var xDomain;
// Info Box div to add the tooltips
var div = d3.select("body").append("div")   
  .attr("class", "nvtooltip")               
  .style("opacity", 0);

function getXScale() {
  return d3.scale.linear().domain(d3.extent(values)).range([0,X_SCALE]);
}
function getYScale() {
  return d3.scale.linear().domain([0,labels.length]).range([0,Y_SCALE]);
}

var canvas = d3.select('#wrapper')
    .append('svg')
    .attr({'width':WIDTH,'height':HEIGHT})
    .attr("id","bar-graph");

function getXAxis() {
  var xScale = getXScale();
  return d3.svg.axis().orient('bottom').scale(xScale);
}

function getYAxis() {
  var yScale = getYScale();
  return d3.svg.axis().orient('left').scale(yScale).tickSize(2)
    .tickFormat(function(d,i) { return labels[i]; })
    .tickValues(d3.range(labels.length));
}

function addAxes() {
  var xAxis = getXAxis();
  var yAxis = getYAxis();
  canvas.append('g')
    .attr("transform", "translate(290,0)")
    .attr('id','yaxis')
    .call(yAxis);

  canvas.append('g')
    .attr("transform", "translate(290,480)")
    .attr('id','xaxis')
    .call(xAxis);
}

function addBars() {
  var xScale = getXScale();
  var yScale = getYScale();
  chart = canvas.append('g')
            .attr("transform", "translate(210,0)")
            .attr('id','bars')
            .selectAll('rect')
            .data(values)
            .enter()
            .append('rect')
            .attr('class','rect-bar')
            .attr('height',19)
            .attr({'x':80,'y':function(d,i){ return yScale(i) + 15; }})
            .style('fill',function(d,i){ return colors(i); })
            .attr('width',function(d){ return 0; })
            .on("mouseover", function(d,i){
              var div = d3.select("body").append("div")   
                .attr("class", "nvtooltip")               
                .style("opacity", 0);
              div.transition()        
                .duration(200)      
                .style("opacity", .9);      
              div.html('<h3 style="background-color: '
                + colors(i) + '">' + labels[i+1] + '</h3>'
                + '<p><b>' + d + '</b> occurrences</p>')  
                .style("left", (d3.event.pageX) + "px")     
                .style("top", (d3.event.pageY - 28) + "px");       
            })
            .on("mouseout", function(){
              d3.selectAll(".nvtooltip").remove();
            }); 

  d3.select("svg").selectAll("rect")
  .data(values)
  .transition()
    .duration(1000) 
  .attr("width", function(d) {return xScale(d); });
}

function addChart() {
  addAxes();
  addBars();
}

d3.csv(STATIC_STRING + "barchart.csv", function(error, data) {
  labels = [''];
  values = [];
  data.forEach(function(d) {
    labels.push(d.label);
    values.push(parseInt(d.value));
  });
  addChart();
});



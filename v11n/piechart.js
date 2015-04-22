// Constants
var DEFAULT_LABEL = 'days';

// Global variables
var chart;
var chartData = {};
var currentLabel = DEFAULT_LABEL;

var showTooltip = function(key, y, e, graph) {
  return '<h3 style="background-color: '
    + e.color + '">' + key + '</h3>'
    + '<p><b>' + y.substring(0, y.indexOf('.')) + '</b> stops</p>';
}

var addPieChart = function() {
  chart = nv.models.pieChart()
      .x(function(d) { return d.label })
      .y(function(d) { return d.measure })
      .showLabels(true)
      .labelThreshold(.05) 
      .labelType("percent")
      .tooltipContent(showTooltip)
      .donut(true)
      .donutRatio(0.35);

  d3.select("#chart2 svg")
      .datum(chartData[currentLabel])
      .transition().duration(350)
      .call(chart);

  return chart;
}

d3.csv("data/stats.csv", function(error, data) {
  data.forEach(function(d) {
    var datum = {};
    datum.label = d.label;
    datum.measure = parseInt(d.measure);
    if (!(d.type in chartData)) {
      chartData[d.type] = [];
    }
    chartData[d.type].push(datum);
  });
  nv.addGraph(addPieChart);
});

$(document).ready(function() {
  $('input:radio').on('change', function(){
    currentLabel = $(this).val();
    addPieChart();
  });
});

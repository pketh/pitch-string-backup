# todo convert to async await fetch
# todo do 
# accessibility w hidden tables
# todo views -> visits
Observable = require 'o_0'
axios = require 'axios'
_ = require 'underscore'

AnalyticsTemplate = require "../templates/includes/analytics"
AnalyticsTimePopPresenter = require "./pop-overs/analytics-time-pop"
# AnalyticsProjectsSelectPopPresenter = require "./pop-overs/analytics-projects-select"

METRICS = ["remixes", "visits"]
REFERRER_FIELDS = ["remixReferrers", "referrers"]
REFERRER_VALUES = ["remixes", "requests"]
COLORS = ["#70ECFF", "#F2A2FF"]
LINE_COLOR = "#c3c3c3"
BACKGROUND_COLOR = '#f5f5f5'
HEIGHTS = [200, 200]



sum = (array) ->
  array.reduce (a, b) ->
    a + b
  , 0

module.exports = (application, teamOrProject) ->
  self = 
  
    analyticsTimeLabel: application.analyticsTimeLabel
  
    remixesChartElement: document.createElement 'div'
    remixesReferrersBars: document.createElement 'referrer-bars'
  
    visitsChartElement: document.createElement 'div'
    visitsReferrersBars: document.createElement 'referrer-bars'
    
    showRemixesReferrers: Observable false
    totalRemixes: Observable 0
    showVisitsReferrers: Observable false
    totalVisits: Observable 0
    
    analyticsData: Observable {}
    chartData: Observable {}

    # PK: width of what text? is this a character spacing thing?
    # ET: this is the method we use to calculate the left margin of the two charts
    #     this way, the two charts have the same left margin
    # PK: that makes sense. I think it'd be clearer to future us if it was called something like
    # `getWidthOfYAxisLabel`. 'text' is too generic
    getWidthOfText: (txt, fontname, fontsize) ->
      f = self.getWidthOfText
      if f.c is undefined
        f.c = document.createElement 'canvas'
        f.ctx = f.c.getContext '2d'
      f.ctx.font = fontsize + ' ' + fontname
      return f.ctx.measureText(txt).width

    # PK: not sure what's a param here. is it a plotly specific thing?
    # ET: they are chart params: the left margin and the y-range
    calculateParams: (chartData) ->
      maxes = chartData.map (data) ->
        Math.max data.y...
      digits = maxes.map (max) ->
        Math.ceil Math.log10 max
      maxDigits = Math.max digits...
      if maxDigits <= 0
        maxDigits = 1
      # PK: what is 's'?
      # ET: It is just a temporary variable used to store the string with which
      #     we are going to calculate the width of the left margin
      # PK: is it used anywhere? I see it's definition, but no other references to it
      # ET: it is used 4 lines below...
      leftMarginString = [1..maxDigits].reduce (a, b) ->
        a + "9"
      , "9" # we add one digit because the histogram may aggregate buckets together
      leftMarginString = Plotly.d3.format(',dr')(parseInt leftMarginString)

      leftMargin: self.getWidthOfText leftMarginString, "Benton Sans", "14px" # super gross
      ranges: maxes.map (max) ->
        if max >= 3 then undefined else [0, 3]

    drawCharts: (chartData) ->
      console.log 'Plotly ready', Plotly
      {leftMargin, ranges} = calculatedParams = self.calculateParams(chartData)
      console.log 'calculateParams', calculatedParams
      
      # PK: instead of one big args object and unwrapping, would this be clearer if broken up into 
      # seperate graphdiv, data, and layout objects to pass to plotly so that'd it'd match the docs:
      # Plotly.newPlot(graphDiv, data, layout);
      
      [remixData, visitsData] = chartData.map (data, i) ->
        total = sum data.y
        console.log '🐬 chartdata total', total

        layout =
          paper_bgcolor: BACKGROUND_COLOR
          plot_bgcolor: BACKGROUND_COLOR
          font:
            family: '"Benton Sans",Helvetica,Sans-serif'
          margin:
            l: leftMargin
            r: 0
            b: 50
            t: 10
            pad: 0
          height: HEIGHTS[i]
          bargap: 0.2
          xaxis:
            zeroline: false
            showline: true
            linecolor: LINE_COLOR
            type: "date"
            showgrid: true
            autorange: false
            fixedrange: true
            range: [data.x[0].getTime() - 3600000, data.x[data.x.length-1].getTime() + 4 * 3600000]          
            tickangle: 1e-10 # to have it aligned to the right of the tick
          yaxis:
            fixedrange: true
            rangemode: "nonnegative"
            range: ranges[i]
            tickformat: ',dr'
            zeroline: false

        options =
          displayModeBar: false

        console.log '[[data], layout, options, total]', [[data], layout, options, total]
        return [[data], layout, options, total]

      if remixData[3] > 0
        [lines, layout, options, total] = remixData
        self.totalRemixes total
        Plotly.newPlot self.remixesChartElement, lines, layout, options
      else
        self.remixesChart.innerHTML = "<b>No remixes in the selected timespan</b>"

      if visitsData[3] > 0
        [lines, layout, options, total] = visitsData
        self.totalVisits total
        Plotly.newPlot self.visitsChartElement, lines, layout, options
      else
        self.visitsChart.innerHTML = "<b>No visits in the selected timespan</b>"

    drawReferrers: (analyticsData) ->
      args = REFERRER_FIELDS.map (field, i) ->
        total = analyticsData[field].reduce (a, b) ->
          "#{REFERRER_VALUES[i]}": a[REFERRER_VALUES[i]] + b[REFERRER_VALUES[i]]
        , { "#{REFERRER_VALUES[i]}": 0 }
        total = total[REFERRER_VALUES[i]]

        referrers = analyticsData[field].filter (r, i) -> !r.self and i < 5
        # invert them
        referrers = referrers.reverse()
        referrers = referrers.map (r) ->
          domain: r.domain
          value: r[REFERRER_VALUES[i]]

        unless referrers.length > 0
          return null

        data =
          x: referrers.map (r) -> r.value
          y: referrers.map (r) -> r.domain
          hoverinfo: 'none'
          marker:
            color: COLORS[i]
          type: 'bar'
          orientation: 'h'

        layout =
          annotations: referrers.map (r) ->
            x: 0
            y: r.domain
            showarrow: false
            text: "#{r.value} - #{r.domain}"
            xanchor: "left"
            xshift: 5
          paper_bgcolor: BACKGROUND_COLOR
          plot_bgcolor: BACKGROUND_COLOR
          font:
            family: '"Benton Sans",Helvetica,Sans-serif'
          margin:
            l: 0
            r: 10
            b: 10
            t: 10
            pad: 0
          height: 20 + 30 * referrers.length
          barwidth: 20
          xaxis:
            showticklabels: false
            showgrid: false
            zeroline: false
            fixedrange: true
          yaxis:
            showticklabels: false
            fixedrange: true
        options =
          displayModeBar: false

        [[data], layout, options]

      self.showRemixesReferrers !!args[0]
      if args[0] # this check is here because of line 203. coolz
        [lines, layout, options] = args[0]
        Plotly.newPlot self.remixesReferrersBars, lines, layout, options
      self.showVisitsReferrers !!args[1]
      if args[1]
        Plotly.newPlot self.visitsReferrersBars, args[1]...
    
    mapChartData: (data) ->
      {buckets} = data
      chartData = METRICS.map (metric, i) ->
        x: buckets.map (x) -> new Date x.startTime
        y: buckets.map (y) -> y.analytics[metric] ? 0
        marker:
          color: COLORS[i]
        type: 'histogram'
        histfunc: "sum"
        nbinsx: 28
      self.chartData chartData

    plotlyLoad: (e) ->
      console.log "Plotly Load", e

    getAnalyticsData: (fromDate, projectDomain) ->
      id = teamOrProject.id()
      CancelToken = axios.CancelToken
      source = CancelToken.source()
      if projectDomain
        analyticsPath = "analytics/#{id}/project/#{projectDomain}?from=#{fromDate}"
      else
        analyticsPath = "analytics/#{id}/team?from=#{fromDate}"

      application.api(source).get analyticsPath
      .then ({data}) ->
        application.gettingAnalytics false
        application.gettingAnalyticsFromDate false
        application.gettingAnalyticsProjectDomain false
        self.analyticsData data
        self.mapChartData data
        console.log "▶️ self.chartData", self.chartData()
        self.drawCharts(self.chartData())
        self.drawReferrers(self.analyticsData())
      .catch (error) ->
        console.error 'getAnalyticsData', error

    toggleAnalyticsTimePopVisits: (event) ->
      event.stopPropagation()
      application.gettingAnalyticsProjectDomain false
      application.analyticsChartType 'visits'
      application.analyticsTimePopVisible.toggle()

    toggleAnalyticsTimePopRemixes: (event) ->
      event.stopPropagation()
      application.gettingAnalyticsProjectDomain false
      application.analyticsChartType 'remixes'
      application.analyticsTimePopVisible.toggle()

    analyticsTimePopVisits: -> 
      AnalyticsTimePopPresenter application, 'visits'

    analyticsTimePopRemixes: ->
      AnalyticsTimePopPresenter application, 'remixes'
      

      
    toggleAnalyticsProjectDomain: (event) ->
      event.stopPropagation()
      application.analyticsTimePopVisible false
      application.gettingAnalyticsProjectDomain.toggle()

#     hiddenIfGettingAnalytics: ->
#       'hidden' if application.gettingAnalytics()

#     hiddenUnlessGettingAnalytics: ->
#       'hidden' unless application.gettingAnalytics()

  # self.chartData.observe (value) ->
  #   self.drawCharts()

  window.addEventListener 'resize', _.throttle ->
    Plotly.Plots.resize(self.remixesChartElement)
    Plotly.Plots.resize(self.remixesReferrersBars)
    Plotly.Plots.resize(self.visitsChartElement)
    Plotly.Plots.resize(self.visitsReferrersBars)
  , 50

  if typeof Plotly != undefined
    self.getAnalyticsData application.analyticsFromDate()

  return AnalyticsTemplate self

# todo convert to async await fetch
# todo do 
# accessibility w hidden tables
# todo views -> visits
Observable = require 'o_0'
commaNumber = require 'comma-number' #
axios = require 'axios'
moment = require 'moment'
_ = require 'underscore'

AnalyticsTemplate = require "../templates/includes/analytics"

METRICS = ["remixes", "visits"]
REFERRER_FIELDS = ["remixReferrers", "referrers"]
FEFERRER_VALUE = ["remixes", "requests"]
COLORS = ["#70ECFF", "#F2A2FF"]
HEIGHTS = [200, 200]

TWO_WEEKS = moment().subtract(2, 'weeks').valueOf()
ONE_MONTH = moment().subtract(1, 'months').valueOf()
ONE_DAY = moment().subtract(24, 'hours').valueOf()

module.exports = (application, teamOrProject) ->

  self = 
  
    analyticsData: Observable {}
    chartData: Observable {}

    drawCharts
    
    sum: (array) ->
      array.reduce (a, b) ->
        a + b
      , 0
    
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
    
    getAnalyticsData: (fromDate, projectDomain) ->
      id = teamOrProject.id()
      CancelToken = axios.CancelToken
      source = CancelToken.source()
      if projectDomain
        analyticsPath = "analytics/#{id}/project/#{projectDomain}?from=#{fromDate}"
      else
        analyticsPath = "analytics/#{id}/team?from=#{fromDate}"
      application.gettingAnalytics true
      application.api(source).get analyticsPath
        .then ({data}) ->
          application.gettingAnalytics false
          self.analyticsData data
          self.mapChartData data
          console.log "👋 self.analyticsData", self.analyticsData()
          console.log "▶️ self.chartData", self.chartData()
          self.drawCharts()
        .catch (error) ->
          console.error 'getAnalyticsData', error
      
#     hiddenIfGettingAnalytics: ->
#       'hidden' if application.gettingAnalytics()

#     hiddenUnlessGettingAnalytics: ->
#       'hidden' unless application.gettingAnalytics()


  self.getAnalyticsData(TWO_WEEKS)
  return AnalyticsTemplate self

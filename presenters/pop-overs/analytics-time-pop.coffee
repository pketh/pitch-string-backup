moment = require 'moment'

AnalyticsTimePopTemplate = require "../../templates/pop-overs/analytics-time-pop"

twoWeeks = moment().subtract(2, 'weeks').valueOf()
oneMonth = moment().subtract(1, 'months').valueOf()
oneDay = moment().subtract(24, 'hours').valueOf()

module.exports = (application) ->

  self =
  
    application: application
  
    hiddenUnlessAnalyticsTimePopVisible: ->
      'hidden' unless application.analyticsTimePopVisible()

    stopPropagation: (event) ->
      event.stopPropagation()

    selectWeeksFrame: ->
      application.analyticsTimeLabel 'Last 2 Weeks'
      application.analyticsFromDate twoWeeks
      application.gettingAnalyticsFromDate true
    
    selectMonthFrame: ->
      application.analyticsTimeLabel 'Last Month'
      application.analyticsFromDate oneMonth
      application.gettingAnalyticsFromDate true

    selectHoursFrame: ->
      application.analyticsTimeLabel 'Last 24 Hours'
      application.analyticsFromDate oneDay
      application.gettingAnalyticsFromDate true


  application.analyticsFromDate twoWeeks
  return AnalyticsTimePopTemplate self

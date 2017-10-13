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

    selectMonthFrame: ->
      application.analyticsTimeLabel 'Last Month'
      application.analyticsFromDate oneMonth
      application.gettingAnalyticsFromDate true
      
    selectWeeksFrame: ->
      application.analyticsTimeLabel 'Last 2 Weeks'
      application.analyticsFromDate twoWeeks
      application.gettingAnalyticsFromDate true
    
    selectHoursFrame: ->
      application.analyticsTimeLabel 'Last 24 Hours'
      application.analyticsFromDate oneDay
      application.gettingAnalyticsFromDate true

    activeIfLabelIsMonths: ->
      'active' if application.analyticsTimeLabel() is 'Last Month'
        
    activeIfLabelIsWeeks: ->
      'active' if application.analyticsTimeLabel() is 'Last 2 Weeks'

    activeIfLabelIsHours: ->
      'active' if application.analyticsTimeLabel() is 'Last 24 Hours'
      

  if !application.analyticsFromDate()
    application.analyticsFromDate twoWeeks

  return AnalyticsTimePopTemplate self

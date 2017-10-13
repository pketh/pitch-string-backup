Observable = require 'o_0'
# _ = require 'underscore'

AnalyticsProjectsPopTemplate = require "../../templates/pop-overs/analytics-projects-pop"

module.exports = (application) ->

  self =
  
    application: application
  
    query: Observable ""

    hiddenUnlessAnalyticsProjectsPopVisible: ->
      'hidden' unless application.analyticsProjectsPopVisible()
    
    stopPropagation: (event) ->
      event.stopPropagation()

    filter: (event) ->
      query = event.target.value.trim()
      self.query query

    spacekeyDoesntClosePop: (event) ->
      event.stopPropagation()
      event.preventDefault()    
    
    filteredResults: ->
      console.log self.query()


  return AnalyticsProjectsPopTemplate self

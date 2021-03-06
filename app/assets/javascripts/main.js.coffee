
@getTimeString = ->
  now = new Date()
  hour = now.getHours()
  if hour > 12
    hour -= 12
    amPm = 'pm'
  else
    amPm = 'am'
  minute = now.getMinutes()
  minute = "0" + minute if minute < 10
  second = now.getSeconds()
  second = "0" + second if second < 10
  
  hour + ':' + minute + ':' + second + amPm

@autosave = (parentSelector, eventName, childSelector, url) ->
  changedCallback = (event) ->
    $this = $(this)
    if ($this.val() == $this.data('saved-value'))
      $this.removeClass 'invalid'
    else
      nameParts = $this.attr('name').split(/[\[\]]+/)
      modelName = nameParts[0]
      id = nameParts[1]
      attributeNames = nameParts[2...nameParts.length - 1]
      
      ajaxData = {}
      ajaxData[modelName + '[' + attributeNames.join("][") + ']'] = $this.val()

      $(parentSelector).find('.autosave-status').text 'Saving...'

      $.ajax
        type: 'PUT'
        url: url.replace(/{id}/, id)
        data: ajaxData
      .done ->
        $this.data('saved-value', ajaxData[modelName + '[' + attributeNames.join("][") + ']'])
        $this.removeClass 'invalid'

        $(parentSelector).find('.autosave-status').text 'Saved at ' + getTimeString()
      .fail (jqXHR) ->
        try
          errors = $.parseJSON(jqXHR.responseText)
          errorMessage = "The " + modelName + " wasn't saved!<ul>"
          for errorField of errors
            errorMessage += "<li>" + errorField + " " + errors[errorField].join(' and ') + "</li>"
          errorMessage += "</ul>"
        catch ex
          errorMessage = jqXHR.responseText
        
        $this.addClass 'invalid'

        showAlert errorMessage
        
        $(parentSelector).find('.autosave-status').text 'There was an error saving the ' + modelName

  $(parentSelector).on eventName, childSelector, changedCallback

@showAlert = (alertMessage) ->
  $("<div class='container-fluid'><div class='alert alert-danger alert-dismissable'><button type='button' class='close' data-dismiss='alert' aria-hidden='true'>&times;</button>" + alertMessage + "</div></div>")
    .insertAfter('#header-nav')

@getAmount = (amountStr) ->
  return NaN unless amountStr
  amount = parseFloat amountStr.replace(/[^-.0-9]/g, "")
  amount = 0 if isNaN amount
  amount
  
@numberToCurrency = (number) ->
  return "" if isNaN(number)
  
  valueStr = Math.abs(number).toFixed 2
  
  # The (?=) is a positive lookahead that will not be a part of the match, but still determines
  # whether a match is made. Here a digit will be the match if it is followed by any number of sets
  # of 3 digits that are followed by either a period or the end of the string. Then we replace that digit
  # with that same digit plus a comma.
  valueStr = valueStr.replace /(\d)(?=(\d{3})+(\.|$))/g, '$1,' if number >= 1000
  
  valueStr = "$" + valueStr
  valueStr = "-" + valueStr if number < 0
  
  valueStr

$ ->
  $(document).on('blur', '.amount input', ->
    $this = $(this)
    value = getAmount $this.val()
    $this.val numberToCurrency(value)
  )

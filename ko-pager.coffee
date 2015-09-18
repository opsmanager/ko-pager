# ko-pager.coffee --- Smart paging for Knockout.js
#
# Authors:
# Jason Milkins jason@opsmanager.com
# Lincoln Lee   lincoln@opsmanager.com
#
# # Knockout Pager
#
# Provide pagination features for an observableArray. Getting data
# from a server via Ajax.
#
#     @myCollection = ko.observableArray().pager {options}
#
# ## Options
#
# | Parameters         | Default | Description                                 |
# | ------------------ | ------- | ------------------------------------------- |
# | size:              | 10      | Page size                                   |
# | initialPage:       | 1       | First page to make available to .pagedItems |
# | mapFromServer:     | null    | Function to parse server data               |
# | url:               | null    | This can be a string with template items    |
# | ajaxOptions:       | {}      | jQuery ajax options                         |
#
# ## Available properties
#
# | Object         | Type     | Description                                                                                         |
# | -------------- | -------- | --------------------------------------------------------------------------------------------------- |
# | `.pagedItems`  | Array    | The current page of items                                                                           |
# | `.totalCount`  | Integer  | The total number of items (grabbed from the server result 'total_count' set manually if neccessary) |
# | `.totalPage`   | Integer  | The total number of pages                                                                           |
# | `.size`        | Integer  | page set size                                                                                       |
# | `.startOffset` | Integer  | The start item offset                                                                               |
# | `.endOffset`   | Integer  | The end item offset                                                                                 |
# | `.isFirstPage` | Boolean  | boolean observable                                                                                  |
# | `.isLastPage`  | Boolean  | boolean observable                                                                                  |
# | `.isLoading`   | Boolean  | boolean observable                                                                                  |
# | `.next`        | Method   | Use with click: binding                                                                             |
# | `.previous`    | Method   | Use with click: binding                                                                             |
# | `.reset`       | Method   | reset the collection                                                                                |
# | `.goToPage`    | Method   | go to a page                                                                                        |
#

do (ko, $) ->


  extend = ko.utils.extend

  _defaults =
    size:            10
    initialPage:     1    # first page to make available to .pagedItems
    mapFromServer:   null # function to parse server data
    url:             null # this can be a string with template items
    ajaxOptions:     {}   # jQuery ajax options

  templateParser = (str, obj) ->
    regexEscape = (str) -> (String(str)).replace /[\-#$\^*()+\[\]{}|\\,.?\s]/g, "\\$&"
    for i of obj
      continue if obj.hasOwnProperty(i) isnt true
      value = String(obj[i])
      str   = str.replace(new RegExp("{" + regexEscape(i) + "}", "g"), value)
    str

  constructUrl = (urlTemplate, pg, size, initialPage) ->
    if initialPage > 1
      start = 0
      end   = initialPage * size
      size  = end
      pg    = 1
    else
      start = size * (pg - 1)
      end   = start + size

    data =
      pg:     pg
      size:   size
      start:  start
      end:    end

    if typeof urlTemplate == 'function' then urlTemplate(data) else templateParser(urlTemplate, data)

  config_init = (defaults, a, b, c) ->
    cfg = extend({}, defaults)
    if typeof a is "number"
      cfg.size = a
      if typeof b is "string"
        cfg.url = b
    else
      extend cfg, a

    if cfg.ajaxOptions and cfg.ajaxOptions.success
      delete cfg.ajaxOptions.success
    cfg

  pager = (a, b) ->

    items = this
    cfg = config_init(_defaults, a, b)
    current = ko.observable(cfg.initialPage)

    pagedItems = ko.pureComputed ->
      pg = current()
      start = cfg.size * (pg - 1)
      end = start + cfg.size
      items().slice start, end

    totalCount = ko.observable(0)

    totalPage = ko.pureComputed ->
      Math.ceil totalCount() / cfg.size

    startOffset = ko.pureComputed ->
      if totalCount() > 0
        (current() - 1) * cfg.size + 1
      else
        0

    endOffset = ko.pureComputed ->
      if current() < totalPage()
        current() * cfg.size
      else if current() is totalPage()
        totalCount()
      else
        0 if totalCount() is 0

    isFirstPage = ko.pureComputed ->
      current() is 1

    isLastPage = ko.pureComputed ->
      current() is totalPage()

    isLoading = ko.observable(true)

    reset = ->
      items([])
      current(1)
      goToPage(1)

    goToPage =  (pg) ->
      isLoading true

      $.ajax extend
        url: constructUrl(cfg.url, pg, cfg.size, cfg.initialPage)
        success: (results) ->
          totalCount(Number(results.total_count)) if results.total_count?
          results = cfg.mapFromServer(results) if cfg.mapFromServer
          onPageReceived pg, results, cfg.initialPage > 1
          cfg.initialPage = 1
          isLoading false
          cfg.onSuccess results if cfg.onSuccess
        complete: ->
          isLoading false
      , cfg.ajaxOptions

    onPageReceived = (pg, data, initialLoad = false) ->
      if initialLoad
        items(data)
      else
        start = cfg.size * (pg - 1)
        Array::splice.apply items(), [start, 0].concat(data)

      items.notifySubscribers()
      current pg

    next = -> goToPage current() + 1 if next.enabled()

    next.enabled = ko.pureComputed -> not isLastPage()

    previous = -> goToPage current() - 1 if previous.enabled()

    previous.enabled = ko.pureComputed -> not isFirstPage()

    # TODO: This should be a relative page fetch instead of fetching all previous pages
    goToPage current()

    extend items,
      current:               current
      totalCount:            totalCount
      totalPage:             totalPage
      startOffset:           startOffset
      endOffset:             endOffset
      isFirstPage:           isFirstPage
      isLastPage:            isLastPage
      pagedItems:            pagedItems
      size:                  cfg.size
      isLoading:             isLoading
      next:                  next
      reset:                 reset
      previous:              previous
      goToPage:              goToPage
      __paged_cfg:           extend({},  cfg)

    items

  pager.defaultOptions = _defaults

  ko.observableArray.fn.pager = pager
  return

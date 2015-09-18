# Knockout Pager

Smart pager for Knockout. Provides pagination features for an observableArray. Getting data
from a server via Ajax.

    @myCollection = ko.observableArray().pager {options}

This is a re-write of knockout-asPager extension.

## Options

| Parameters         | Default | Description                                 |
| ------------------ | ------- | ------------------------------------------- |
| size:              | 10      | Page size                                   |
| initialPage:       | 1       | First page to make available to .pagedItems |
| mapFromServer:     | null    | Function to parse server data               |
| url:               | null    | This can be a string with template items    |
| ajaxOptions:       | {}      | jQuery ajax options                         |

## Available properties

| Object         | Type     | Description                                                                                         |
| -------------- | -------- | --------------------------------------------------------------------------------------------------- |
| `.pagedItems`  | Array    | The current page of items                                                                           |
| `.totalCount`  | Integer  | The total number of items (grabbed from the server result 'total_count' set manually if neccessary) |
| `.totalPage`   | Integer  | The total number of pages                                                                           |
| `.size`        | Integer  | page set size                                                                                       |
| `.startOffset` | Integer  | The start item offset                                                                               |
| `.endOffset`   | Integer  | The end item offset                                                                                 |
| `.isFirstPage` | Boolean  | boolean observable                                                                                  |
| `.isLastPage`  | Boolean  | boolean observable                                                                                  |
| `.isLoading`   | Boolean  | boolean observable                                                                                  |
| `.next`        | Method   | Use with click: binding                                                                             |
| `.previous`    | Method   | Use with click: binding                                                                             |
| `.reset`       | Method   | reset the collection                                                                                |
| `.goToPage`    | Method   | go to a page                                                                                        |

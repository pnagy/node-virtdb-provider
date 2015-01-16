# node-virtdb-provider

## Overview

This is a node.js module that helps creating new data connectors to the [VirtDB](http://www.virtdb.com) system.

## How to write a new data connector

By using the virtdb-provider module it is quite easy to create new connectors. Only the **METADATA** and the **DATA** interfaces have to be implemented. To get detailed information of the structures used in the following examples see the [starschema/virtdb-proto](http://ww.github.com/starschema/virtdb-proto) project.

### METADATA

The **METADATA** interface is used for letting [VirtDB](http://www.virtdb.com) know the structure of the data provided. This is done by replying to **METADATA** requests.

```coffeescript
# A typical meta_data request.
request =
    Name: "customers"
    WithFields: false
}
```

```coffeescript
# A typical meta_data reply
reply =
    Tables: [
        Name: "customers"
        Fields: [
            Name: "id"
            Desc:
                Type: 'UINT64'
        ,
            Name: "name"
            Desc:
                Type: 'STRING'
        ]
    ]
```

### DATA

The **DATA** interface is used for sending data back to queries. Data is sent in column chunks.

```coffeescript
# A typical query
query =
    QueryId: "e142fbd0-9d77-11e4-bd06-0800200c9a66"
    Table: "customers"
    Fields: [
        Name: "id"
        Desc:
            Type: 'UINT64'
    ,
        Name: "name"
        Desc:
            Type: 'STRING'
    ]
    Filter: [
        Operand: "like"
        Simple:
            Variable: "name"
            Value: "John%"
    ]
}
```

```coffeescript
# A typical column reply for the query. (Separate replies are needed for each columns requested in the query.)
columnChunk =
    QueryId: "e142fbd0-9d77-11e4-bd06-0800200c9a66"
    Name: "name"
    SeqNo: 0 # a strictly increasing series for each column
    Data:
        Type: 'STRING'
        StringValue: ['John Doe', 'John Smith', 'Johnathan Apple']
    EndOfData: true
    CompType: "NO_COMPRESSION" # alternative: LZ4_COMPRESSION
```

## Sample implementation

```coffeescript
DataProvider = require 'virtdb-provider'

# component name should be unique throughout the system
# url is the ZeroMQ url of the virtdb config service component.
virtdb = new DataProvider('<component-name>', '<url>')

# meta_data is a list of table descriptions that match the request criteria
virtdb.onMetaDataRequest (request) ->
        meta_data = get_meta_data_from_your_datasource request
        virtdb.sendMetaData meta_data
        return

# virtdb data is sent by column chunks
virtdb.onQuery (query) ->
        data = query_your_datasource query
        for column in data
            column.QueryId = query.QueryId
            virtdb.sendColumn column
```

## Credits

[VirtDB](http://www.virtdb.com) is the product of [Starschema Technologies.](https://www.starschema.net). For any questions, comments or issues please contact us: [@virtdb](https://twitter.com/virtdb)

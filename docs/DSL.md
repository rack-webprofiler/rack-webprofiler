# @title Collector DSL

# Collector DSL

## Presentation

{Rack::WebProfiler::Collector::DSL}
{Rack::WebProfiler::Collector::DSL::ClassMethods}

## Collector DSL methods

### `collector_name`

Technical name of the collector.

**example**

```ruby
collector_name "my_collector"
```

### `icon`

Base64 encoded image for the icon collector.

**example**

```ruby
icon <<-'ICON'
data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8Xw8AAoMBgDTD2qgAAAAASUVORK5CYII=
ICON
```

### `position`

Position of the collector in the toolbar.

**example**

```ruby
position 2
```

### `collect`

Place to collect data to store. It give you access to the {Rack::WebProfiler::Request} and the {Rack::WebProfiler::Response}.  
Inside you could `store` the datas you want. And you also could set a `status`.  
There is `success`, `warning` and `error` has available `status`.

**example**

```ruby
collect do |request, response|
  store :url, request.url
  store :key, ["v1", "v2"]

  status :success if response.successful?
end
```

### `template`

**example**

```ruby
template "../path/to/template.erb"
# Or
template __FILE__, type: :DATA
```

### `is_enabled?`

**example**

```ruby
is_enabled? -> { defined? MyApp }
```

## Collector template

### `h`
### `highlight`
### `partial`
### `tab_content`
### `panel_content`
### `data(k)`

## Collector registration

It's really simple to register a Collector or an {Array} of collectors.

```ruby
Rack::WebProfiler.register_collector MyCustomCollector
Rack::WebProfiler.register_collector [MyCustomCollector, MySecondCustomCollector]
```

You could also unregister a collector

```ruby
Rack::WebProfiler.unregister_collector MyCustomCollector
Rack::WebProfiler.unregister_collector [MyCustomCollector, MySecondCustomCollector]
```


## Example

```ruby
class MyCustomCollector
  include Rack::WebProfiler::Collector::DSL

  icon <<-'ICON'
data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8Xw8AAoMBgDTD2qgAAAAASUVORK5CYII=
ICON

  collector_name "my_collector"
  position 2

  collect do |request, response|
    store :url, request.url
    store :key, ["v1", "v2"]

    status :success if response.successful?
  end

  template __FILE__, type: :DATA

  is_enabled? -> { defined? MyApp }
end

__END__
<% tab_content do %>
  <%=h data(:url) %>
<% end %>

<%# panel_content do %>
  <ul>
    <li><%=h data(:url) %></li>
    <li><%=h data(:key).inspect %></li>
  </ul>
<%# end %>
```

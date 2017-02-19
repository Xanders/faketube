<list>
  <div class="note" if={note}>{note}</div>
  <div class="error" if={error}>{error}</div>
  <preview each={videos}></preview>

  <style>
    :scope {
      display: flex;
      flex-wrap: wrap;
      width: 100%;
    }
  </style>

  this.note = "Loading..."
  this.videos = []

  var that = this
  this.on('route', function() {
    $.getJSON(server).done(function(data) {
      if(that.isMounted) that.videos = data
    }).fail(function() {
      if(that.isMounted) that.error = "Cannot load data from server! :("
    }).always(function() {
      if(!that.isMounted) return
      delete that.note
      that.update()
    })
  })
</list>
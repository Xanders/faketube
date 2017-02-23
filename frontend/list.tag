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
      if(!that.isMounted) return
      if(data.length) {
        that.videos = data
        delete that.note
      } else {
        that.note = "There is no videos on the server yet. Welcome to upload one!"
      }
    }).fail(function() {
      if(!that.isMounted) return
      that.error = "Cannot load data from server! :("
      delete that.note
    }).always(function() {
      if(that.isMounted) that.update()
    })
  })
</list>
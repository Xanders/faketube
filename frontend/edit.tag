<edit>
  <div class="note" if={note}>{note}</div>
  <div class="error" if={error}>{error}</div>
  <form onsubmit={submit}>
    <label for="title">
      New watermark
      <input type="text" id="title" name="title" ref="title">
    </label>
    <input type="submit" ref="submit">
  </form>

  <style>
    label[for="title"], [type="submit"] {
      display: block;
    }

    label[for="title"] {
      margin-bottom: 1rem;
    }

    [ref="title"], [type="submit"] {
      padding: 0.2rem 0.25rem;
    }
  </style>

  this.on('route', function(id) {
    this.id = id
  })

  var that = this
  this.submit = function(event) {
    event.preventDefault()

    var title = this.refs.title.value
    if(title.match(/^\s*$/)) return this.error = undefined
    if(title.length > 100) return this.error = "Watermark cannot be longer than 100 characters"

    delete this.error
    this.refs.submit.disabled = true

    $.ajax({
      url: server + that.id + '?' + $.param({title: title}),
      method: 'PATCH',
      success: function(response) {
        if(response.processing) alert("Your video is in processing now, the changes will appear at few minutes.")
        if(that.isMounted) route(that.id)
      },
      error: function() {
        if(!that.isMounted) return
        delete that.note
        that.error = "The error occured on updating process! Sorry. :("
        that.update()
      },
      complete: function() {
        if(that.isMounted) that.refs.submit.disabled = false
      }
    })

    this.note = "Processing..."
  }
</edit>
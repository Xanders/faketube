<new>
  <div class="note" if={note}>{note}</div>
  <div class="error" if={error}>{error}</div>
  <form onsubmit={submit}>
    <input type="file" name="file" ref="file">
    <label for="title">
      Watermark
      <input type="text" id="title" name="title" ref="title">
    </label>
    <input type="submit">
  </form>

  <style>
    [ref="file"], label[for="title"], [type="submit"] {
      display: block;
    }

    label[for="title"] {
      margin: 1rem 0;
    }

    [ref="title"], [type="submit"] {
      padding: 0.2rem 0.25rem;
    }
  </style>

  var that = this
  this.submit = function(event) {
    event.preventDefault()

    var file = this.refs.file.files[0]
    if(!file) return this.error = "Please, select the file"

    var title = this.refs.title.value
    if(title.match(/^\s*$/)) return this.error = "Please, enter watermark"
    if(title.length > 100) return this.error = "Watermark cannot be longer than 100 characters"

    delete this.error
    var data = new FormData()
    data.append('file', file)

    $.post({
      url: server + '?' + $.param({title: title}),
      data: data,
      cache: false,
      contentType: false,
      processData: false,
      success: function(response) {
        var redirect = that.isMounted && !that.refs.file.value && !that.refs.title.value
        if(response.processing) {
          alert("Your video is in processing now, it will appear in list at few minutes. You can leave the site or watch some other videos fow now.")
          if(redirect) route('')
        } else {
          alert("Your video was uploaded successfully!")
          if(redirect) route(response.id)
        }
      },
      error: function() {
        if(that.isMounted) {
          delete that.note
          that.update()
        }
        alert("The error occured on uploading process! Sorry. :(")
      }
    })

    this.refs.file.value = ""
    this.refs.title.value = ""
    this.note = "Video uploading in process. You can leave the page, but please, do not leave the site until successful notification."
  }
</new>
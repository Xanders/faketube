<show>
  <div class="note" if={note}>{note}</div>
  <div class="error" if={error}>{error}</div>
  <virtual if={!video.loading}>
    <div ref="holder"></div>
    <span if={video.title} ref="watermark">{video.title}</span>
    <a ref="edit" href="/{video.id}/edit">Edit</a>
  </virtual>

  <style>
    :scope {
      display: block;
      position: relative;
    }

    [ref="watermark"] {
      position: absolute;
      bottom: 6rem;
      width: 100%;
      padding: 1rem;
      color: black;
      background: rgba(255, 255, 255, 0.7);
      font-size: 1.5rem;
      text-align: center;
      pointer-events: none;
    }

    [ref="edit"] {
      display: block;
      width: 100%;
      padding: 0.5rem 0.75rem;
      margin-top: 1rem;
      color: black;
      background-color: rgb(255, 255, 100);
      font-size: 1.25rem;
      text-align: center;
      text-decoration: none;
      text-transform: uppercase;
    }
    [ref="edit"]:hover {
      color: rgb(67, 77, 0);
    }

    video {
      width: 100%;
    }
  </style>

  this.note = "Loading..."
  this.video = { loading: true }

  var that = this

  this.fail = function() {
    if(!that.isMounted) return
    delete that.note
    that.error = "Cannot load data from server! :("
    that.update()
  }

  this.on('route', function(id) {
    $.getJSON(server + id).done(function(data) {
      if(!that.isMounted) return
      delete that.note
      that.video = data
      var embedly_params = { url: that.video.url, autoplay: true, key: embedly_key, width: $(that.root).width() }
      var embedly_url = 'https://api.embedly.com/1/oembed?' + $.param(embedly_params)
      $.getJSON(embedly_url).done(function(data) {
        if(!that.isMounted) return
        that.one('updated', function() {
          that.refs.holder.innerHTML = data.html || '<video src="' + that.video.url + '" controls></video>'
        })
        that.update()
      }).fail(that.fail)
    }).fail(that.fail)
  })
</show>
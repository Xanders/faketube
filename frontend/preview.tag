<preview>
  <a href="/{id}">
    <img src={thumbnail}>
    <span if={time} ref="time">{time}s</span>
    <span if={size} ref="size">{(size / 1024 / 1024).toFixed(2)} MB</span>
  </a>

  <style>
    :scope {
      display: flex;
      margin: 1rem;
    }

    a {
      position: relative;
    }

    :scope, a, img {
      width: 100%;
      max-width: 15rem;
    }

    [ref=time], [ref=size] {
      position: absolute;
      top: 1rem;
      color: black;
      background: rgba(255, 255, 255, 0.7);
      padding: 0.5rem;
    }
    [ref=time] {
      left: 1rem;
    }
    [ref=size] {
      right: 1rem;
    }
  </style>
</preview>
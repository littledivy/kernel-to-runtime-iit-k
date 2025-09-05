#set page(width: 16cm, height: 9cm, margin: 1cm)
#set text(size: 15pt)

#let main(pretitle, title) = [
  #text(size: 10pt, style: "italic", pretitle)
  #linebreak()
  #text(30pt, title)

  #v(1cm)
  #text("peek inside a javascript runtime")

  #v(2.4cm)

  #text(12pt, "IIT Kanpur (OOSC)")
  #h(1fr)
  #text(12pt, "5 Sept 2025")
]

#let slide(title, body) = [
  #pagebreak()
  #text(size: 20pt, title)
  #v(0.8cm)
  #body
]

#let slide2(title, body) = [
  #pagebreak()
  #text(size: 20pt, title)
  #linebreak()
  #body
]

#main("From", "kernel to runtime")

// Explain what Deno is
#slide("What's Deno?", [
  #grid(
    columns: (1fr, auto),
    column-gutter: 1em,
    box([
      Deno is an open source JavaScript runtime built on top of V8.
      - supports modern web standard APIs
      - builtin TypeScript support
      - sandbox permission system
      - Node.js/npm compatibility
    ]),
    figure(
      image("deno-logo.svg", width: 2cm, height: 2cm),
    ),
  )
])

// JS runtimes are single-threaded, epoll based event loop
#slide("Single thread I/O", [
  Event loop is driven using epoll/IOCP when a file is ready, the kernel
  notifies epoll_wait()
  #linebreak()
  #linebreak()

  JavaScript runtimes put I/O operations on the event loop and use Promises/callbacks to notify the user code
])

// The hook: how Deno.serve works?
#slide("One line HTTP server", [
  ```js
  // $ deno --allow-net server.js
  Deno.serve(req => new Response("Hello, World!"))
  ```

  - single threaded
  - can handle 130k+ rps#super[[1]]
  - 1ms p99 latency#super[[1]]
  - in JavaScript

  #align(right)[
    #text(
      8pt,
      "[1] https://www.trevorlasn.com/blog/benchmarks-for-node-bun-deno",
    )
  ]
])

#slide("Scheduling", [
  I/O operations are scheduled on the event loop, they _may_ be offloaded to
  a thread pool but the user code is not blocked.

  ```js
  const file = await Deno.open("index.html");
  const req = await fetch("https://littledivy.com");

  req.body.pipeTo(file.writable);
  ```
])

#align(horizon)[
  #image("scheduling-1.svg", width: 10cm, height: 8cm, fit: "cover")
]

#align(horizon)[
  #image("scheduling-2.svg", width: 10cm, height: 9cm, fit: "cover")
]

#slide("Permission system", [
  Virtual permission system that restricts access to OS resources.

  ```sh
  deno run server.ts # blocked
  deno run --allow-net server.ts # OK
  ```

  #image("permissions.png")
])

#slide("Memory management", [
  JavaScript objects are garbage collected.

  #linebreak()
  #linebreak()
  How does it cleanup native files, sockets and other resources?
])

#slide("Resources", [
  Resources are like fds: integer handles for open files, sockets, etc.

  ```ts
  console.log(Deno.resources());
  // { 0: "stdin", 1: "stdout", 2: "stderr" }
  Deno.close(0);
  ```

  This allows users to manually close native resources.
])

#slide("Garbage collectable resources", [
  GC'able resources are attach to a JavaScript object. The native
  resource is freed when the object is collected.

  ```js
  import { DatabaseSync } from "node:sqlite";

  const db = new DatabaseSync();
  // ...
  ```
])

#slide2("Bonus: Deno OS", [
  minimal Linux kernel build with a Deno userspace.

  #table(
    columns: 2,
    stroke: 0.7pt + gray,
    inset: 4pt,
    [
      *Linux*
    ],
    [
      *Deno*
    ],

    [
      Processes
    ],
    [
      Web Workers
    ],

    [
      File descriptors (fd)
    ],
    [
      Resource ids (rid)
    ],

    [
      Syscalls
    ],
    [
      Ops
    ],

    [
      Scheduler
    ],
    [
      Tokio
    ],

    [
      man pages
    ],
    [
      `deno types`
    ],
  )
])

#text(fill: blue, "https://github.com/littledivy/deno-os")
#image("deno-os.png")

#slide("Get involved", [
  Github: #text(fill: blue, "https://github.com/denoland/deno")

  Discord: #text(fill: blue, "https://discord.gg/deno")

  #linebreak()
  #linebreak()
  open issues, ideas or contribute code
])

#slide("Thanks!", [
  Questions?

  Source:

  #v(3cm)
  me\@littledivy.com
  #h(1fr)
  discord.gg/deno
])

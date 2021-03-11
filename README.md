EDDN Ruby
---

### What's EDDN?

Stands for [Elite Dangerous Data Network](https://github.com/EDCD/EDDN).

A stream that contains data from all players of Elite Dangerous who share their logs.

Here's the projects [Wiki](https://github.com/EDCD/EDDN/wiki).

### How can I use this?

If you know what you're doing, you can use this to plug into the stream and do whatever you want after.

### Requirements:

* Ruby 3+

### Usage:

```ruby
$ irb

> load './subscriber_poc.rb'
> eddn = EDDN::SubscriberPoc.new
> eddn.run! # This will start fetching data from the stream, prepare yo have your screen bombarded.
```

### Acknowledgements:

This is the work of a bored dev who wants to create cool shit. Don't expect this to be maintained constantly or to have a lot of guides on how to use it.

Feel free to PR tho :)

This requires some level of expertise with Ruby, ZeroMQ and the EDDN API itself.

### Useful links:

* [ffi-rzmq](https://github.com/chuckremes/ffi-rzmq)
* [EDDN](https://github.com/EDCD/EDDN)
* [EDDN Monitor](https://eddn.edcd.io)
* [EDCodex](http://edcodex.info)

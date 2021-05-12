require "./event"

class Pulsar::Graph
  def initialize
    @root = Node.new(:root)
  end

  def add(*args, &block : Event ->)
    @root.add(args.to_a, payload: block)
  end

  def emit(*args, message)
    @root.emit(args.to_a, message, [@root])
  end
end

class Pulsar::Node
  getter name : Symbol

  def initialize(name : Symbol)
    @name = name
    @childern = Array(Node).new
    @payloads = Array(Event ->).new
  end

  def add(args, payload : Event ->) : Bool
    if args.size == 0
      @payloads << payload
      true
    else
      new_name = args.shift
      if found_node = @childern.find { |node| node.name == new_name }
        return found_node.add(args, payload: payload)
      else
        new_node = Node.new(new_name)
        @childern << new_node
        return new_node.add(args, payload: payload)
      end
    end
  end

  def emit(args, message, callers) : Bool
    if args.size == 0
      callers.each &.@payloads.not_nil!.each &.call(message)
      return true
    end

    new_name = args.shift
    callers = Array(Node).new
    if new_name == :*
      callers.concat @childern
    else
      if found_node = @childern.find { |node| node.name == new_name }
        callers << found_node
      end
    end

    if callers.size > 0
      return emit(args, message, callers)
    end

    false
  end
end

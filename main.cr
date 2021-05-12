require "./src/pulsar"

graph = Pulsar::Graph.new

graph.add(:db) do |event|
  puts "DB: #{event}"
end

graph.add(:db, :create) do |event|
  puts "DB::CREATE #{event}"
end

class TestEvent < Pulsar::Event
end

graph.emit(:db, :create, message: TestEvent.new)
graph.emit(:db, :*, message: TestEvent.new)

pp graph

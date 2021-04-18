class Graph
  MESS = "SYSTEM ERROR: method missing".freeze

  attr_reader :num_vertices, :directed
  def initialize(num_vertices, directed = false)
    @num_vertices = num_vertices
    @directed = directed
  end

  def add_edge(v1, v2, weight)
    raise MESS
  end

  def get_adjacent_vertices(v)
    raise MESS
  end

  def get_indegree(v)
    raise MESS
  end

  def get_edge_weight(v1, v2)
    raise MESS
  end

  def display(graph)
    raise MESS
  end
end


class AdjacencyMatrixGraph < Graph
  attr_accessor :matrix
  def initialize(num_vertices, directed = false)
    super
    @matrix = Array.new(num_vertices) { Array.new(num_vertices, 0) }
  end

  def add_edge(v1, v2, weight = 1)
    if v1 >= num_vertices || v2 >= num_vertices || v1.negative? || v2.negative?
      raise "Vertices #{v1} and #{v2} are out of bounds"
    end

    matrix[v1][v2] = weight
    matrix[v2][v1] = weight unless directed
  end

  def get_adjacent_vertices(v)
    adjacent_vertices = []
    for i in (0...num_vertices) do
      adjacent_vertices << i if matrix[v][i] > 0
    end
    adjacent_vertices
  end

  def get_indegree(v)
    indegree = 0
    for i in (0...num_vertices) do
      indegree += 1 if matrix[i][v] > 0
    end
    indegree
  end

  def get_edge_weight(v1, v2)
    matrix[v1,v2]
  end

  def display
    for i in (0...num_vertices) do
      for v in get_adjacent_vertices(i)
        p "#{i} ---> #{v}"
      end
    end
  end
end

require "set"

class Node
  attr_reader :vertex_id, :adjacency_set
  def initialize(vertex_id)
    @vertex_id = vertex_id
    @adjacency_set = SortedSet.new
  end

  def add_edge(v)
    raise 'Vertex can not adjcent to itself' if vertex_id == v

    adjacency_set.add(v)
  end

  def get_adjacent_vertices
    adjacency_set
  end
end

class AdjacencySetGraph < Graph
  attr_reader :num_vertices, :directed, :vertex_list

  def initialize(num_vertices, directed= false)
    super
    @vertex_list = []
    0.upto(num_vertices) { |i| vertex_list << Node.new(i) }
  end

  def add_edge(v1, v2, weight = 1)
    if v1 >= num_vertices || v2 >= num_vertices || v1.negative? || v2.negative?
      raise "Vertices #{v1} and #{v2} are out of bounds"
    end

    vertex_list[v1].add_edge(v2) # get node of v1 and add v2 to the list
    vertex_list[v2].add_edge(v1) unless directed
  end

  def get_adjacent_vertices(v)
    vertex_list[v].get_adjacent_vertices
  end

  def get_indegree(v)
    indegree = 0
    0.upto(num_vertices - 1) do |i|
      indegree +=1 if get_adjacent_vertices(i).include?(v)
    end
    indegree
  end

  def get_edge_weight(v1, v2)
    1
  end

  def display
    for i in (0...num_vertices) do
      for v in get_adjacent_vertices(i)
        p "#{i} ---> #{v}"
      end
    end
  end
end

def breadth_first(graph, start = 0)
  queue = []
  queue.push(start)
  visited = Array.new(graph.num_vertices, 0)
  until queue.empty?
    vertex = queue.pop
    next if visited[vertex] == 1

    puts "Visit: #{vertex}"
    visited[vertex] = 1
    graph.get_adjacent_vertices(vertex).each do |v|
      queue.insert(0, v) if visited[v] != 1
    end
  end
end

def depth_first(graph, visited = nil, current = 0)
  visited ||= Array.new(graph.num_vertices, 0)

  return if visited[current] == 1

  visited[current] = 1
  puts "Visit: #{current}"
  graph.get_adjacent_vertices(current).each do |v|
    depth_first(graph, visited, v)
  end
end

def build_distance_table(graph, source)
  distance_table = {}

  0.upto(graph.num_vertices-1) do |v|
    distance_table[v] = [nil, nil]
  end

  distance_table[source] = [0, source]

  queue = [source] # array can work as queue
  while queue.any? do
    current_v = queue.pop
    current_distance = distance_table[current_v][0]

    graph.get_adjacent_vertices(current_v).each do |neighbor|
      if distance_table[neighbor][0].nil?
        distance_table[neighbor] = [1 + current_distance, current_v]
        if graph.get_adjacent_vertices(neighbor).count > 0
          queue.insert(0, neighbor)
        end
      end
    end
  end
  distance_table
end

def shortest_path(graph, source, dest)
  distance_table = build_distance_table(graph, source)

  path = [dest] # acts as a stack by using push and pop

  previous_vertex = distance_table[dest][1]

  while !previous_vertex.nil? && previous_vertex != source
    path = path.insert(0, previous_vertex)
    previous_vertex = distance_table[previous_vertex][1]
  end

  if previous_vertex.nil?
    p "No Path found from #{source} to #{dest}"
  else
    path.insert(0, source)
    p "shortest path is  #{path}"
  end
end

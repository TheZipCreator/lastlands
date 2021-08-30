Node[][] constructNodes() { //Construct nodes for a* based on map
  Node[][] rv = new Node[wsx][wsy];
  for(int i = 0; i < wsx; i++) { //Loop through all nodes
    for(int j = 0; j < wsy; j++) {
      rv[i][j] = new Node(i, j, (world[i][j] == 0)); //Create a node at the current position, traversable if it's ground
    }
  }
  for(int i = 0; i < wsx; i++) { //Loop through all nodes
    for(int j = 0; j < wsy; j++) {
      rv[i][j].addNeighbors(); //Add neighbors to each node
    }
  }
  return rv;
}

//Black magic
ArrayList<intvect> a_star(Node[][] astar_nodes, intvect start, intvect end) {
  ArrayList<intvect> openSet = new ArrayList<intvect>();
  ArrayList<intvect> closedSet = new ArrayList<intvect>();
  openSet.add(start);
  int maxLoops = 1000; //Maximum amount of loops through the while loops
  int currLoops = 0; //Amount of loops gone through the while loop
  while(openSet.size() > 0 && currLoops < maxLoops) {
    currLoops++;
    int winner = 0;
    for(int i = 0; i < openSet.size(); i++) {
      if(getNodeAt(openSet.get(i), astar_nodes).f < getNodeAt(openSet.get(winner), astar_nodes).f) {
        winner = i;
      }
    }
    intvect current = openSet.get(winner);
    if(current.equals(end)) {
      ArrayList<intvect> path = new ArrayList<intvect>();
      intvect temp = current;
      path.add(temp);
      while(getNodeAt(temp, astar_nodes).previous != null && !temp.equals(start)) {
        path.add(getNodeAt(temp, astar_nodes).previous);
        temp = getNodeAt(temp, astar_nodes).previous;
      }
      return path;
    }
    openSet.remove(winner);
    closedSet.add(current);
    for(int i = 0; i < getNodeAt(current, astar_nodes).neighbors.size(); i++) {
      intvect neighbor = getNodeAt(current, astar_nodes).neighbors.get(i);
      if(!nodeIsInSet(neighbor, closedSet) && getNodeAt(neighbor, astar_nodes).traversable) {
        float tempG = getNodeAt(current, astar_nodes).g+1;
        if(nodeIsInSet(neighbor, openSet)) {
          if(tempG < getNodeAt(neighbor, astar_nodes).g) astar_nodes[neighbor.x][neighbor.y].g = tempG;
        } else {
          astar_nodes[neighbor.x][neighbor.y].g = tempG;
          openSet.add(neighbor);
        }
        astar_nodes[neighbor.x][neighbor.y].h = heuristic(neighbor,end);
        astar_nodes[neighbor.x][neighbor.y].f = getNodeAt(neighbor, astar_nodes).g+getNodeAt(neighbor, astar_nodes).h;
        astar_nodes[neighbor.x][neighbor.y].previous = current;
      }
    }
  }
  return null;
}
Node getNodeAt(intvect vect, Node[][] astar_nodes) {
  return astar_nodes[vect.x][vect.y];
}
boolean nodeIsInSet(intvect node, ArrayList<intvect> set) {
  for(int i = 0; i < set.size(); i++) {
    if(node.equals(set.get(i))) return true;
  }
  return false;
}
float heuristic(intvect a, intvect b) {
  return abs(a.x-b.x)+abs(a.y-b.y);
}
class Node { //Used for A*.
  int x;
  int y;
  float f;
  float g;
  float h;
  ArrayList<intvect> neighbors;
  intvect previous;
  boolean traversable = true;
  Node(int x, int y, boolean traversable) {
    neighbors = new ArrayList<intvect>();
    this.x = x;
    this.y = y;
    this.traversable = traversable;
    f = 0;
    g = 0;
    h = 0;
  }
  //void render(color col) {
  //  fill(col);
  //  rect(x*tileSizeX, y*tileSizeY, tileSizeX-1, tileSizeY-1);
  //}
  void addNeighbors() {
    if(x < wsx-1) neighbors.add(new intvect(x+1, y));
    if(x > 0) neighbors.add(new intvect(x-1, y));
    if(y < wsy-1) neighbors.add(new intvect(x, y+1));
    if(y > 0) neighbors.add(new intvect(x, y-1));
  }
}
class intvect {
  int x;
  int y;
  intvect(int x, int y) {
    this.x = x;
    this.y = y;
  }
  boolean equals(intvect other) {
    if(other.x == x && other.y == y) return true;
    return false;
  }
}

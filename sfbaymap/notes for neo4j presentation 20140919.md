# Notes for neo4j presentation on 20140919

## simple model
### create a node

refer to [create](http://docs.neo4j.org/chunked/stable/query-create.html) in the manual.

use json syntax `create (nodeIdentifier: Label {key1: value1, key2: value2})`

#### test
// create a node with the name = "joe"

`create (n {name: 'dave'})`

`create (n {name: 'joe', age: 5})`

// use get some data to list the node
`match (n) where n.name='joe' return n.age`

// clear database ==> run clear 

// create 3 cities with name and population, and label them as City

#### create sample nodes

```
CREATE (n01:City {name: 'Mountain View', population: 77646}),
    (n02:City {name: 'Palo Alto', population: 66642}),
    (n18:City {name: 'Sunnyvale', population: 147559})
```
#### get some data from database
// run get some data
// find out some property value of a node
`match (n) with n.name = 'Mountain View' as myCity return myCity` this will compare each node and return true/false of the comparision. There are 3 cities, only one match the name, we will get true, false, false. `where` is different from `with`, `match (n) where n.name = 'Mountain View' return n.population` will return the population of Mountain View. 

### create a link
To create relationship while creating node, just append the code below. If we create the links separately, we will end up with duplicate nodes.

```
(n01)-[:connect_to {distance: 5.5}]->(n02),    // mtv - pa
(n01)-[:connect_to {distance: 2.9}]->(n18)     // mtv - snyl
```
To create relationship after nodes already created, we need to do a match first then merge the new relationship.

```
MATCH (a:City {name: 'Mountain View'}),
      (b:City {name: 'Palo Alto'})
MERGE (a)-[r:connect_to {distance: 5.5}]->(b)
```
For bidirection,

```
MATCH (a:City {name: 'Mountain View'}),
      (c:City {name: 'Sunnyvale'})
MERGE (a)-[r1:connect_to {distance: 2.9}]->(c)
MERGE (c)-[r2:connect_to {distance: 2.9}]->(a) 
```

### query some data, use match
MATCH (a)-[r:connect_to]->(b)
WHERE (a.name = 'Mountain View') RETURN b.name, r.distance

## more nodes
### add some different type nodes and connect them with `has`
This code will create duplicate nodes,

```
CREATE
    (s01:School {name: 'Stanford University'}), // <<== add more places
    (s02:School {name: 'Foothill Community College'}),
    (n02)-[:has]->(s01),                    	 // <<== connect places to cities
    (n01)-[:has]->(s02)
```
Use this code to add school, for Mountain View

```
MATCH (n01: City)
WHERE n01.name = 'Mountain View' 
MERGE (s02:School {name: 'Foothill Community College'}) 
MERGE (n01)-[:has]->(s02)                    	
RETURN
	n01, s02
```
For Palo Alto,

```
MATCH (n01: City)
WHERE n01.name = 'Palo Alto' 
MERGE (s02:School {name: 'Stanford University'}) 
MERGE (n01)-[:has]->(s02)                    	
RETURN
	n01, s02
```

### query
To delete a node by ID, `MATCH (n) WHERE id(n) = 16331 DELETE n`; this will not work, there is a relationship.

See [discussion](http://stackoverflow.com/questions/19624414/delete-node-and-relationships-using-cypher-query-over-rest-api), need to delete relationship first.

```
START n=node(16331)
OPTIONAL MATCH n-[r]-()
DELETE r, n;
```

Find out which city has school, 

```
MATCH (n:City)-[:has]->(m:School) RETURN n.name, m.name
```
## best route
### add different relationship train_to, so we can study alternate route later.

```
MATCH (n01:City {name: 'Mountain View'}),
      (n02:City {name: 'Palo Alto'})
MERGE (n01)-[:train_to {distance: 5.4}]->(n02)    // drop 0.1 mile
MERGE (n02)-[:train_to {distance: 5.4}]->(n01)
```
### do some query

```
MATCH p = allShortestPaths((s {name: 'Palo Alto'})-[r:connect_to*..5]->(d {name: 'Sunnyvale'}))
RETURN NODES(p)
```
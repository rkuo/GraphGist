CREATE (n01:City {name: 'Mountain View', population: 77646}), 
	(n02:City {name: 'Palo Alto', population: 66642}),
	(n18:City {name: 'Sunnyvale', population: 147559}),
	(n14:City {name: 'Fremont', population: 224922}),
	(n15:City {name: 'Milpitas', population: 69783}),
	(n16:City {name: 'Santa Clara', population: 120245}),
	(n17:City {name: 'San Jose', population: 998537}),
	(n19:City {name: 'Cupertino', population: 60189}),
	(n26:City {name: 'Athetron', population: 7159}),

	// highway
	(n01)-[:connect_to {distance: 5.5}]->(n02),		// mtv - pa
	(n01)-[:connect_to {distance: 2.9}]->(n18),		// mtv - snyl
	(n02)-[:connect_to {distance: 4.2}]->(n26),		// pa - atht
	(n26)-[:connect_to {distance: 17.1, linkType: 'bridge', toll: 0}]->(n14),	// atht - frmt
	(n14)-[:connect_to {distance: 11.2}]->(n15),	// frmt - mlpt 
	(n16)-[:connect_to {distance: 5.1}]->(n18),		// stcl - snyl
	(n16)-[:connect_to {distance: 4.1}]->(n17),		// stcl - sjs
	(n16)-[:connect_to {distance: 7.4}]->(n19),		// stcl - cptn
	(n17)-[:connect_to {distance: 11.8}]->(n15),	// sjs - mlpt
	(n17)-[:connect_to {distance: 10.3}]->(n19),	// stcl - cptn
	(n18)-[:connect_to {distance: 9.9}]->(n15),		// snyl - mlpt 
	(n18)-[:connect_to {distance: 3.3}]->(n19),		// snyl - cptn

	// reverse direction
	(n02)-[:connect_to {distance: 5.5}]->(n01),		
	(n18)-[:connect_to {distance: 2.9}]->(n01),		
	(n26)-[:connect_to {distance: 4.2}]->(n02),		
	(n14)-[:connect_to {distance: 17.1, linkType: 'bridge', toll: 5}]->(n26),	
	(n15)-[:connect_to {distance: 11.2}]->(n14),	
	(n18)-[:connect_to {distance: 5.1}]->(n16),		
	(n17)-[:connect_to {distance: 4.1}]->(n16),		
	(n19)-[:connect_to {distance: 7.4}]->(n16),		
	(n17)-[:connect_to {distance: 11.8}]->(n15),	
	(n19)-[:connect_to {distance: 10.3}]->(n17),	
	(n15)-[:connect_to {distance: 9.9}]->(n18),		 
	(n19)-[:connect_to {distance: 3.3}]->(n18),		

	// train - northbound
	(n17)-[:train_to {distance: 4.1}]->(n16),		
	(n16)-[:train_to {distance: 5.1}]->(n18),		
	(n18)-[:train_to {distance: 2.9}]->(n01),		
	(n01)-[:train_to {distance: 5.5}]->(n02),		
	(n02)-[:train_to {distance: 4.2}]->(n26),		

	// train - southbound
	(n16)-[:train_to {distance: 4.0}]->(n17),	// dropped 0.1 mile		
	(n18)-[:train_to {distance: 5.1}]->(n16),		
	(n01)-[:train_to {distance: 2.9}]->(n18),		
	(n02)-[:train_to {distance: 5.5}]->(n01),		
	(n26)-[:train_to {distance: 4.2}]->(n02),		

	// Add special place in City School, Airport 
	(s01:School {name: 'Stanford University'}),
	(s02:School {name: 'Foothill Community College'}),
	(s03:School {name: 'San Jose State University'}),
	(s04:School {name: 'De Anza College'}),
	(s05:School {name: 'Santa Clara University'}),	
	(a01:Airport {name: 'Mineta San Jose International Airport'}),

	// Connect the places to City
	(n02)-[:has]->(s01), 
	(n01)-[:has]->(s02), 
	(n17)-[:has]->(s03), 
	(n19)-[:has]->(s04), 
	(n16)-[:has]->(s05), 
	(n17)-[:has]->(a01) 

// find the shortest route from City A to City B
MATCH p=(a {name: 'Palo Alto'})-[r*2..5]->(b {name: 'Milpitas'}) 
WHERE NOT(a-->b) 					// where a is not directly connected to b
WITH p, relationships(p) AS rcoll 	// just for readability, alias rcoll
RETURN p, reduce(totalDistance=0, x IN rcoll| totalDistance + x.distance) AS totalDistance
ORDER BY totalDistance
LIMIT 1

// if we have to pay toll, use 25 miles/gal * $5.0 per gal = $0.20 per mile
// for $4/0.20 = 20 miles difference, ??? reduce is not working yet, 
MATCH p=(a {name: 'Palo Alto'})-[r*2..5]->(b {name: 'Milpitas'}) 
WHERE NOT(a-->b) 					// where a is not directly connected to b
WITH p, relationships(p) AS rcoll 	// just for readability, alias rcoll
RETURN p, reduce(totalCost=0, x IN rcoll| totalCost + x.distance * 0.20) AS totalCost
ORDER BY totalCost
LIMIT 1


// find all cities has school
MATCH (n:City)-[:has]->(m:School) RETURN n.name, m.name

// use shortest distance
MATCH p = allShortestPaths((s {name: 'Palo Alto'})-[r:connect_to*..5]->(d {name: 'Santa Clara'}))
RETURN NODES(p)

// find which City has both School and Airport
MATCH (l: Airport)<-[:has]-(n:City)-[:has]->(m: School) 
RETURN n.name, m.name, l.name



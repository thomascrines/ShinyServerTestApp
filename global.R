library(shiny)
library(leaflet)        # For GIS
library(rgdal)          
library(SPARQL)         # To return data from API

SparqlDataEndpoint <- 'http://statistics.gov.scot/sparql.csv'
SparqlDataQuery <- 'PREFIX qb: <http://purl.org/linked-data/cube#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX dim: <http://statistics.gov.scot/def/dimension/>
PREFIX sdmx: <http://purl.org/linked-data/sdmx/2009/dimension#>

SELECT ?year ?age ?gender ?servicesperformance ?simd ?urbanrural ?area ?95lowerCI ?percent ?95upperCI

WHERE { graph <http://statistics.gov.scot/graph/local-authority-services-and-performance---shs> {
?s qb:dataSet <http://statistics.gov.scot/data/local-authority-services-and-performance---shs>;
dim:age ?ageURI;
sdmx:refPeriod ?yearURI;
dim:gender ?genderURI;
dim:localAuthorityServicesAndPerformance ?servicesperformanceURI;
dim:simdQuintiles ?simdURI;
dim:urbanRuralClassification ?urbanruralURI;
<http://statistics.gov.scot/def/measure-properties/95-lower-confidence-limit-percent> ?95lowerCI;
sdmx:refArea ?areaURI.

?t qb:dataSet <http://statistics.gov.scot/data/local-authority-services-and-performance---shs>;
dim:age ?ageURI;
sdmx:refPeriod ?yearURI;
dim:gender ?genderURI;
dim:localAuthorityServicesAndPerformance ?servicesperformanceURI;
dim:simdQuintiles ?simdURI;
dim:urbanRuralClassification ?urbanruralURI;
<http://statistics.gov.scot/def/measure-properties/95-upper-confidence-limit-percent> ?95upperCI;
sdmx:refArea ?areaURI.

?u qb:dataSet <http://statistics.gov.scot/data/local-authority-services-and-performance---shs>;
dim:age ?ageURI;
sdmx:refPeriod ?yearURI;
dim:gender ?genderURI;
dim:localAuthorityServicesAndPerformance ?servicesperformanceURI;
dim:simdQuintiles ?simdURI;
dim:urbanRuralClassification ?urbanruralURI;
<http://statistics.gov.scot/def/measure-properties/percent> ?percent;
sdmx:refArea ?areaURI.
}

?ageURI rdfs:label ?age.
?yearURI rdfs:label ?year.
?genderURI rdfs:label ?gender.
?servicesperformanceURI rdfs:label ?servicesperformance.
?simdURI rdfs:label ?simd.
?urbanruralURI rdfs:label ?urbanrural.
?areaURI rdfs:label ?area.
}'

rawData <- SPARQL(SparqlDataEndpoint, SparqlDataQuery, format = "csv")
Unfiltered <- rawData$results

LocalAuthorityServicesAndPerformanceUnsorted <- unique(Unfiltered["servicesperformance"])
LocalAuthorityServicesAndPerformance <- LocalAuthorityServicesAndPerformanceUnsorted[order(unique(Unfiltered["servicesperformance"])),]


DateCodeUnsorted <- unique(Unfiltered["year"])
DateCode <- DateCodeUnsorted[order(unique(Unfiltered["year"])),]

FeatureCodeUnsorted <- unique(Unfiltered["area"])
FeatureCode <- FeatureCodeUnsorted[order(unique(Unfiltered["area"])),]

localAuthoritiesShape <- readOGR(dsn="data", layer=
                                     "Local_Authority_Districts_December_2016_Super_Generalised_Clipped_Boundaries_in_Great_Britain", 
                                 verbose=FALSE)

locAuthLatLon <- spTransform(localAuthoritiesShape, CRS("+proj=longlat +datum=WGS84"))
scotLocAuth <- subset(locAuthLatLon, locAuthLatLon$lad16nm %in% FeatureCode)

byYearColoursMap <- c("#008080","#6cafe1",  "#ccccff")

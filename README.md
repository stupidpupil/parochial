# parochial

A R package to make it easier to get started with travel time analyses in bits of Britain. 

## Features and Anti-Features

### Downloading
_parochial_ will download:
- OpenStreetMap data from geofabrik.de
- Welsh and Scottish bus etc. data from Traveline ([requires registration](https://www.travelinedata.org.uk/traveline-open-data/traveline-national-dataset/))
- "heavy" rail data from data.atoc.org ([requires registration](https://data.atoc.org/))
- English bus etc. and Transport for London open data from [DfT BODS GOV.UK](https://data.bus-data.dft.gov.uk/)
- Terrain elevation data from Ordnance Survey

### Processing
_parochial_
- processes TransXChange and CIF timetables to GTFS using [{UK2GTFS}](https://github.com/ITSLeeds/UK2GTFS)
- crops map and timetables to a particular geospatial area and period in time
- buffers geospatial bounds where appropriate to ensure adequate coverage
- uses [pfaedle](https://github.com/ad-freiburg/pfaedle) to fit public transport routes to roads and railways
- uses [gtfstidy](https://github.com/patrickbr/gtfstidy/) to merge and compress public transport timetables

### Outputs
_parochial_ can prepare:
- [OpenTripPlanner](https://www.opentripplanner.org/) network graphs, good for planning single journeys
- [{r5r}](https://github.com/ipeaGIT/r5r) network graphs, good for producing many-to-many multimodal public transport travel time matrices
- [OSRM](http://project-osrm.org/) network graphs, good for producing many-to-many driving travel time matrices

### Misc
- Includes a GitHub Actions workflow with extensive parallelisation
- Supports caching of downloads and outputs, both when run as a GitHub Action and when run locally

## Minimum requirements
- R
- [osmium](https://osmcode.org/osmium-tool/)
- Support for symlinks (e.g. macOS, Linux including _Windows Subsystem for Linux_)

## How-to

```R
devtools::install_github("stupidpupil/parochial")
library(parochial)

# Complete config.yml
check_config_and_environment()

download_atoc()
prepare_atoc_gtfs()
download_tnds()
prepare_tnds_gtfs()
download_and_prepare_bods_gtfs()
download_and_prepare_osm()

# If you want to include elevation data (e.g. for walking, cycling)
download_terrain50()
prepare_terrain50()

# If you've got gtfstidy and pfaedle installed
if(gtfstidy_is_available() & pfaedle_is_available()){
  prepare_merged_gtfs()
}

# OpenTripPlanner
# (Requires JDK 17)
download_otp()
prepare_street_graph()
prepare_transport_graph()
# output/opentripplanner/ should now contain graph.obj

# r5r
# (Requires JDK 11)
prepare_r5r_network_dat()
# output/r5r/ should now contain network.dat


```
## Licence of outputs

Outputs include data derived from the following sources:

| Data                       | License                                                                             | Source                                   |
|----------------------------|-------------------------------------------------------------------------------------|------------------------------------------|
| ATOC Heavy Rail Timetables | [CC-BY-2.0](https://creativecommons.org/licenses/by/2.0/uk/legalcode)    | RSP Limited (Rail Delivery Group)                              |
| DfT Bus Open Data Service (BODS) | [OGL-UK-3.0](https://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/) | Department for Transport (UK Government)  |
| Traveline National Data Set (TNDS) | [OGL-UK-3.0](https://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/) | Traveline  |
| OpenStreetMap data         | [ODbL-1.0](https://opendatacommons.org/licenses/odbl/)                                  | OpenStreetMap contributors, Geofabrik.de |
| Terrain 50 elevation data  | [OGL-UK-3.0](https://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/) | Ordnance Survey                      |


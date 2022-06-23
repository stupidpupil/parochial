# Parochial

## Requirements
- R
- [Java 17](https://adoptium.net)
- [osmium](https://osmcode.org/osmium-tool/)

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


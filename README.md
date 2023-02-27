# Pleiades
_Work in progress_

SwiftUI client for Subaru remote vehicle services, for iOS and iPadOS

## Name
"Pleiades" is the Greek name for a cluster of stars in the Taurus constellation. The Japanese name for this cluster is "Subaru".

## Project goals
 - Deliver faster and more user-friendly interface, compared to official MySubaru app
 - watchOS integration, enabling access to remote start/door lock/location services from Apple Watch
 - Siri and Shortcuts integration, enabling voice commands to start vehicle or control door locks

## Development constraints
All features are tested on a 2019 Forester, with a StarLink Security Plus account based in the US, as that is what I have access to. This vehicle uses the G2 version of Subaru's API. If you are interested in testing on other vehicles, please contact me. Particularly of interest are:
 - 2018 vehicles and older, which use the G1 API and do not support remote start
 - Plug-in Hybrid variants, which use the G2 API with additional features
 - Solterra EVs, which use the new G3 API
 - Vehicles registered in Canada, which seem to behave the same as US ones, but on a different server
 
 ## Acknowledgements
 Knowledge of the Subaru API was gleaned from the [Subarulink](https://github.com/G-Two/subarulink) Python package.

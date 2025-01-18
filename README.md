# BikeNearMe

A cross platform application to monitor the availability of station-based mobility systems.
It allows the user to see how many bikes are available in a station in real-time. For some systems, it provides the history of availability by hour of day from the last week data. It also shows at which distance they are from the user's current position. Therefore, it allows users to better plan their journey from A to B.

## Project state

Currently, some features are only accessible on a limited number of systems. However, they could be enabled on more systems by upgrading the backend services from the free tier, reducing the current limitations.

#### Fully working for the following systems
- [Bixi](https://bixi.com/) (Montréal, QC)
- [àVélo](https://aveloquebec.ca/) (Québec, QC) (Seasonal system)
- [Accès Vélo](https://sts.saguenay.ca/infos-pratiques/acces-velo) (Saguenay, QC) (Seasonal system)
- [BikeShareToronto](https://bikesharetoronto.com/) (Toronto, ON)

#### Partially working for the following systems (No history of availability feature)
- Canada
    - [mobi](https://www.mobibikes.ca/) (Vancouver, BC)
    - [SocialBikes](https://hamilton.socialbicycles.com/) (Hamilton, ON)

- United States
    - [CitiBike](https://citibikenyc.com/) (New York, NY)
    - [CapitalBikeShare](https://capitalbikeshare.com/) (Washington, DC)
    - [Bluebikes](https://bluebikes.com/) (Boston, MA)
    - [Indego](https://www.rideindego.com/) (Philadelphia, PA)
    - [DivvyBikes](https://divvybikes.com/) (Chicago, IL)
    - [MoGo](https://mogodetroit.org/) (Detroit, MI)
    - [CoGo](https://cogobikeshare.com/) (Colombus, OH)
    - [BayWheels](https://www.lyft.com/bikes/bay-wheels) (San Francisco, CA)
    - [MetroBikeShare](https://bikeshare.metro.net/) (Los Angeles, CA)
    - [Biki](https://gobiki.org/) (Honolulu, HI)
    - [HIBIKE](https://www.hawaiiislandbike.com/) (Island of Hawaii, HI)
 
- France
    - [Vélib](https://www.velib-metropole.fr/) (Paris)

<em><b>Note:</b> This application is not affiliated with, endorsed or sponsored by these entities.</em>

## User interface

The application is using a layout similar to the one of [Transit](https://transitapp.com/) for nearby bus, trains or subway routes schedule but applying it to shared mobility stations availability of bikes or docks to return them (other modes could be added later).

<table>
  <tr>
    <td>Surrounding map with stations view</td>
    <td>Selected station information view</td>
    <td>Station availability history view</td>
  </tr>
  <tr>
    <td><img src="https://github.com/user-attachments/assets/ec92e581-2a3c-44ce-ba99-53d5e857d21b" width=270/></td>
    <td><img src="https://github.com/user-attachments/assets/cc823555-77b2-4041-9522-898f62a03ab8" width=270/></td>
    <td><img src="https://github.com/user-attachments/assets/11705eaa-eaa7-4207-bef7-50f2f4c1a029" width=270/></td>
  </tr>
</table>

## How to use

Ensure you have an internet connection, as the application directly calls the system API to retrieve its station data (for cost reasons otherwise a server would be great). Then, you simply have to open the app, if the region you are in have stations you will see them in a list that you can scroll in if there is a lot. Each station is clickable and you will see information about it. As stated above, on the station view some systems allow to view the history of availability through a button.

## Upcoming improvements

- <strike>Making it possible to add systems dynamically in the database (if using the [GBFS](https://gbfs.org/) standard)</strike> <em>Done!</em>
- Adding a price calculator by the time length that adapt for each systems
- Making it work on screen where the width is bigger than the height
- Adding non-bike station-based systems support
- Making it possible to display systems that are not station based

## Useful links

The main functionnality of the application which is showing the station status of a shared mobility systems in real-time is archieve thanks to the [General Bikeshare Feed Specification](https://gbfs.org/).

Providing the history of availability by hour of day from the last week data is possible with [Google Apps Script](https://developers.google.com/apps-script). A trigger is set so that the status of the system is store on a spreadsheet every five minutes. The data in cells of the spreadsheet is defined the following way:
```
cell <= a,b,c,d,e

a = nbOfBikesDisabled
b = nbOfBikesAvailable
c = nbOfElectricBikesAvailable
d = nbOfDocksDisabled
e = nbOfDocksAvailable
```
The data is then transfered each night to a [Realtime Database](https://firebase.google.com/docs/database) in Firebase so it is easier to query in the application. The [drive folder](https://drive.google.com/drive/u/0/folders/1vw1ik62Sepzjl0Iq_TzPDMlqFNydO0Zr) that contains the script and its related spreadsheet is available publicly.

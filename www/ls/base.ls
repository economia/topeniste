tooltip = new Tooltip!
obce = {}

mapControl = L.map do
    *   'map'
    *   minZoom: 6,
        maxZoom: 13,
        zoom: 8,
        center: [49.78, 15.5]
$map = $ \#map
mapControl.on \zoomend (evt) ->
    if mapControl.getZoom! >= 11
        $map.css \background \#555
    else
        $map.css \background \#fff

currentMapId = 0
currentLayer = null
srcPrefix = "../data"
getLayer = (address) ->
    L.tileLayer do
        *   "#srcPrefix/#address/{z}/{x}/{y}.png"
        *   attribution: '<a href="http://creativecommons.org/licenses/by-nc-sa/3.0/cz/" target = "_blank">CC BY-NC-SA 3.0 CZ</a> <a target="_blank" href="http://ihned.cz">IHNED.cz</a>, data <a target="_blank" href="http://www.volby.cz">ČSÚ</a>'
            zIndex: 2

mapLayer = L.tileLayer do
    *   "http://hnmaps.blob.core.windows.net/tiles-desaturated/{z}/{x}/{y}.png"
    *   zIndex: 3
        opacity: 0.65
        attribution: 'mapová data &copy; přispěvatelé OpenStreetMap, obrazový podkres <a target="_blank" href="http://ihned.cz">IHNED.cz</a>'

mapUnderLayer = L.tileLayer do
    *   "http://hnmaps.blob.core.windows.net/tiles-gray/{z}/{x}/{y}.png"
    *   zIndex: 1
        opacity: 0.3
        attribution: 'mapová data &copy; přispěvatelé OpenStreetMap, obrazový podkres <a target="_blank" href="http://ihned.cz">IHNED.cz</a>'


getGrid = (address) ->
    new L.UtfGrid "#srcPrefix/#address/{z}/{x}/{y}.json", useJsonP: no
        ..on \mouseover (e) ->
            [obec, okrsek, zeman, schwarz] = e.data
            total = zeman + schwarz
            txt = "<b>#obec</b>, okrsek č. #okrsek<br />"
            if total
                txt += "Miloš Zeman: #{Math.round zeman / total * 100}% (#zeman hlasů)<br />"
                txt += "Karel Schwarzenberg: #{Math.round schwarz / total * 100}% (#schwarz hlasů)"
            else
                txt += "V tomto okrsku nikdo nevolil"
            tooltip.display txt
        ..on \mouseout -> tooltip.hide!

mapControl.addLayer getGrid "tiles"

selectParty = (mapId) ->
    currentMapId := mapId
    selectLayer maps[currentMapId]

selectLayer = (map) ->
    if currentLayer
        lastLayer = currentLayer
        setTimeout do
            ->
                mapControl.removeLayer lastLayer.map
            300
    layer = getLayer map.imagery
    mapControl.addLayer layer

    if map.displayMap
        if that == \reverse
            mapControl.removeLayer mapLayer
            mapControl.addLayer mapUnderLayer
        else
            mapControl.removeLayer mapUnderLayer
            mapControl.addLayer mapLayer
    else
        mapControl.removeLayer mapLayer
        mapControl.removeLayer mapUnderLayer
    currentLayer :=
        map: layer



legend =
    colors: <[#b35806 #542788]>
    values: <[Zeman Schwarzenberg]>

maps =
    *   name: "Mapa topenišť"
        imagery: "tiles"
        grid: "tiles"
    *   name: "Mapa topenišť s&nbsp;podkladem"
        imagery: "tiles"
        grid: "tiles"
        displayMap: yes

$body = $ \body
$ document .on \mouseout \#map ->
    tooltip.hide!

$ document .on \click '.selector li' ->
    $e = $ @
    $ '.selector li' .removeClass \active
    $e.addClass 'active'
    c = $e.data \count
    c = parseInt c, 10
    if c > 0
        $ ".legend" .addClass \choro
    else
        $ ".legend" .removeClass \choro
    selectLayer maps[c]

geocoder = null
geocodeMarker = null
L.Icon.Default.imagePath = "http://service.ihned.cz/js/leaflet/images"
geocode = (address, cb) ->
    (results, status) <~ geocoder.geocode {address}
    return cb status if status isnt google.maps.GeocoderStatus.OK
    return cb 'no-results' unless results?.length > 0
    result = results[0]
    latlng = new L.LatLng do
        result.geometry.location.lat!
        result.geometry.location.lng!
    mapControl.setView latlng, 10
    if geocodeMarker == null
        geocodeMarker := L.marker latlng
            ..on \mouseover -> mapControl.removeLayer geocodeMarker
    geocodeMarker
        ..addTo mapControl
        ..setLatLng latlng
    cb null
$ '.search form' .on \submit (evt) ->
    geocoder ?:= new google.maps.Geocoder();
    evt.preventDefault!
    address = $ '.search input' .val!
    _gaq.push ['_trackEvent' 'geocode' address]
    (err) <~ geocode address
    if err
        alert "Bohužel danou adresu se nám nepodařilo nalézt."
selectParty currentMapId


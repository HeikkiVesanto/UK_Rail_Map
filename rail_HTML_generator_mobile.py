#!/usr/bin/python
#folder is the folder name minus _js
__author__ = 'Heikki Vesanto'

import sys, getopt, time

colors = [
'#FFB300',
'#803E75',
'#FF6800',
'#A6BDD7',
'#C10020',
'#CEA262',
'#817066',
'#007D34',
'#F6768E',
'#00538A',
'#FF7A5C',
'#53377A',
'#FF8E00',
'#B32851',
'#F4C800',
'#7F180D',
'#93AA00',
'#593315',
'#F13A13',
'#232C16',
'#00ff00',
'#0000ff',
'#ff0000',
'#01fffe',
'#ffa6fe',
'#ffdb66',
'#006401',
'#010067',
'#95003a',
'#007db5',
'#ff00f6',
'#774d00',
'#90fb92',
'#0076ff',
'#d5ff00',
'#ff937e',
'#6a826c',
'#ff029d',
'#fe8900',
'#7e2dd2']

def main(argv):
    global inputfile
    inputfile = ''
    try:
      opts, args = getopt.getopt(argv,"hi:","ifile=")
    except getopt.GetoptError:
      print 'test.py -i <inputfile>'
      sys.exit(2)
    for opt, arg in opts:
      if opt == '-h':
         print 'test.py -i <inputfile>'
         sys.exit()
      elif opt in ("-i", "--ifile"):
         inputfile = arg
    print 'Input file is', inputfile

if __name__ == "__main__":
   main(sys.argv[1:])

input_file = inputfile + '.txt'

f = open(input_file, 'r')

class Layers:
    filename = ''
    name = ''
    color = ''

    def __init__(self, filename, folder):
        self.color = color_generator.next()
        self.filename = filename.strip()
        self.layername = self.filename[:-3]
        self.jsonfilename = 'json_' + self.layername + '_' + folder
        self.jsonlayername = self.jsonfilename + '_layer'
        self.jsonstyle = 'style_' + self.layername + '_' + folder
        self.path = folder + '_js'

def get_color(list):
    i = 0
    while i < len(list):
        yield list[i]
        i += 1
    for i in xrange(99999):
        yield '#000000'

color_generator = get_color(colors)

file_list = []

for line in f.readlines():
    file = line[:-3]
    input_file = Layers(line, inputfile)
    file_list.append(input_file)

outputfile = inputfile + '_mobile.html'

of = open(outputfile, 'w')

header1= '''<html>
    <head>
        <title>UK Rail Map - '''
of.write(header1)
of.write(inputfile.capitalize())

header2= '''</title>
        <meta charset="utf-8" />
        <link rel="stylesheet" href="css/leaflet.css" />
        <link rel="stylesheet" href="css/groupedlayercontrol.css" />
        <link rel="stylesheet" type="text/css" href="css/style.css">
        <script src="js/leaflet.js"></script>
        <script src="js/groupedlayercontrol.js"></script>
        <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" />
        <style>
        .leaflet-control-layers {
          max-height: auto;
          overflow: auto;
          width: auto ;
        }
        </style>
    </head>

        <body style="padding: 0; margin: 0;">
        <div id="map" style="width: 100%; height: 100%; padding: 0; margin: 0; background: #fff;"></div>
'''
of.write(header2)
for i in file_list:
    of.write('\n')
    stri = '        <script src="' + i.path + '/' + i.filename + '"></script>'
    of.write(stri)

header3 = '''<script>
        var map = L.map('map', {zoomControl:false, maxZoom:15, minZoom:5, zoom:6, center:[55,-2.5]})
        map.setMaxBounds([
            [48, -13],
            [63, 10]
        ]);
        var basemap = L.tileLayer('http://a.tile.stamen.com/toner/{z}/{x}/{y}.png', {
            attribution: ' Map tiles by <a href="http://stamen.com">Stamen Design</a>, <a href="http://creativecommons.org/licenses/by/3.0">CC BY 3.0</a> &mdash; Map data: &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors,<a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>'
        }).addTo(map);

        var info2 = L.control();
        info2.setPosition('topleft');
        info2.onAdd = function (map) {
            this._div = L.DomUtil.create('div', 'info2'); // create a div with a class "info"
            this._div.innerHTML = 'View by: <b><a target="_top" href="agencies_mobile.html">Agency</a></b> || <b><a target="_top"  href="parent_mobile.html">Parent Company</a></b><br>Created by: <b><a href="http://gisforthought.com/uk-rail-map/">GIS for Thought</a></b> || ''' + time.strftime("%Y/%m/%d") + '''<br>Hosting: <a href="https://www.digitalocean.com/?refcode=f67c2dabcf79" target="_blank">Digital Ocean</a> || Logic: <a href="ukrail_distinct_agencies_parent.html" target="_blank">Agency to Parent</a>';
            return this._div;
        };
        info2.addTo(map);

        var zoomer = L.control.zoom();
        zoomer.addTo(map);

        function moveDown(e) {
            var layer = e.target;
            layer.bringToBack();
        }
        function onEachFeature(feature, layer) {
            layer.on({
                click: moveDown
            });
        }
'''
of.write(header3)
for j in file_list:
    of.write('        function ' + j.jsonstyle + '(feature) {' + '\n')
    of.write("""            return {
                weight: 1.6,
                color: '""")
    of.write(j.color)
    of.write("""',
                dashArray: '',
                opacity: 1.0
            };
        }
        var """)
    of.write(j.jsonlayername + '  = new L.geoJson(' + j.jsonfilename + ', {'+'\n')
    of.write('onEachFeature: onEachFeature,'+'\n')
    of.write('style: ')
    of.write(j.jsonstyle)
    of.write(''+'\n')
    of.write('});'+'\n')

for j in file_list:
    of.write(j.jsonlayername + '.addTo(map);'+'\n')
    break

layers_title = inputfile.title()

legend1='''var groupedOverlays = {
        "''' + layers_title + '''": {'''
of.write(legend1+'\n')

for k in file_list[:-1]:
    of.write("'<font color=")
    of.write(k.color)
    of.write('>')
    of.write('&')
    of.write('#9632;</font> ')
    of.write(k.layername)
    of.write("': ")
    of.write(k.jsonlayername)
    of.write(',')

of.write("'<font color=")
of.write(file_list[-1].color)
of.write('>')
of.write('&')
of.write('#9632;</font> ')
of.write(file_list[-1].layername)
of.write("': ")
of.write(file_list[-1].jsonlayername)
of.write('\n')

ender1='''}
            };

        var options = {groupCheckboxes: true, collapsed: true, exclusiveGroups:["'''+ layers_title +'''"]};
        L.control.groupedLayers([], groupedOverlays , options).addTo(map);

    </script>
<script>
  (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
  (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
  m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
  })(window,document,'script','//www.google-analytics.com/analytics.js','ga');

  ga('create', 'UA-41533238-5', 'auto');
  ga('send', 'pageview');

</script>
</body>
</html>'''
of.write(ender1)
f.close()
of.close()
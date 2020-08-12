---
title: "My Beautiful Rio" 
author: "Matheus Cardoso"
date: "2020-07-21"
output: 
  html_document: 
    fig_caption: yes
    fig_width: 10
    fig_height: 6
    highlight: zenburn
    keep_md: yes
    theme: simplex
    toc: yes
    number_sections: yes
    code_folding: hide
editor_options: 
  chunk_output_type: console
---




```r
library(leaflet)
library(magrittr)

pao <- c("<a href='https://www.bondinho.com.br/parque/'>Pão de Açúcar<br><small>(Option for English version on right top side)</small><br><img src='https://www.bondinho.com.br/_nuxt/img/bondinho-pao-de-acucar-footer-desktop-0b2f653.jpg' width='300' height='150'></a>")

cristo <- c("<a href='http://www.tremdocorcovado.rio/gallery.html'>Cristo Redentor<br><small>(Option for English version on right top side)</small><br><img src='https://upload.wikimedia.org/wikipedia/commons/thumb/8/87/Cristo_Redentor_-_Rio_de_Janeiro%2C_Brasil.jpg/640px-Cristo_Redentor_-_Rio_de_Janeiro%2C_Brasil.jpg?1595337262337' width='200' height='300'></a>")

copacabana <- c("<a href='https://www.wikiwand.com/en/Copacabana,_Rio_de_Janeiro'>Copacabana Beach<br><small>_____________________________________</small><br><img src='https://thumbor.thedailymeal.com/feB0qXZeVbTic7htl-L7Zb1o77w=/574x366/filters:format(webp)/https://www.thedailymeal.com/sites/default/files/2018/01/17/Copacabana%20Beach.Dreamstime.jpg' width='300' height='150'></a>")

leaflet() %>% 
    addTiles() %>% 
    setView(lng = -43.166690, lat = -22.953551, zoom = 12) %>% 
    addMarkers(lng = -43.154713, lat = -22.949999, popup = pao) %>% 
    addMarkers(lng = -43.21036, lat = -22.952330, popup = cristo) %>% 
    addMarkers(lng =  -43.178818, lat = -22.968510, popup = copacabana)
```

<!--html_preserve--><div id="htmlwidget-aed13e7d02fb08f3df44" style="width:960px;height:576px;" class="leaflet html-widget"></div>
<script type="application/json" data-for="htmlwidget-aed13e7d02fb08f3df44">{"x":{"options":{"crs":{"crsClass":"L.CRS.EPSG3857","code":null,"proj4def":null,"projectedBounds":null,"options":{}}},"calls":[{"method":"addTiles","args":["//{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",null,null,{"minZoom":0,"maxZoom":18,"tileSize":256,"subdomains":"abc","errorTileUrl":"","tms":false,"noWrap":false,"zoomOffset":0,"zoomReverse":false,"opacity":1,"zIndex":1,"detectRetina":false,"attribution":"&copy; <a href=\"http://openstreetmap.org\">OpenStreetMap<\/a> contributors, <a href=\"http://creativecommons.org/licenses/by-sa/2.0/\">CC-BY-SA<\/a>"}]},{"method":"addMarkers","args":[-22.949999,-43.154713,null,null,null,{"interactive":true,"draggable":false,"keyboard":true,"title":"","alt":"","zIndexOffset":0,"opacity":1,"riseOnHover":false,"riseOffset":250},"<a href='https://www.bondinho.com.br/parque/'>Pão de Açúcar<br><small>(Option for English version on right top side)<\/small><br><img src='https://www.bondinho.com.br/_nuxt/img/bondinho-pao-de-acucar-footer-desktop-0b2f653.jpg' width='300' height='150'><\/a>",null,null,null,null,{"interactive":false,"permanent":false,"direction":"auto","opacity":1,"offset":[0,0],"textsize":"10px","textOnly":false,"className":"","sticky":true},null]},{"method":"addMarkers","args":[-22.95233,-43.21036,null,null,null,{"interactive":true,"draggable":false,"keyboard":true,"title":"","alt":"","zIndexOffset":0,"opacity":1,"riseOnHover":false,"riseOffset":250},"<a href='http://www.tremdocorcovado.rio/gallery.html'>Cristo Redentor<br><small>(Option for English version on right top side)<\/small><br><img src='https://upload.wikimedia.org/wikipedia/commons/thumb/8/87/Cristo_Redentor_-_Rio_de_Janeiro%2C_Brasil.jpg/640px-Cristo_Redentor_-_Rio_de_Janeiro%2C_Brasil.jpg?1595337262337' width='200' height='300'><\/a>",null,null,null,null,{"interactive":false,"permanent":false,"direction":"auto","opacity":1,"offset":[0,0],"textsize":"10px","textOnly":false,"className":"","sticky":true},null]},{"method":"addMarkers","args":[-22.96851,-43.178818,null,null,null,{"interactive":true,"draggable":false,"keyboard":true,"title":"","alt":"","zIndexOffset":0,"opacity":1,"riseOnHover":false,"riseOffset":250},"<a href='https://www.wikiwand.com/en/Copacabana,_Rio_de_Janeiro'>Copacabana Beach<br><small>_____________________________________<\/small><br><img src='https://thumbor.thedailymeal.com/feB0qXZeVbTic7htl-L7Zb1o77w=/574x366/filters:format(webp)/https://www.thedailymeal.com/sites/default/files/2018/01/17/Copacabana%20Beach.Dreamstime.jpg' width='300' height='150'><\/a>",null,null,null,null,{"interactive":false,"permanent":false,"direction":"auto","opacity":1,"offset":[0,0],"textsize":"10px","textOnly":false,"className":"","sticky":true},null]}],"setView":[[-22.953551,-43.16669],12,[]],"limits":{"lat":[-22.96851,-22.949999],"lng":[-43.21036,-43.154713]}},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->


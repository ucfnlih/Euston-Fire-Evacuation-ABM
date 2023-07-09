;platform (rgb 132 151 176)
;store (rgb 255 230 153)
;ticket (rgb 198 89 17)
;exit (rgb 169 208 142) (rgb 55 86 35) (rgb 226 239 218)]
;waiting hall white
globals
[
  count-evacuees1
  count-evacuees2
  count-evacuees3
  count-allevacuees

  fire-started?
  fire-occur-time
]

breed [passengers passenger]
breed [staffs-high-awareness staff-high]
breed [staffs-medium-awareness staff-medium]
breed [staffs-low-awareness staff-low]
breed [fire-spots fire-spot]

passengers-own [calmed?]

turtles-own
[
  next-patch
  another-patches
  panic-degree
  health-condition
  reaction-time
]


patches-own
[
  fire?
  staffonly?
  accessible?

  dist-exit1
  dist-exit2
  dist-exit3

  dist-allexits

  selected1?
  selected2?
  selected3?
]

to setup
  ca
  reset-ticks
  global-set
  patches-set

  draw-layout
  label-area
  staff-area
  accessible-area

  create-passengers-and-staff
  define-evacuation-routes
end


to go
  ifelse ticks < fire-occur-time
  [move-normal]

  [if fire-started? = false
  [fire-start
  set fire-started? true
  ]

   fire-spread
   emergency-lighting-set
   move-fire-passengers

   ifelse ticks < 200
    [staff-evacuation]
    [move-fire-staff]
  ]

  remove-evacuees

  tick
end

;;;;;;;;;;;;;Go;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to move-normal
  ask passengers
  [
    set next-patch one-of neighbors4 with [staffonly? = false and accessible? = true]
    carefully
     [face next-patch
      move-to next-patch
  ][]
  ]

  ask staffs-low-awareness
  [
    set next-patch one-of neighbors4 with [staffonly? = true and accessible? = true]
    carefully
       [face next-patch
        move-to next-patch
   ][]]

  ask (turtle-set staffs-medium-awareness staffs-high-awareness)
  [
    set next-patch one-of neighbors4 with [accessible? = true]
    carefully
      [face next-patch
       move-to next-patch
  ][]]

end


to fire-start
  ask n-of fire-degree patches with [accessible? = true]
  [
      sprout-fire-spots 1
      [
      set shape "fire"
      set color red
      set size 1.5  ]

    set fire? true
  ]
end


to fire-spread
  ask n-of 1 patches with [any? neighbors4 with [fire? = true] and pcolor != black and accessible? = true ]
  [
    sprout-fire-spots 1
    [
      set shape "fire"
      set color red
      set size 1.5
      set fire? true
    ]
  ]
end

to move-fire-passengers


ask passengers
  [
   ifelse emergency-lighting?
    [set reaction-time reaction-time - 2]
    [set reaction-time reaction-time - 1]

   ifelse reaction-time < 0
      [
       if any? (turtle-set staffs-high-awareness) in-radius 1 and not calmed?
      [set panic-degree panic-degree - 2
      set calmed? true]

    if any? (turtle-set staffs-medium-awareness) in-radius 1 and not calmed?
      [set panic-degree panic-degree - 1
      set calmed? true]

     if any? (turtle-set staffs-low-awareness) in-radius 1 and not calmed?
      [set panic-degree panic-degree - 0
      set calmed? true]


      ifelse panic-degree < 5
       [set next-patch one-of ((neighbors with [staffonly? = false and accessible? = true and fire? = false and any? turtles-here = false]) with-min [dist-allexits])]
       [set next-patch one-of neighbors with [accessible? = true and any? turtles-here = false]]
       carefully
       [
        face next-patch
        move-to next-patch
       ]
       []

    ]
    []

    if [fire? = true] of patch-here
    [
      set health-condition health-condition - 1
      if health-condition = 0 [die]
    ]
    ]

end

to staff-evacuation

  ask (turtle-set staffs-medium-awareness staffs-low-awareness staffs-high-awareness)
  [
    ifelse emergency-lighting?
    [set reaction-time reaction-time - 2]
    [set reaction-time reaction-time - 1]

   ifelse reaction-time < 0
  [
    ifelse [pcolor] of patch-here = white
  [set next-patch one-of neighbors4 with [accessible? = true and fire? = false and any? turtles-here = false]
    carefully
      [face next-patch
       move-to next-patch
   ][]]
    [set next-patch min-one-of patches with [pcolor = white and fire? = false and any? turtles-here = false] [distance myself]
     face next-patch
     move-to next-patch
    ]
    ]
    []

    if [fire? = true] of patch-here
    [set health-condition health-condition - 1
     if health-condition = 0 [die]
   ]]
end

to move-fire-staff
  ask (turtle-set staffs-medium-awareness staffs-low-awareness staffs-high-awareness)
     [
      ifelse panic-degree < 5
        [set next-patch one-of ((neighbors with [accessible? = true and fire? = false and any? turtles-here = false]) with-min [dist-allexits])]
        [set next-patch one-of neighbors with [accessible? = true and any? turtles-here = false]]
      carefully
      [
        face next-patch
        move-to next-patch
      ]
      []

      if [fire? = true] of patch-here
    [
      set health-condition health-condition - 1
      if health-condition = 0 [die]
    ]
        ]
end

to remove-evacuees

  ask (turtle-set passengers staffs-medium-awareness staffs-low-awareness staffs-high-awareness)
  [
    if  pcolor = (rgb 169 208 142)
    [set count-evacuees1 (count-evacuees1 + 1)
     die
    ]

    if pcolor = (rgb 55 86 35)
    [set count-evacuees2 (count-evacuees2 + 1)
     die
    ]

    if pcolor = (rgb 226 239 218)
    [set count-evacuees3 (count-evacuees3 + 1)
     die
    ]
  ]

   set count-allevacuees (count-evacuees1 + count-evacuees2 + count-evacuees3)

end


;;;;;;;;;;;;;;;;;;;;;Set up;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;Create turtles;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to create-passengers-and-staff
    create-passengers  num-passenger-waiting-hall
  [
    set shape "person"
    set size 0.8
    set color brown
    set health-condition 3
    set panic-degree random 8 + 1
    set calmed? false
    set reaction-time 5
    move-to one-of patches with [pcolor = white]
  ]

  create-passengers  num-passenger-store
  [
    set shape "person"
    set size 0.8
    set color brown
    set health-condition 5
    set panic-degree random 8 + 1
    set calmed? false
    set reaction-time 5

    move-to one-of patches with [pcolor = (rgb 255 230 153)]
  ]

  create-staffs-high-awareness num-staffs-high-awareness
  [
    set shape "person"
    set size 0.8
    set color blue
    set health-condition 5
    set panic-degree 1
    set reaction-time 1

   move-to one-of patches with [accessible? = true]
  ]

  create-staffs-medium-awareness num-staffs-medium-awareness
  [
    set shape "person"
    set size 0.8
    set color blue
    set health-condition 5
    set panic-degree 3
    set reaction-time 2

   move-to one-of patches with [accessible? = true]
  ]

  create-staffs-low-awareness num-staffs-low-awareness
  [
    set shape "person"
    set size 0.8
    set color blue
    set health-condition 5
    set panic-degree 4
    set reaction-time 3

   move-to one-of patches with [pcolor = (rgb 198 89 17)]
    ]

end

;;;;;;;;;;;;;;;;;;;;;Global setup;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to global-set
  set fire-started? false
  set count-evacuees1 0
  set count-evacuees2 0
  set count-evacuees3 0
  set count-allevacuees 0
  set fire-occur-time 100
end

;;;;;;;;;;;;;;;;;;;;;Patches attributes setup;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to emergency-lighting-set
  ask patches with [(pxcor > -32) and (pxcor < -26) and (pycor > 10) and (pycor < 14)]
  [ifelse emergency-lighting?
  [set pcolor red
      ask patch -28 12 [set plabel "lighting"]
    ]
    []]
end

to patches-set
   ask patches
  [
   set staffonly? false
   set fire? false
 ]
end

to define-evacuation-routes
  ;exits3
  ask patches with [(pxcor < -29) and (pxcor > -32) and (pycor > -3) and (pycor < 1) ]
  [set selected3? false
   set dist-exit3 0
  ]
  ;exits2
  ask patches with [(pxcor < -8) and (pxcor > -15) and (pycor > -17) and (pycor < -14)]
  [set selected2? false
   set dist-exit2 0
  ]
  ;exits1
  ask patches with [(pxcor > 6) and (pxcor < 13) and (pycor > -17) and (pycor < -14)]
  [set selected1? false
   set dist-exit1 0
  ]


  ;Which can go
  ask patches with [pcolor = white]
  [
    set dist-exit1 1000000
    set dist-exit2 1000000
    set dist-exit3 1000000

    set selected1? false
    set selected2? false
    set selected3? false
  ]

  ;platform
  let pxcors_plat [-18 -17 -16 -12 -11 -10 -6 -5 -4 0 1 2 6 7 8 12 13 14 18 19 20 24 25 26]
  foreach pxcors_plat [
  [x] ->
  ask patches with [(pxcor = x) and (pycor > 5) and (pycor < 14)] [
    set dist-exit1 1000000
    set dist-exit2 1000000
    set dist-exit3 1000000

    set selected1? false
    set selected2? false
    set selected3? false
  ]]

  ;store
  ask patches with [(pxcor > 12) and (pxcor < 31) and (pycor > -10) and (pycor < 1)]
  [ set dist-exit1 1000000
    set dist-exit2 1000000
    set dist-exit3 1000000

    set selected1? false
    set selected2? false
    set selected3? false
  ]
  ;store
  ask patches with [(pxcor > -28) and (pxcor < -16) and (pycor > -10) and (pycor < 2)]
  [ set dist-exit1 1000000
    set dist-exit2 1000000
    set dist-exit3 1000000

    set selected1? false
    set selected2? false
    set selected3? false
  ]
  ;ticket office
  ask patches with [(pxcor < -8) and (pxcor > -17) and (pycor > -7) and (pycor < -1)]
  [
    set dist-exit1 1000000
    set dist-exit2 1000000
    set dist-exit3 1000000

    set selected1? false
    set selected2? false
    set selected3? false
  ]

  while [any? (patches with [dist-exit1 = 1000000])]
  [
    let possible-patches (patches with [selected1? = false])
    let chosen-patch (one-of possible-patches with-min [dist-exit1])

    ask chosen-patch
    [
      set selected1? true
      ask (neighbors4 with [dist-exit1 = 1000000])
      [set dist-exit1 (1 + [dist-exit1] of myself)]
    ]
  ]

  while [any? (patches with [dist-exit2 = 1000000])]
  [
    let possible-patches (patches with [selected2? = false])
    let chosen-patch (one-of possible-patches with-min [dist-exit2])

    ask chosen-patch
    [
      set selected2? true
      ask (neighbors4 with [dist-exit2 = 1000000])
      [set dist-exit2 (1 + [dist-exit2] of myself)]
    ]
  ]

  while [any? (patches with [dist-exit3 = 1000000])]
  [
   let possible-patches (patches with [selected3? = false])
   let chosen-patch (one-of possible-patches with-min [dist-exit3])

   ask chosen-patch
   [
     set selected3? true
     ask (neighbors4 with [dist-exit3 = 1000000])
     [set dist-exit3 (1 + [dist-exit3] of myself)]
   ]
  ]

  ask patches
  [set dist-allexits min (list (dist-exit1) (dist-exit2) (dist-exit3))]
end


to staff-area
  ask patches with [(pxcor < -8) and (pxcor > -17) and (pycor > -8) and (pycor < -1)]
  ;ask patches with [pcolor = black]
  [set staffonly? true]
end

to accessible-area
  ask patches with [pcolor = white]
  [set accessible? true]
  ;platform
  let pxcors_plat [-18 -17 -16 -12 -11 -10 -6 -5 -4 0 1 2 6 7 8 12 13 14 18 19 20 24 25 26]
  foreach pxcors_plat [
  [x] ->
  ask patches with [(pxcor = x) and (pycor > 5) and (pycor < 14)] [
  set accessible? true
  ]]
  ;store
  ask patches with [(pxcor > 12) and (pxcor < 31) and (pycor > -10) and (pycor < 1)]
  [set accessible? true]
  ;store
  ask patches with [(pxcor > -28) and (pxcor < -16) and (pycor > -10) and (pycor < 3)]
  [set accessible? true]
  ;building
  ask patches with [pcolor = black]
  [set accessible? false]
  ;ticket office
  ask patches with [(pxcor < -8) and (pxcor > -17) and (pycor > -7) and (pycor < -1)]
  [set accessible? true]


  ;exits3
  ask patches with [(pxcor < -29) and (pxcor > -32) and (pycor > -3) and (pycor < 1) ]
  [ifelse exit3-open?
  [set accessible? true]
    [set accessible? false
     set pcolor black]]

  ;exits2
  ask patches with [(pxcor < -8) and (pxcor > -15) and (pycor > -17) and (pycor < -14)]
  [ifelse exit2-open?
  [set accessible? true]
    [set accessible? false
     set pcolor black]]

  ;exits1
  ask patches with [(pxcor > 6) and (pxcor < 13) and (pycor > -17) and (pycor < -14)]
  [ifelse exit1-open?
  [set accessible? true]
    [set accessible? false
     set pcolor black]]
end


;;;;;;;;;;;;;;;;;;;;;Euston layout setup;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to draw-layout
  ;blue:background
  ask patches with [(pxcor < -30) and (pycor > -17) and (pycor < 17) ]
  [set pcolor (rgb 221 235 247)]

  ask patches with [(pxcor > -31) and (pxcor < -26) and (pycor > 5) and (pycor < 17)]
  [set pcolor (rgb 221 235 247)]

  ask patches with [(pxcor > -30) and (pxcor < 33) and (pycor > 14) and (pycor < 17)]
  [set pcolor (rgb 221 235 247)]

  ask patches with [(pxcor = 32) and (pycor > -17) and (pycor < 17) ]
  [set pcolor (rgb 221 235 247)]

  ask patches with [(pxcor > -31) and (pxcor < 33) and (pycor = -16) ]
  [set pcolor (rgb 221 235 247)]

  ;white: waiting hall
  ask patches with[(pxcor < 31 ) and (pxcor > -26) and (pycor > 4) and (pycor < 14)]
  [set pcolor white]

  ask patches with[(pxcor < 31 ) and (pxcor > -30) and (pycor > -15) and (pycor < 5)]
  [set pcolor white]

  ;grey: train
  let pxcors [-19 -15 -13 -9 -7 -3 -1 3 5 9 11 15 17 21 23 27]

  foreach pxcors [
  [x] ->
  ask patches with [(pxcor = x) and (pycor > 11) and (pycor < 14)] [
    set pcolor (rgb 117 113 113)
  ]]

  foreach pxcors [
  [x] ->
  ask patches with [(pxcor = x) and (pycor > 7) and (pycor < 10)] [
    set pcolor (rgb 117 113 113)
  ]]

  foreach pxcors [
  [x] ->
  ask patches with [(pxcor = x) and (pycor > 9) and (pycor < 12)] [
    set pcolor (rgb 217 217 217)
  ]]

   foreach pxcors [
  [x] ->
  ask patches with [(pxcor = x) and (pycor > 5) and (pycor < 8)] [
    set pcolor (rgb 217 217 217)
  ]]


  ;gap between trains (black)
  let pxcors_gap  [-14 -8 -2 4 10 16 22]

  foreach pxcors_gap[
  [x] ->
  ask patches with [(pxcor = x) and (pycor > 5) and (pycor < 14)] [
    set pcolor (rgb 196 166 97)
  ]]


  ;platform
  let pxcors_plat [-18 -17 -16 -12 -11 -10 -6 -5 -4 0 1 2 6 7 8 12 13 14 18 19 20 24 25 26]
  foreach pxcors_plat [
  [x] ->
  ask patches with [(pxcor = x) and (pycor > 5) and (pycor < 14)] [
  set pcolor (rgb 132 151 176)
  ]]

  let pxcors_black [-19 -15 -14 -13 -9 -8 -7 -3 -2 -1 3 4 5 9 10 11 15 16 17 21 22 23 27]
  foreach pxcors_black [
  [x] ->
  ask patches with [(pxcor = x) and (pycor = 5)]
  [set pcolor black
  ]]

  ask patches with [(pxcor = -20) and (pycor > 4) and (pycor < 14)]
  [set pcolor black]

  ask patches with [(pxcor = 28) and (pycor > 4) and (pycor < 14)]
  [set pcolor black]

   ;retail store1
  ask patches with [(pxcor > -28) and (pxcor < -16) and (pycor > -10) and (pycor < 2)]
  [set pcolor (rgb 255 230 153)]
  ask patches with [(pxcor > -27) and (pxcor < -23) and (pycor = 2)]
  [set pcolor (rgb 255 230 153)]
  ask patches with [(pxcor > -28) and (pxcor < -26) and (pycor = 2)]
  [set pcolor black]
  ask patches with [(pxcor > -24) and (pxcor < -16) and (pycor = 2)]
  [set pcolor black]


  ask patches with [(pxcor = -27) and (pycor > -10) and (pycor < 2)]
  [set pcolor black]

  ask patches with [(pxcor = -17) and (pycor > -10) and (pycor < 2)]
  [set pcolor black]

  ask patches with [(pxcor > -28) and (pxcor < -22) and (pycor = -9)]
  [set pcolor black]

  ask patches with [(pxcor > -19) and (pxcor < -16) and (pycor = -9)]
  [set pcolor black]

  ;retail store2
  ask patches with [(pxcor > 12) and (pxcor < 31) and (pycor > -10) and (pycor < 1)]
  [set pcolor (rgb 255 230 153)]

  ask patches with [(pxcor > 13) and (pxcor < 31) and (pycor = -10)]
  [set pcolor black]

  ask patches with [(pxcor > 13) and (pxcor < 31) and (pycor = 0)]
  [set pcolor black]

  ask patches with [(pxcor = 13) and (pycor > -11) and (pycor < -8)]
  [set pcolor black]
  ask patches with [(pxcor = 13) and (pycor > -2) and (pycor < 1)]
  [set pcolor black]
  ask patches with [(pxcor = 13) and (pycor > -7) and (pycor < -3)]
  [set pcolor black]

  ;tickets office
  ask patches with [(pxcor < -8) and (pxcor > -17) and (pycor > -7) and (pycor < -1)]
  [set pcolor (rgb 198 89 17)]

  ask patches with [(pxcor < -8) and (pxcor > -17) and (pycor = -7)]
  [set pcolor black]
  ask patches with [(pxcor < -8) and (pxcor > -17) and (pycor = -1)]
  [set pcolor black]
  ask patches with [(pxcor = -9) and (pycor > -8) and (pycor < -3)]
  [set pcolor black]

  ;barrier
  ask patches with [(pxcor > -5) and (pxcor < -2) and (pycor > -8) and (pycor < -5) ]
  [set pcolor black]

  ask patches with [(pxcor = 7) and (pycor > -5) and (pycor < -1)]
  [set pcolor black]

  ;exits3
  ask patches with [(pxcor < -29) and (pxcor > -32) and (pycor > -3) and (pycor < 1) ]
  [set pcolor (rgb 226 239 218)]
  ;[set pcolor blue]
  ;exits2
  ask patches with [(pxcor < -8) and (pxcor > -15) and (pycor > -17) and (pycor < -14)]
  [set pcolor (rgb 55 86 35)]
  ;[set pcolor yellow]
  ;exits1
  ask patches with [(pxcor > 6) and (pxcor < 13) and (pycor > -17) and (pycor < -14)]
  [set pcolor (rgb 169 208 142)]
  ;[set pcolor grey]
end


to label-area
  let pxcors_plat [-16 -10 -4 2 8 14 20 26]
  foreach pxcors_plat [
  [x] ->
    ask patch x 8 [set plabel "Platform"]]

  ask patch -21 -3 [set plabel "Retail Store"]

  ask patch 22 -4 [set plabel "Retail Store"]

  ask patch -11 -4 [set plabel "Ticket Office"]

  ask patch -30 -1 [set plabel "Exit3"]

  ask patch -11 -15 [set plabel "Exit2"]

  ask patch 10 -15 [set plabel "Exit1"]

  ask patch 10 -15 [set plabel "Exit1"]

  ;gap between trains (black)
  let pxcors_gap  [-14 -8 -2 4 10 16 22]

  foreach pxcors_gap[
  [x] ->
  ask patch  x  12 [set plabel "G"
  ]]
  foreach pxcors_gap[
  [x] ->
  ask patch  x  11 [set plabel "A"
  ]]
  foreach pxcors_gap[
  [x] ->
  ask patch  x  10 [set plabel "P"
  ]]

end
@#$#@#$#@
GRAPHICS-WINDOW
441
21
1248
435
-1
-1
12.3
1
10
1
1
1
0
1
1
1
-32
32
-16
16
0
0
1
ticks
30.0

BUTTON
354
12
421
45
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
355
59
422
92
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
0
254
315
287
fire-degree
fire-degree
1
5
3.0
1
1
NIL
HORIZONTAL

SLIDER
0
94
188
127
num-staffs-high-awareness
num-staffs-high-awareness
0
10
5.0
1
1
NIL
HORIZONTAL

SLIDER
0
130
189
163
num-staffs-medium-awareness
num-staffs-medium-awareness
0
10
5.0
1
1
NIL
HORIZONTAL

SLIDER
0
166
189
199
num-staffs-low-awareness
num-staffs-low-awareness
0
10
5.0
1
1
NIL
HORIZONTAL

PLOT
3
291
220
453
Total Evacuees
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot count-allevacuees"

SWITCH
195
94
313
127
exit3-open?
exit3-open?
0
1
-1000

SWITCH
195
131
313
164
exit2-open?
exit2-open?
0
1
-1000

SWITCH
195
167
313
200
exit1-open?
exit1-open?
0
1
-1000

PLOT
222
291
422
452
Evacuees of Each Exit
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot count-evacuees1"
"pen-1" 1.0 0 -1184463 true "" "plot count-evacuees2"
"pen-2" 1.0 0 -13791810 true "" "plot count-evacuees3"

SLIDER
3
10
232
43
num-passenger-waiting-hall
num-passenger-waiting-hall
300
500
400.0
1
1
NIL
HORIZONTAL

SLIDER
2
46
233
79
num-passenger-store
num-passenger-store
30
80
80.0
1
1
NIL
HORIZONTAL

SWITCH
0
204
314
237
emergency-lighting?
emergency-lighting?
0
1
-1000

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fire
false
0
Polygon -7500403 true true 151 286 134 282 103 282 59 248 40 210 32 157 37 108 68 146 71 109 83 72 111 27 127 55 148 11 167 41 180 112 195 57 217 91 226 126 227 203 256 156 256 201 238 263 213 278 183 281
Polygon -955883 true false 126 284 91 251 85 212 91 168 103 132 118 153 125 181 135 141 151 96 185 161 195 203 193 253 164 286
Polygon -2674135 true false 155 284 172 268 172 243 162 224 148 201 130 233 131 260 135 282

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.3.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@

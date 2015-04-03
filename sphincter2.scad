include <parametric_involute_gear_v5.0.scad>


// http://de.wikipedia.org/wiki/Profilzylinder#Bema.C3.9Fung
// Aus Wikipedia:
//  Höhe:   33
//  D_Kopf: 17
//  Breite:       10
z_laenge        = 33+0.6;     // Länge Zylinder
z_hoehe         = 30;         // Höhe Zylinder
z_r_kopf        = (17)/2+0.2; // Radius Kopf
z_r_koerper     = 5+0.1;      // Radius Körper
z_korr_loecher  = 0.4;        // Y-Korrektur Bohrlöcher

p_breite        = 70;         // Breite Grundplatte
p_laenge        = 125;        // Länge Grundplatte
p_hoehe         = 5;          // Höhe Grundplatte
p_radius        = 5;          // Radius Eckenrundung

l_hoehe         = 20.1;       // Hoehe des Lagers
l_radius        = 27 - 0.2;   // Radius des Lagers
l_res           = 100;        // Auflösung Lager

m_langloch      = 3;          // Länge des Motorlanglochs

schluesseldicke = 2.5;        // Dicke des Schlüssels


generator = 0;  // Welches Teil soll generiert werden?
// 0: Alles
// 1: großes Zahnrad
// 2: kleines Zahnrad
// 3: Grundplatte
// 4: Halteplatte

cut = false;    // Schnitt durchs Modell


// wie bevel_gear_pair() aus der lib mit eigenen Anpassungen
module custom_bevel_gear_pair (
        gear1_teeth = 59,
        gear2_teeth = 17,
        axis_angle = 90,
        outside_circular_pitch=250,
        gr = 0) //gr=0 -> both; gr=1 -> big gear; gr=2 -> small gear
{
    outside_pitch_radius1 = gear1_teeth * outside_circular_pitch / 360;
    outside_pitch_radius2 = gear2_teeth * outside_circular_pitch / 360;

    pitch_apex1=outside_pitch_radius2 * sin (axis_angle) +
        (outside_pitch_radius2 * cos (axis_angle) +
         outside_pitch_radius1) / tan (axis_angle);

    cone_distance = sqrt (pow (pitch_apex1, 2) + 
            pow (outside_pitch_radius1, 2));

    pitch_apex2 = sqrt (pow (cone_distance, 2) -
            pow (outside_pitch_radius2, 2));

    echo ("cone_distance", cone_distance);

    pitch_angle1 = asin (outside_pitch_radius1 / cone_distance);
    pitch_angle2 = asin (outside_pitch_radius2 / cone_distance);

    echo ("pitch_angle1, pitch_angle2", pitch_angle1, pitch_angle2);
    echo ("pitch_angle1 + pitch_angle2", pitch_angle1 + pitch_angle2);

    rotate([0,0,90])
        translate ([0,0,pitch_apex1+20])
        {
            if(gr==0||gr==1){
                translate([0,0,-pitch_apex1])
                    bevel_gear (
                            face_width=12,
                            gear_thickness = 8.2,
                            number_of_teeth=gear1_teeth,
                            cone_distance=cone_distance,
                            pressure_angle=30,
                            outside_circular_pitch=outside_circular_pitch);
            }
            if(gr==0){
                rotate([0,-(pitch_angle1+pitch_angle2),0])
                    translate([0,0,-pitch_apex2])
                    bevel_gear (
                            face_width=10,
                            gear_thickness = 2,
                            number_of_teeth=gear2_teeth,
                            cone_distance=cone_distance,
                            pressure_angle=30,
                            outside_circular_pitch=outside_circular_pitch);
            }
            if(gr==2){
                translate([0,0,-pitch_apex2])
                    bevel_gear (
                            face_width=10,
                            gear_thickness = 2,
                            number_of_teeth=gear2_teeth,
                            cone_distance=cone_distance,
                            pressure_angle=30,
                            outside_circular_pitch=outside_circular_pitch);
            }
        }
}



module zahnrad(groesse=3) {

    if(groesse==0||groesse==1){ //großes und/oder kleines zahnrad zeichnen
        difference(){
            difference(){
                union(){
                    difference(){
                        union(){
                            rotate([0,0,180])translate([0,0,-5.3])
                                custom_bevel_gear_pair (gr=groesse);
                            if(groesse==0||groesse==1){
                                translate([0,0,12])
                                    cylinder(r=31,h=10,$fn=l_res);
                                translate([0,0,22])
                                    cylinder(r1=31,r2=23,h=7,$fn=l_res);
                            }
                        }

                        union(){
                            h_nut = 6 - 0.3;
                            translate([0,0,p_hoehe-0.1])
                                cylinder(
                                        r=l_radius+0.15+0.2,
                                        h=l_hoehe-p_hoehe-h_nut+2+0.1,
                                        $fn=l_res);

                            // innere Nut für Halteplatte
                            translate([0,0,16.2-0])
                                cylinder(r1=29+0.3,r2=27.5,h=h_nut,$fn=l_res);
                        }
                    }

                    // Brücken-Stütze
                    if(groesse==0||groesse==1){
                        //translate([0,0,15.3])cube([4,38,20],center=true);
                        hull() {
                            translate([0,16.3,5.3+0.3])cylinder(r=2.4,h=20);
                            translate([0,-16.3,5.3+0.3])cylinder(r=2.4,h=20);
                        }
                        translate([0,0,5.3])cube([20,40,0.6],center=true);
                    }
                }
                // Schlüssel-Schlitz
                hull(){
                    translate([0,16.3,0])
                        cylinder(r=schluesseldicke/2,h=40,$fn=10);
                    translate([0,-16.3,0])
                        cylinder(r=schluesseldicke/2,h=40,$fn=10);
                }
                // Löcher für Schraubendreher
                translate([0,16.3,0])
                    cylinder(r=2,h=40,$fn=10);
                translate([0,-16.3,0])
                    cylinder(r=2,h=40,$fn=10);
            }

            // Zahn-cut
            difference(){
                cylinder(r=50,h=20);
                cylinder(r=41,h=20,$fn=l_res);
            }

        }

    }

    if(groesse==2){  //kleines zahnrad drehen und befestigung zeichnen

        difference(){
            union(){
                difference(){
                    union(){
                        translate([0,0,9.15])
                            custom_bevel_gear_pair(gr=groesse);
                        translate([0,0,-8])cylinder(r=13.5,h=8,$fn=40);
                    }
                    cylinder(r=2.7,h=50,center=true,$fn=20);
                }
                //translate([-3,3-0.25-0.5,-8])cube([6,3,17]);
            }

            translate([0,20,-4])rotate([90,0,0])cylinder(r=1.8,h=20);
            #translate([0,8+6.7,-4])rotate([90,0,0])cylinder(r=3.1,h=5);
            hull(){
                translate([0,7.5,-4])rotate([90,30,0])
                    cylinder(r=3.25,h=3,$fn=6);
                translate([0,7.5,-8])rotate([90,30,0])
                    cylinder(r=3.25,h=3,$fn=6);
            }

            rotate([0,0,90]){
                translate([0,20,-4])rotate([90,0,0])cylinder(r=1.8,h=20);
                #translate([0,8+6.7,-4])rotate([90,0,0])cylinder(r=3.1,h=5);
                hull(){
                    translate([0,7.5,-4])rotate([90,30,0])
                        cylinder(r=3.25,h=3,$fn=6);
                    translate([0,7.5,-8])rotate([90,30,0])
                        cylinder(r=3.25,h=3,$fn=6);
                }
            }
        }
    }
}


module motor(){

    difference(){
        union(){
            translate([0,0,2])hull(){
                translate([-0.25-2,44,0])cylinder(r=2,h=43,$fn=20);
                translate([42.5+2,44,0])cylinder(r=2,h=43,$fn=20);
                translate([-0.25-2,18.5,0])cylinder(r=2,h=43,$fn=20);
                translate([42.5+2,18.5,0])cylinder(r=2,h=43,$fn=20);
            }
            hull(){
                translate([-0.25-2,44,0])cylinder(r1=4,r2=2,h=2,$fn=20);
                translate([42.5+2,44,0])cylinder(r1=4,r2=2,h=2,$fn=20);
                translate([-0.25-2,18.5,0])cylinder(r1=4,r2=2,h=2,$fn=20);
                translate([42.5+2,18.5,0])cylinder(r1=4,r2=2,h=2,$fn=20);
            }


        }

        hull(){
            translate([21.1-12,50,29.3])rotate([90,0,0])
                cylinder(r=0.5,h=10,$fn=20);
            translate([20.9+12,50,29.3])rotate([90,0,0])
                cylinder(r=0.5,h=10,$fn=20);
            translate([21-7,50,37])rotate([90,0,0])cylinder(r=0.1,h=10,$fn=20);
            translate([21+7,50,37])rotate([90,0,0])cylinder(r=0.1,h=10,$fn=20);
        }

        translate([-10,15,20])rotate([45,0,0])cube([60,50,50]);

        union(){ //NEMA17
            translate([-0.25,-0.25,-0.25])cube([42.5,42.5,50]);
            translate([21,42,21])rotate([270,0,0])cylinder(r=2.5,h=23,$fn=20);
            translate([21,42,21])rotate([270,0,0])cylinder(r=15,h=5,$fn=50);


            hull(){
                translate([21+15.5,42,21+15.5])rotate([270,0,0])
                    cylinder(r=1.7,h=10,$fn=20);
                translate([21+15.5,42,21+15.5+m_langloch])rotate([270,0,0])
                    cylinder(r=1.7,h=10,$fn=20);
            }
            hull(){
                translate([21-15.5,42,21+15.5])rotate([270,0,0])
                    cylinder(r=1.7,h=10,$fn=20);
                translate([21-15.5,42,21+15.5+m_langloch])rotate([270,0,0])
                    cylinder(r=1.7,h=10,$fn=20);
            }
            hull(){
                translate([21+15.5,42,21-15.5])rotate([270,0,0])
                    cylinder(r=1.7,h=10,$fn=20);
                translate([21+15.5,42,21-15.5+m_langloch])rotate([270,0,0])
                    cylinder(r=1.7,h=10,$fn=20);
            }
            hull(){
                translate([21-15.5,42,21-15.5])rotate([270,0,0])
                    cylinder(r=1.7,h=10,$fn=20);
                translate([21-15.5,42,21-15.5+m_langloch])rotate([270,0,0])
                    cylinder(r=1.7,h=10,$fn=20);
            }
        }
    }
}

module lager(){
    difference(){
        union(){
            cylinder(r=l_radius,h=l_hoehe-1,$fn=l_res); //Lager
            translate([0,0,l_hoehe-1])
                cylinder(r1=l_radius,r2=l_radius-1,h=1,$fn=l_res); //Fase
        }

        // Aussparung für Halteplatte
        translate([-20,5,16.2])cube([40,30,5]);

    }
}

module halteplatte() {

    difference(){
        translate([-19.8,5.1,16.2])cube([39.6,25,3.9]);

        translate([0,0,16.2]){
            difference(){
                cylinder(r=40,h=3.9);
                cylinder(r1=28.5,r2=27, h=3.9,$fn=l_res);
            }
        }
    }
}

module halteplatten_loecher() {
    // Muttern
    translate([12,11,0])cylinder(r=6.4/2,h=4,$fn=6);
    translate([-12,11,0])cylinder(r=6.4/2,h=4,$fn=6);

    // Löcher
    translate([12,11,4.3])cylinder(r=1.8,h=20);
    translate([-12,11,4.3])cylinder(r=1.8,h=20);

    // Versenkung
    translate([12,11,16.2+2.1])cylinder(r=3,h=5);
    translate([-12,11,16.2+2.1])cylinder(r=3,h=5);
}


module zylinder(
        lochabstand = 50
        ){

    cylinder(r=z_r_kopf,h=z_hoehe);
    hull(){
        cylinder(r=z_r_koerper,h=z_hoehe);
        translate([0,-(z_laenge-z_r_koerper-z_r_kopf),0])
            cylinder(r=z_r_koerper,h=z_hoehe);
    }

    // Die Befestigungslöcher sind symmetrisch zur vertikalen Mitte des 
    // Schließzylinders
    translate([0,-z_laenge/2+z_r_kopf+z_korr_loecher,0]){

        // Oberes Schraubloch
        translate([0,lochabstand/2,0])cylinder(r=2.2,h=z_hoehe);
        translate([0,lochabstand/2,2])cylinder(r1=2.2,r2=5.2,h=3);
        translate([0,lochabstand/2,5])cylinder(r=6.5,h=z_hoehe);

        // Unteres Schraubloch
        translate([0,-lochabstand/2,0])cylinder(r=2.2,h=z_hoehe);
        translate([0,-lochabstand/2,2])cylinder(r1=2.2,r2=5.2,h=3);

    }
}


module platte(){
    hull(){
        translate([p_breite/2-p_radius,p_laenge/2-p_radius,0])
            cylinder(r=p_radius,h=p_hoehe);
        translate([-(p_breite/2-p_radius),p_laenge/2-p_radius,0])
            cylinder(r=p_radius,h=p_hoehe);
        translate([p_breite/2-p_radius,-(p_laenge/2-p_radius),0])
            cylinder(r=p_radius,h=p_hoehe);
        translate([-(p_breite/2-p_radius),-(p_laenge/2-p_radius),0])
            cylinder(r=p_radius,h=p_hoehe);
    }

}

difference(){
    union(){
        if(generator==0||generator==3){
            translate([-21,-99,5])motor();
            difference(){
                union(){
                    translate([0,-22,0])platte();
                    lager();
                    if(generator!=3)halteplatte();
                }
                zylinder();
                halteplatten_loecher();
            }
        }
        if(generator==4){
            translate([0,-5.1,-16.2])
                difference(){
                    union(){
                        halteplatte();
                    }
                    zylinder();
                    halteplatten_loecher();
                }
        }
        // Rotate to see if screw holes fit
        //rotate([0,0,90-42.51])
        zahnrad(groesse=generator);
    }
    if(cut) cube([100,100,100]);
}

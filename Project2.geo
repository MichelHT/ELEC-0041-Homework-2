SetFactory("OpenCASCADE");
// Include the data 
Include "Project2_data.geo";

/********************* User defined funciton*********************/
/* This function create an oblong surface given by the union of the surface number Num_Surf, Num_Surf+1 and Num_Surf+2.
 The horizontal position, vertical position, length and width of the oblong surface are defined by the parameters X_Hole,
 H1, L and h respectively.*/
Function "Create_Oblong_hole"
	//Rectangle
	cp = newp ;
	Point(cp)       = {X_Hole, (H1 -(h/2)), 0, lc_holes};
	Point(cp+1)     = {X_Hole+L, (H1 -(h/2)), 0, lc_holes};
	Point(cp+2)     = {X_Hole+L, (H1 +(h/2)), 0, lc_holes};
	Point(cp+3)     = {X_Hole, (H1 +(h/2)), 0, lc_holes};

	cl = newl;
	Line(cl)    = {cp, cp+1};
	Line(cl+1)  = {cp+1, cp+2};
	Line(cl+2)  = {cp+2, cp+3};
	Line(cl+3)  = {cp+3, cp};

	cll = newll; 
	Curve Loop(cll) = {cl, cl+1, cl+2, cl+3};

	Plane Surface(Num_Surf) = {cll};
	
	// End circles
	cp = newp ; //Left
	Point(cp)     = {X_Hole, H1, 0, lc_holes};
	Point(cp+1)   = {X_Hole+(h/2), H1, 0, lc_holes};
	Point(cp+2)   = {X_Hole, H1+(h/2), 0, lc_holes};
	Point(cp+3)   = {X_Hole-(h/2), H1, 0, lc_holes};
	Point(cp+4)   = {X_Hole, H1-(h/2), 0, lc_holes};

	cl = newl;
	Circle(cl)   = {cp+1, cp, cp+2};
	Circle(cl+1) = {cp+2, cp, cp+3};
	Circle(cl+2) = {cp+3, cp, cp+4};
	Circle(cl+3) = {cp+4, cp, cp+1};
	
	cll = newll; 
	Curve Loop(cll) =  {cl, cl+1, cl+2, cl+3};
	Plane Surface(Num_Surf+1) = {cll};
	
	cp = newp ;//Right
	Point(cp)     = {X_Hole+L, H1, 0, lc_holes};
	Point(cp+1)   = {X_Hole+L+(h/2), H1, 0, lc_holes};
	Point(cp+2)   = {X_Hole+L, H1+(h/2), 0, lc_holes};
	Point(cp+3)   = {X_Hole+L-(h/2), H1, 0, lc_holes};
	Point(cp+4)   = {X_Hole+L, H1-(h/2), 0, lc_holes};

	cl = newl;
	Circle(cl)   = {cp+1, cp, cp+2};
	Circle(cl+1) = {cp+2, cp, cp+3};
	Circle(cl+2) = {cp+3, cp, cp+4};
	Circle(cl+3) = {cp+4, cp, cp+1};
	
	cll = newll; 
	Curve Loop(cll) =  {cl, cl+1, cl+2, cl+3};
	Plane Surface(Num_Surf+2) = {cll};
Return

/********************* Construction of the geometry *********************/
// Domain
cp = newp ;
Point(cp)       = {0, 0, 0, lc_boundary} ;
Point(cp+1)     = {Ldom, 0, 0, lc_boundary} ;
Point(cp+2)     = {Ldom, Hdom, 0, lc_boundary} ;
Point(cp+3)     = {0, Hdom, 0, lc_boundary} ;

cl = newl;
Line(cl)    = {cp, cp+1};
Line(cl+1)  = {cp+1, cp+2};
Line(cl+2)  = {cp+2, cp+3};
Line(cl+3)  = {cp+3, cp};

cll = newll; 
Curve Loop(cll) = {cl, cl+1, cl+2, cl+3} ;

Plane Surface(1) = {cll};


// Input and output terminals
TerminalPosx(1) = Ldom/2;  // Input position
TerminalPosy(1) =  Hin;

TerminalPosx(2) = (Ldom-(3*Dout))/2;  // Output position
TerminalPosy(2) =  Hout;
TerminalPosx(3) = ((Ldom-(3*Dout))/2)+(Dout);  
TerminalPosy(3) =  Hout;
TerminalPosx(4) = ((Ldom-(3*Dout))/2)+(2*Dout);  
TerminalPosy(4) =  Hout;
TerminalPosx(5) = ((Ldom-(3*Dout))/2)+(3*Dout);  
TerminalPosy(5) =  Hout;

For i In {1:5}	// Creation of the terminals
	cp = newp ;
	Point(cp)     = {TerminalPosx(i), TerminalPosy(i), 0, lc_InOut};
	Point(cp+1)   = {TerminalPosx(i)+(DiamCable/2), TerminalPosy(i), 0, lc_InOut};
	Point(cp+2)   = {TerminalPosx(i), TerminalPosy(i)+(DiamCable/2), 0, lc_InOut};
	Point(cp+3)   = {TerminalPosx(i)-(DiamCable/2), TerminalPosy(i), 0, lc_InOut};
	Point(cp+4)   = {TerminalPosx(i), TerminalPosy(i)-(DiamCable/2), 0, lc_InOut};

	cl = i*100;
	Circle(cl) = {cp+1, cp, cp+2};
	Circle(cl+1) = {cp+2, cp, cp+3};
	Circle(cl+2) = {cp+3, cp, cp+4};
	Circle(cl+3) = {cp+4, cp, cp+1};
	
	cll = newll; 
	Curve Loop(cll) =  {cl, cl+1, cl+2, cl+3};
	Plane Surface(1+i) = {cll};
EndFor

// Holes

If(Flag_Holes==0)
	// Removal of the inputs and outputs from the domain
	BooleanDifference{ Surface{1}; Delete; }{ Surface{2}; Surface{3}; Surface{4}; Surface{5}; Surface{6}; Delete; }
EndIf

If(Flag_Holes==1)
	X_Hole = (Ldom-L)/2;
	Num_Surf = 7;
	Call "Create_Oblong_hole";
	
	// Removal of the inputs, outputs and hole from the domain 
	BooleanDifference{ Surface{1}; Delete; }{ Surface{2}; Surface{3}; Surface{4}; Surface{5}; Surface{6}; Surface{7} ; Surface{8}; Surface{9}; Delete; }
EndIf

If(Flag_Holes==2)
	X_Hole = (Ldom-L-L-dist-h)/2;
	Num_Surf = 7;
	Call "Create_Oblong_hole";
	
	X_Hole = (Ldom-L-L-dist-h)/2+(L+h+dist);
	Num_Surf = 10;
	Call "Create_Oblong_hole";
	
	
	// Removal of the inputs, outputs and hole from the domain 
	BooleanDifference{ Surface{1}; Delete; }{ Surface{2}; Surface{3}; Surface{4}; Surface{5}; Surface{6}; Surface{7} ; Surface{8}; Surface{9}; Surface{10} ; Surface{11} ; Surface{12}; Delete; }
EndIf


/********************* Definition of the physical curves and surfaces *********************/
Physical Surface("Square_plate") = {1};
Physical Curve("Cond_in") = {100,101,102,103};
Physical Curve("Cond_out1") = {200,201,202,203};
Physical Curve("Cond_out2") = {300,301,302,303};
Physical Curve("Cond_out3") = {400,401,402,403};
Physical Curve("Cond_out4") = {500,501,502,503};



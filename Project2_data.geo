/********************* Imposed geometricals parameters *********************/
Ldom = 0.19;					// Domain length
Hdom = 0.09;					// Domain height
DiamCable = 0.005;				// Diameter of the input and outputs
Hin = 0.06;						// Vertical position of the input
Hout = 0.01;					// Vertical position of the outputs
Dout = 0.05;					// Distance between the outputs 

/********************* UI Path *********************/           

PathGeometricParameters  = "Input/010Geometric parameters/" ;
PathMaterialsParameters  = "Input/030Materials parameters/" ;
PathElectricalParameters = "Input/020Electrical parameters/";
PathMeshParameters       = "Input/040Mesh parameters/"      ;

/********************* Number of added holes *********************/
Flag_Holes          = DefineNumber[0, Name StrCat[PathGeometricParameters,"001Number of holes"]]; 

/********************* Geometricals parameters of the holes*********************/
If(Flag_Holes>0)
	H1 = DefineNumber[0.019, Name StrCat[PathGeometricParameters,"002Vertical position of the holes [m]"]];    
	L = DefineNumber[0.02, Name StrCat[PathGeometricParameters,"003Length of the hole [m]"]];    
	h = DefineNumber[0.005, Name StrCat[PathGeometricParameters,"004Width of the hole [m]"]];  
	If (Flag_Holes==2)
			dist = DefineNumber[0.025, Name StrCat[PathGeometricParameters,"005Distance bewteen the holes [m]"]];
	EndIf
EndIf

/********************* Mesh size parameter *********************/
lc_boundary_param = DefineNumber[35, Name StrCat[PathGeometricParameters,"006Mesh parameter on the boundary [-]"]];
lc_InOut_param = DefineNumber[50, Name StrCat[PathGeometricParameters,"007Mesh parameter on the terminals [-]"]];
If(Flag_Holes>0)
	lc_holes_param = DefineNumber[50, Name StrCat[PathGeometricParameters,"008Mesh parameter on the hole [-]"]];
	lc_holes = h/lc_holes_param;
EndIf

lc_boundary = Ldom/lc_boundary_param;			
lc_InOut = DiamCable/lc_InOut_param;

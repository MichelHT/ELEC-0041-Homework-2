Group {
  /**************** Geometrical regions ***************/
	Square_plate = Region[1];				// Bus bar
	Cond_in = Region [2];					// Input terminal
	Cond_out1 = Region[3];					// First output terminal
	Cond_out2 = Region[4];					// Second output terminal 
	Cond_out3 = Region[5];					// Third output terminal
	Cond_out4 = Region[6];					// Fourth output terminal 

	Vol_Ele = Region[ {Square_plate} ];
	Sur_Neu_Ele = Region[ {} ];
	Sur_Electrodes_Ele = Region [ {Cond_in, Cond_out1, Cond_out2 ,Cond_out3, Cond_out4} ];
	Borne_pos = Region[2];
	Borne_neg = Region[{3,4,5,6}];
}
RhoCond = DefineNumber[1.6e-8, Name "2Copper conductivity conductivity"] ;
InjectedCurrent = DefineNumber[400, Name "2Injected current"];

Function {
  sigma[Square_plate] = 1/RhoCond;
}

Constraint {
  { Name SetGlobalPotential; Type Assign;
    Case {      
        { Region Borne_neg; Value 0; }      
    }
  }
  { Name SetInjectedCurrent; Type Assign;
    Case {      
        { Region Borne_pos; Value InjectedCurrent; }    
    }
  }
}

Group{
  Dom_Hgrad_v_Ele =  Region[ {Vol_Ele, Sur_Neu_Ele, Sur_Electrodes_Ele} ];
}

FunctionSpace {
  { Name Hgrad_v_Ele; Type Form0;
    BasisFunction {
      { Name sn; NameOfCoef vn; Function BF_Node;
        Support Dom_Hgrad_v_Ele; Entity NodesOf[ All, Not Sur_Electrodes_Ele ]; }
      { Name sf; NameOfCoef vf; Function BF_GroupOfNodes;
        Support Dom_Hgrad_v_Ele; Entity GroupsOfNodesOf[ Sur_Electrodes_Ele ]; }
    }
    GlobalQuantity {
      { Name GlobalPotential; Type AliasOf       ; NameOfCoef vf; }
      { Name InjectedCurrent ; Type AssociatedWith; NameOfCoef vf; }
    }
    Constraint {
      { NameOfCoef GlobalPotential; EntityType GroupsOfNodesOf;
	NameOfConstraint SetGlobalPotential; }
      { NameOfCoef InjectedCurrent; EntityType GroupsOfNodesOf;
	NameOfConstraint SetInjectedCurrent; }
    }
  }
}

Jacobian {
  { Name Vol ;
    Case {
      { Region All ; Jacobian Vol ; }
    }
  }
}

Integration {
  { Name Int ;
    Case { {Type Gauss ;
            Case { { GeoElement Triangle    ; NumberOfPoints  4 ; }
                   { GeoElement Quadrangle  ; NumberOfPoints  4 ; } }
      }
    }
  }
}

Formulation {
  { Name Electrokinetic_v; Type FemEquation;
    Quantity {
      { Name v; Type Local; NameOfSpace Hgrad_v_Ele; }
      { Name U; Type Global; NameOfSpace Hgrad_v_Ele [GlobalPotential]; }
      { Name I; Type Global; NameOfSpace Hgrad_v_Ele [InjectedCurrent]; }
    }
    Equation {
      Integral { [ sigma[] * Dof{d v} , {d v} ];
        In Vol_Ele; Jacobian Vol; Integration Int; }
      GlobalTerm { [ -Dof{I} , {U} ]; In Sur_Electrodes_Ele; }
    }
  }
}

Resolution {
  { Name EleKin_v;
    System {
      { Name Sys_Ele; NameOfFormulation Electrokinetic_v; }
    }
    Operation {
      Generate[Sys_Ele]; Solve[Sys_Ele]; SaveSolution[Sys_Ele];
    }
  }
}

PostProcessing {
 { Name EleKin_v; NameOfFormulation Electrokinetic_v;
    Quantity {
      { Name v; Value {
          Term { [ {v} ]; In Vol_Ele; Jacobian Vol; }
        }
      }
      { Name e; Value {
          Term { [ -{d v} ]; In Vol_Ele; Jacobian Vol; }
        }
      }
      { Name j; Value {
          Term { [ -sigma[] * {d v} ]; In Vol_Ele; Jacobian Vol; }
        }
      }
      { Name I; Value {
          Term { [ {I} ]; In Sur_Electrodes_Ele; }
        }
      }
      { Name U; Value {
          Term { [ {U} ]; In Sur_Electrodes_Ele; }
        }
      }
      { Name R; Value {
          Term { [ {U}/{I} ]; In Sur_Electrodes_Ele; }
        }
      }
    }
  }
}

PostOperation {
  { Name Map; NameOfPostProcessing EleKin_v;
     Operation {
       Print[ v, OnElementsOf Dom_Hgrad_v_Ele, File "v.pos" ];
	   Print[ j, OnElementsOf Dom_Hgrad_v_Ele, File  "j.pos"];
       Print[ U, OnRegion Borne_pos, File > "output.txt", Color "AliceBlue",
	      Format Table, SendToServer "Output/Potential borne + [V]" ];
		Print[ I, OnRegion Cond_out1, File > "Current1.txt", Color "AliceBlue",
	      Format Table, SendToServer "Output/Current in out 1" ];
		Print[ I, OnRegion Cond_out2, File > "Current2.txt", Color "AliceBlue",
	      Format Table, SendToServer "Output/Current in out 2" ];
		Print[ I, OnRegion Cond_out3, File > "Current3.txt", Color "AliceBlue",
	      Format Table, SendToServer "Output/Current in out 3" ];
		Print[ I, OnRegion Cond_out4, File > "Current4.txt", Color "AliceBlue",
	      Format Table, SendToServer "Output/Current in out 4" ]; 
		Print[ R, OnRegion Borne_pos, File > "Total_resistance.txt", Color "Red",
	      Format Table, SendToServer "Output/Total resistance" ];
     }
  }
}

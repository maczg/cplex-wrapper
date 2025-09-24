/*********************************************
 * OPL 12.8.0.0 Model
 * Author: Gabriella
 * Creation Date: 09/feb/2021 at 18:50:06
 *********************************************/
/*********************************************
 * OPL 12.8.0.0 Model
 * Author: Gabriella
 * Creation Date: 21/dic/2020 at 10:09:54
 *********************************************/
using CP;
int K=...;
int S=...;
int F=...;

range chains=1..K;
range servers=1..S;
range functions=1..F;


float pis[servers]=...;
float pas[servers]=...;
float pfs[functions][servers]=...;
float pf[functions]=...;
float betafs[functions][servers]=...;
float lambda[chains]=...;
float lambdaB[chains]=...;
float chi[servers]=...;
float Zforzata[servers]=...;
float cI=...;
float cA=...;
float cVM=...;
float cP=...;
float cL=...;
float alpha=...;

int Lungh[chains]=...; 
range Lun=1..max(k in chains)Lungh[k];
range Lun2=2..max(k in chains)Lungh[k];
range Lunm=1..max(k in chains)Lungh[k]-1;
range ikf3=1..K*max(k in chains)Lungh[k];

float gamma[chains][Lun]=...;
float gammaB[chains][Lun]=...;
int pos[functions][chains]=...;

float C[servers]=...;
float Fss[servers][servers]=...;
float rprop[servers][servers]=...;
float w[servers][servers]=...;
float Rmax[servers]=...;
float sigma[functions][servers]=...;
float pVM[functions][servers]=...;


int ZMemory[functions][servers]=...;
int YMemory[functions][servers]=...;

//dexpr float Delay2[k in chains]= sum(i in 1..Lungh[k], s in 1..1, f in functions: pos[f][k]==i) (( (8)*sigma[f][s])/(C[s]-(sum(k2 in chains, g in functions: pos[g][k]==i && pos[g][k2]!=0) lambda[k2]*prod(j in 1..(pos[g][k2]-1))gamma[k2][j])*((8*sigma[f][s])))) ; //*************
dexpr float Delay5[s in servers][k in chains]= sum(i in 1..Lungh[k], f in functions: pos[f][k]==i) (( (F)*sigma[f][s])/(C[s]-(sum(k2 in chains, g in functions: pos[g][k]==i && pos[g][k2]!=0) lambda[k2]*prod(j in 1..(pos[g][k2]-1))gamma[k2][j])*((F*sigma[f][s])))) ; //*************
//float Delay2[chains]=...;

dvar int PsiMu3[servers][ikf3];
 

dvar boolean x[chains][Lun][servers];
dvar boolean xf[chains][functions][servers];

dvar boolean y[functions][servers];
dvar boolean z[servers];
dvar boolean zfs[functions][servers];
dvar boolean yk[chains];
//var cplex = IloCplex();


minimize(sum(s in servers)z[s]*cI*(1-chi[s])*pis[s]+ sum(s in servers)z[s]*cA*pas[s]  
+sum(s in servers)(cVM*(sum(f in functions)zfs[f][s]*pVM[f][s]))
+ sum(s in servers)(cP*(sum(k in chains) ( sum(f in functions : pos[f][k]==1)x[k][1][s]*pfs[f][s]*lambda[k]+ sum(i in Lun2, f in functions: pos[f][k]==i) x[k][i][s]*pfs[f][s]*lambda[k]*prod(j in 1..(i-1)) gamma[k][j]) ))
+cL*( sum(s in servers)sum(k in chains)( sum(i in (Lunm))x[k][i][s]*(sum(s2 in servers)w[s][s2]*x[k][i+1][s2] *lambdaB[k]*prod(j in 1..(i)) gammaB[k][j] ) ))
-0.01* (sum(s in servers)sum(f in functions)y[f][s])
-alpha*(sum(k in chains)yk[k]*lambda[k])
);



subject to{

forall(s in servers : Zforzata[s]==0)
Esclude_Droni_Non_Disponibili:
z[s]==0;

// --------------------- M E M O R Y -----------------------------------****************************
//forall(f in functions, s in servers : Zforzata[s]!=0 && ZMemory[f][s]==1)
//zfs[f][s]==ZMemory[f][s];

//forall(f in functions, s in servers : Zforzata[s]!=0 && YMemory[f][s]==1)
//y[f][s]==YMemory[f][s];

forall(k in chains, f in functions, s in servers: pos[f][k]!=0)
 Uguaglianza_x_w:
x[k][pos[f][k]][s]==xf[k][f][s];

forall(k in chains, f in functions, s in servers: pos[f][k]==0)
Esclude_w:
xf[k][f][s]==0;

forall(k in chains, f in functions, s in servers)
Costruzione_z_1:
xf[k][f][s]<=z[s];

forall(s in servers)
  Costruzione_z_2:
z[s]<=1;

forall(s in servers)
  Costruzione_z_3:
z[s]<=sum(k in chains, f in functions)xf[k][f][s];

forall(k in chains, f in functions, s in servers)
  Costruzione_zf_1:
xf[k][f][s]<=zfs[f][s];

forall(k in chains, f in functions, s in servers)
  Costruzione_zf_2:
zfs[f][s]<=1;

forall(f in functions, s in servers)
  Costruzione_zf_3:
zfs[f][s]<=sum(k in chains)xf[k][f][s];

forall(f in functions, s in servers)
  Costruzione_y:
y[f][s]<=(sum(k in chains)xf[k][f][s]-1)*(sum(k in chains)xf[k][f][s]);

	forall(k in chains, i in Lun)
	  Assegnazione_1_drone:
	  sum(s in servers)x[k][i][s]==yk[k];

// **********************************
	  forall(s in servers)
	    Capacity_max_droni:
	    sum(k in chains, i in 1..Lungh[k], f in functions: pos[f][k]==i)sigma[f][s]*x[k][i][s]*lambda[k]* prod(j in 1..(i-1))gamma[k][j]<=C[s];
  	    
	    forall(s in servers, s2 in servers)
	      Capacity_max_link:
	      sum(k in chains, i in 1..Lungh[k]-1)x[k][i][s]*x[k][i+1][s2]*lambdaB[k]*( prod(j in 1..i)gammaB[k][j])<=Fss[s][s2];
	    
forall(k in chains)
  Ritardo:
 sum(i in 1..Lungh[k], s in servers, f in functions: pos[f][k]==i) ((x[k][i][s]* (sum(f2 in functions) zfs[f2][s])*sigma[f][s])/(C[s]-(sum(k2 in chains: pos[f][k]==i && pos[f][k2]!=0) x[k2][pos[f][k2]][s]*lambda[k2]*prod(j in 1..(pos[f][k2]-1))gamma[k2][j])*(sum(f2 in functions) (zfs[f2][s]*sigma[f][s]))))<= Rmax[k] ; //*************

    


   forall(k in chains, i in Lun, s in servers, f in functions: pos[f][k]==i ) 
   ConstrPsimu:
((sum(f2 in functions)zfs[f2][s])*sigma[f][s])* (sum(k2 in chains: pos[f][k]==i && pos[f][k2]!=0) x[k2][pos[f][k2]][s]*lambda[k2]*prod(j in 1..(pos[f][k2]-1))gamma[k2][j])<=C[s];

 forall(s in servers, k in chains, i in Lun, g in functions: pos[g][k]==i)
   ConUltima:
PsiMu3[s][(i)+Lungh[k]*(k-1)]>=((sum(f2 in functions)zfs[f2][s])*sigma[g][s])* (sum(k2 in chains: pos[g][k]==i && pos[g][k2]!=0) x[k2][pos[g][k2]][s]*lambda[k2]*prod(j in 1..(pos[g][k2]-1))gamma[k2][j]);
 

}

//woow start
tuple xTuple {
int chains;
int Lun;
int servers;
int value;
}
//woow end1..to be continued after the subject to blok
{xTuple}xSet={<k,i,s,x[k,i,s]>| k in chains, i in 1..Lungh[k], s in servers}; 
//woow

//woow start
tuple xfTuple {
int chains;
int functions;
int servers;
int value;
}
//woow end1..to be continued after the subject to blok
{xfTuple}xfSet={<k,f,s,xf[k,f,s]>| k in chains, f in functions, s in servers}; 
//woow




float fo=(sum(s in servers)z[s]*cI*(1-chi[s])*pis[s]+ sum(s in servers)z[s]*cA*pas[s]  
+sum(s in servers)(cVM*(sum(f in functions)zfs[f][s]*pVM[f][s]))
+ sum(s in servers)(cP*(sum(k in chains) ( sum(f in functions : pos[f][k]==1)x[k][1][s]*pfs[f][s]*lambda[k]+ sum(i in Lun2, f in functions: pos[f][k]==i) x[k][i][s]*pfs[f][s]*lambda[k]*prod(j in 1..(i-1)) gamma[k][j]) ))
+cL* (sum(s in servers)sum(k in chains)( sum(i in (Lunm))x[k][i][s]*(sum(s2 in servers)w[s][s2]*x[k][i+1][s2] *lambdaB[k]*prod(j in 1..(i)) gammaB[k][j] ) ))
-alpha*(sum(k in chains)yk[k]*lambda[k]));
//-0.01* (sum(s in servers)sum(f in functions)y[f][s])



float CapacityD1= sum(s in 1..1, k in chains, i in 1..Lungh[k], f in functions: pos[f][k]==i)sigma[f][s]*x[k][i][s]*lambda[k]* prod(j in 1..(i-1))gamma[k][j];
float CapacityD2= sum(s in 2..2, k in chains, i in 1..Lungh[k], f in functions: pos[f][k]==i)sigma[f][s]*x[k][i][s]*lambda[k]* prod(j in 1..(i-1))gamma[k][j];
 float CapacityD3= sum(s in 3..3, k in chains, i in 1..Lungh[k], f in functions: pos[f][k]==i)sigma[f][s]*x[k][i][s]*lambda[k]* prod(j in 1..(i-1))gamma[k][j];
 float CapacityD4= sum(s in 4..4, k in chains, i in 1..Lungh[k], f in functions: pos[f][k]==i)sigma[f][s]*x[k][i][s]*lambda[k]* prod(j in 1..(i-1))gamma[k][j];
 float CapacityD5= sum(s in 5..5, k in chains, i in 1..Lungh[k], f in functions: pos[f][k]==i)sigma[f][s]*x[k][i][s]*lambda[k]* prod(j in 1..(i-1))gamma[k][j];
 float CapacityD[s in servers]=sum(k in chains, i in 1..Lungh[k], f in functions: pos[f][k]==i)sigma[f][s]*x[k][i][s]*lambda[k]* prod(j in 1..(i-1))gamma[k][j];
 
 
 float CapacityLink[s in servers][s2 in servers]=sum(k in chains, i in 1..Lungh[k]-1)x[k][i][s]*x[k][i+1][s2]*lambdaB[k]* (prod(j in 1..i)gammaB[k][j]);

float Delay[k in chains]= sum(i in 1..Lungh[k], s in servers, f in functions: pos[f][k]==i) ((x[k][i][s]* (sum(f2 in functions) zfs[f2][s])*sigma[f][s])/(C[s]-(sum(k2 in chains, g in functions: pos[g][k]==i && pos[g][k2]!=0) x[k2][pos[g][k2]][s]*lambda[k2]*prod(j in 1..(pos[g][k2]-1))gamma[k2][j])*(sum(f2 in functions) (zfs[f2][s]*sigma[f][s])))) ; //*************


 
 float attivazione[s in servers]=z[s]*(1-chi[s])*pis[s];
 float attivazione2[s in servers]=(z[s]*pas[s]);
  float EnergyConsumption[s in servers] = sum(k in chains) ( sum(f in functions : pos[f][k]==1)x[k][1][s]*pfs[f][s]*lambda[k]+ sum(i in Lun2, f in functions: pos[f][k]==i) x[k][i][s]*pfs[f][s]*lambda[k]*prod(j in 1..(i-1)) gamma[k][j]); 
 
 float Links =sum(s in servers)sum(k in chains)( sum(i in Lunm)x[k][i][s]*(sum(s2 in servers)w[s][s2]*x[k][i+1][s2] *lambdaB[k]*prod(j in 1..(i)) gammaB[k][j] ) );
  float PowerVM[f in functions, s in servers]= zfs[f][s]*pVM[f][s];
 
 float Linksss[s in servers][s2 in servers] =sum(k in chains)(sum(i in (Lunm))x[k][i][s]*(w[s][s2]*x[k][i+1][s2] *lambdaB[k]*prod(j in 1..(i)) gammaB[k][j] ) );
 float foalpha=alpha*(sum(k in chains)yk[k]*lambda[k]);
  float fonalpha=(sum(k in chains)yk[k]*lambda[k]);
 
  float FLUSSI[f in functions][s in servers]=sum(k in chains : pos[f][k]==1) ( x[k][1][s]*lambda[k])+ sum(k in chains, i in Lun2: pos[f][k]==i) (x[k][i][s]*lambda[k]*prod(j in 1..(i-1)) gamma[k][j]);
 
 dexpr int status=prod(s in servers)z[s]+1;
 //dvar int mipemphasis;
//float status= cplex.getStatus();
// int status=cplex.solve;
// IloCplex::getStatus();
 //cp.getStatus();
 //CPXgetstat;
 //getCplexStatus;
 //CPX_STAT_OPTIMAL;
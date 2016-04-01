#include <iostream>
#include <fstream>
#include <string>
#include <vector>
using namespace std;

void analyzestresstests() {
  ifstream data ("jys2124.log");

  // vector<string>  date,time,g,r,trash;
  // vector<float>   temperature,humidity,intensity;
  // vector<float>   g1,g2,g3,g4,r1,r2,r3,r4;
  // string date_str,time_str,g_str,r_str,trash_str;
  // float temp_f,humidity_f,intensity_f,g1_f,g2_f,g3_f,g4_f,r1_f,r2_f,r3_f,r4_f;

  const int datasize = 4000;
   string adate[datasize],atime[datasize],trash[datasize];
   float temperature[datasize],humidity[datasize],intensity[datasize],index[datasize];
   float g1[datasize],g2[datasize],g3[datasize],g4[datasize];
   float r1[datasize],r2[datasize],r3[datasize],r4[datasize];
   string g[datasize],r[datasize];
  int i = 0;

  //if (data.is_open()) {

  while ( data >> adate[i] >> atime[i] >> temperature[i] >> humidity[i] 
	  >> g[i] >> g1[i] >> g2[i] >> g3[i] >> g4[i]
	  >> r[i] >> r1[i] >> r2[i] >> r3[i] >> r4[i] ) {
    index[i] = i;
    ++i;
    }

  int npts = i;

  TH2F *hframegray[4];
  TH2F *hframered[4];
  TGraph *ggray[4];
  TGraph *gred[4];

  hframegray[0] = new TH2F( "hframegray0", "Gray: X Position vs. Index",
			    100, -1, npts+1, 100, 0, 640 );
  hframegray[1] = new TH2F( "hframegray1", "Gray: Y Position vs. Index",
			    100, -1, npts+1, 100, 0, 480 );
  hframegray[2] = new TH2F( "hframegray2", "Gray: Intensity vs. Index",
			    100, -1, npts+1, 100, 0, 3.e6 );
  hframegray[3] = new TH2F( "hframegray3", "Gray: idunno vs. Index",
			    100, -1, npts+1, 100, 0, 640 );

  hframered[0] = new TH2F( "hframered0", "Red: X Position vs. Index",
			    100, -1, npts+1, 100, 0, 640 );
  hframered[1] = new TH2F( "hframered1", "Red: Y Position vs. Index",
			    100, -1, npts+1, 100, 0, 480 );
  hframered[2] = new TH2F( "hframered2", "Red: Intensity vs. Index",
			    100, -1, npts+1, 100, 0, 3.e6 );
  hframered[3] = new TH2F( "hframered3", "Red: idunno vs. Index",
			    100, -1, npts+1, 100, 0, 640 );

  ggray[0] = new TGraph( npts, index, g1 );
  ggray[1] = new TGraph( npts, index, g2 );
  ggray[2] = new TGraph( npts, index, g3 );
  ggray[3] = new TGraph( npts, index, g4 );

  gred[0] = new TGraph( npts, index, r1 );
  gred[1] = new TGraph( npts, index, r2 );
  gred[2] = new TGraph( npts, index, r3 );
  gred[3] = new TGraph( npts, index, r4 );

  for ( int i=0; i<4; ++i ) {
    ggray[i]->SetMarkerStyle( 8 );
    ggray[i]->SetMarkerColor( 13 );
    gred[i]->SetMarkerStyle( 8 );
    gred[i]->SetMarkerColor( 2 );
  }
  
  TCanvas *c1 = new TCanvas("c1","hello world", 100, 0, 1200, 800);
  c1->Divide( 4,2 );
  for ( int i=0; i<4; ++i ) {
    c1->cd( i+1 );
    hframegray[i]->Draw();
    ggray[i]->Draw("p");
    c1->cd( i+5 );
    hframered[i]->Draw();
    gred[i]->Draw("p");
  }
  //  gr1->Draw("ap");
 
}

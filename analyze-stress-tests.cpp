#include <iostream>
#include <fstream>
#include <string>
#include <vector>
using namespace std;

int main () {
  string line;
  ifstream data ("jys2124.log");

  vector<string>  date,time,g,r,trash;
  vector<float>   temperature,humidity,intensity;
  vector<float>   g1,g2,g3,g4,r1,r2,r3,r4;
  string date_str,time_str,g_str,r_str,trash_str;
  float temp_f,humidity_f,intensity_f,g1_f,g2_f,g3_f,g4_f,r1_f,r2_f,r3_f,r4_f;
  int index[4000];

  const int datasize = 4000;
  //  string date[datasize],time[datasize],trash[datasize];
  //  float temperature[datasize],humidity[datasize],intensity[datasize],index[datasize];
  //  float g1[datasize],g2[datasize],g3[datasize],g4[datasize];
  //  float r1[datasize],r2[datasize],r3[datasize],r4[datasize];
  //  string g[datasize],r[datasize];
  int i = 0;

  if (data.is_open()) {

    while (std::getline (data, line)) {

      cout << line << '\n';

      //      stringstream linestream(line);
      float value;
      string str;

      if (i % 4 == 0) {
	while(line >> date_str >> time_str >> temp_f >> humidity_f) {
	  date.push_back(date_str);
	  time.push_back(time_str);
	  temperature.push_back(temp_f);
	  humidity.push_back(humidity_f);
	}
      }
      


      //      std::istringstream iss(line);

      //      if ( i % 4 == 0) {
      //	line << date[i] << time[i] << temperature[i] << humidity[i];
      //      }
      //      else if ( i % 4 == 1 ) {
      //	g[i] << g1[i] << g2[i] << g3[i] << g4[i] << line;
      //      }
      //      else if ( i % 4 == 2 ) {
      //	r[i] << r1[i] << r2[i] << r3[i] << r4[i] << line;
      //      }
      ++i;
    }
    data.close();
  }

  else cout << "Unable to open file";

  int npts = i;

  //  TGraph *gr1 = new TGraph( npts, index, a );

  //  TCanvas *c1 = TCanvas("c1","hello world", 100, 0, 500, 500);
  //  gr1->Draw("ap");

  return 0;
}

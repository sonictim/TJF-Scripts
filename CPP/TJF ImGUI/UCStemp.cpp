#include <cstdlib>
#include <iostream>
#include <string>
#include <limits>
#include <vector>
#include <sstream>
#include <numeric>
#include <ctime>
#include <cmath>
#include <fstream>




void getUCSdata() {

  ifstream readFromFile;
  string txtFromFile = "";
  string file = "/Volumes/etc/UCSFile"
 
  readFromFile.open("test.txt", ios_base::in);
  if(readFromFIle.is_open()) {
    while(readFromFile.good()){
        getline(readFromFile, txtFromFile);
        cout << txtFromFile << endl;
    }
    readFromFile.close();
  }
 


}
void TJFFunction() {
    ShowConsoleMsg("Hello World!\n");
    MB("Hello World!", "TITLE BAR", 0 );
}


TJFRegisterAction(&TJFFunction, "TJF_CPP_HELLOWORLD", "TJF C++ Hello World", false, false);



#!/bin/sh

sed -i "/\/\* USER CODE BEGIN PFP \*\//a\
void setup(void);\
void loop(void);" "../Core/Src/main.c"
sed -i "/\/\* USER CODE BEGIN 2 \*\//a\
\  setup();" "../Core/Src/main.c"
sed -i "/\/\* USER CODE BEGIN 3 \*\//a\
\    loop();" "../Core/Src/main.c"
